import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:firebase_storage/firebase_storage.dart';
import '../../../domain/entities/plant.dart';
import 'package:firebase_database/firebase_database.dart';
import 'plant_history_view.dart';
class PlantInfoDetailsView extends ConsumerStatefulWidget {
  const PlantInfoDetailsView({Key? key}) : super(key: key);

  @override
  _PlantInfoDetailsViewState createState() => _PlantInfoDetailsViewState();
}

class _PlantInfoDetailsViewState extends ConsumerState<PlantInfoDetailsView> {
  Plant? plant;
  int moisture = 0;
  String health_status = 'Bitkinin sağlık durumu belirleniyor...';
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();
  Interpreter? _interpreter;
  String? latestImageUrl;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    plant = ModalRoute.of(context)?.settings.arguments as Plant?;
    if (plant != null) {
      _fetchMoistureData();
      _loadModelAndClassifyImage();
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchLatestImageUrl();
  }

  Future<void> _fetchLatestImageUrl() async {
    final storageRef = FirebaseStorage.instance.ref().child('images/');
    final listResult = await storageRef.listAll();
    final allFiles = listResult.items;

    if (allFiles.isNotEmpty) {
      Reference? latestFile;
      DateTime latestTime = DateTime(1970);

      for (var file in allFiles) {
        final metadata = await file.getMetadata();
        if (metadata.timeCreated != null && metadata.timeCreated!.isAfter(latestTime)) {
          latestTime = metadata.timeCreated!;
          latestFile = file;
        }
      }

      if (latestFile != null) {
        final latestUrl = await latestFile.getDownloadURL();
        setState(() {
          latestImageUrl = latestUrl;
        });
      }
    }
  }

  Future<void> _loadModelAndClassifyImage() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/model/model.tflite');

      final ListResult result = await FirebaseStorage.instance
          .ref('images')
          .listAll();

      Reference? newestRef;
      DateTime latestTime = DateTime(1970);

      for (var item in result.items) {
        final metadata = await item.getMetadata();
        if (metadata.timeCreated != null && metadata.timeCreated!.isAfter(latestTime)) {
          latestTime = metadata.timeCreated!;
          newestRef = item;
        }
      }

      if (newestRef != null) {
        final String imageUrl = await newestRef.getDownloadURL();
        print('En yeni görsel URL: $imageUrl');

        // Veritabanında bu görsel için zaten bir sonuç olup olmadığını kontrol et
        final historyRef = _databaseReference.child('plant_history');
        final snapshot = await historyRef.orderByChild('imageUrl').equalTo(imageUrl).once();

        if (snapshot.snapshot.value != null) {
          print('Bu görsel için zaten bir sonuç var.');
          final data = snapshot.snapshot.value as Map<dynamic, dynamic>;
          final existingLabel = data.values.first['label'];
          setState(() {
            health_status = existingLabel;
          });
          return;
        }

        final response = await HttpClient().getUrl(Uri.parse(imageUrl));
        final httpResponse = await response.close();
        final bytes = await consolidateHttpClientResponseBytes(httpResponse);
        final image = img.decodeImage(bytes);

        if (image != null) {
          final resizedImage = img.copyResize(image, width: 224, height: 224);
          var input = imageToByteListFloat32(resizedImage, 224, 127.5, 127.5);
          var output = List.generate(1, (_) => List.filled(18, 0.0));
          var final_input = input.reshape([1, 224, 224, 3]);

          _interpreter?.run(final_input, output);
          print('After running interpreter');

          // Calculate max confidence
          double maxConfidence = output[0].reduce((a, b) => a > b ? a : b);
          print(maxConfidence);
          int maxIndex = output[0].indexOf(maxConfidence);
          String label = maxConfidence > 0.63 ? getLabel(maxIndex) : 'Görsel algılanamadı! \nBu bir bitki görseli olmayabilir veya veri setinde mevcut olmayan bir bitki olabilir.';

          setState(() {
            health_status = label;
          });
          print('Health status updated to: $health_status');

          // Model sonucunu veritabanına kaydet
          await _databaseReference.child('plant_history').push().set({
            'imageUrl': imageUrl,
            'label': label,
            'date': DateTime.now().toIso8601String(),
          });
        } else {
          print('Failed to decode image.');
          setState(() {
            health_status = 'Görsel algılanamadı!';
          });
        }
      } else {
        print('No images found in Firebase Storage.');
        setState(() {
          health_status = 'Görsel algılanamadı!';
        });
      }
    } catch (e) {
      print('Error in _loadModelAndClassifyImage: $e');
      setState(() {
        health_status = 'Görsel algılanamadı!';
      });
    }
  }

  List<double> imageToByteListFloat32(
      img.Image image, int inputSize, double mean, double std) {
    var convertedBytes = <double>[];
    for (var y = 0; y < inputSize; y++) {
      for (var x = 0; x < inputSize; x++) {
        var pixel = image.getPixel(x, y);
        convertedBytes.add(img.getRed(pixel) / 255.0);
        convertedBytes.add(img.getGreen(pixel) / 255.0);
        convertedBytes.add(img.getBlue(pixel) / 255.0);
      }
    }
    return convertedBytes;
  }

  Future<void> _fetchMoistureData() async {
    try {
      final moistureRef = _databaseReference.child('plant/moisture');
      moistureRef.onValue.listen((event) {
        final int newMoisture = event.snapshot.value as int;
        setState(() {
          moisture = newMoisture.toInt();
        });
        print('Moisture data fetched: $newMoisture');
      });
    } catch (e) {
      print('Error fetching moisture data: $e');
    }
  }

  List<String> labels = [
    'aloe_vera_healthy',
    'aloe_vera_unhealthy',
    'boston_fern_healthy',
    'boston_fern_unhealthy',
    'chinese_money_plant_healthy',
    'chinese_money_plant_unhealthy',
    'dracaena_healthy',
    'dracaena_unhealthy',
    'jade_plant_healthy',
    'jade_plant_unhealthy',
    'monstera_deliciosa_healthy',
    'monstera_deliciosa_unhealthy',
    'peace_lily_healthy',
    'peace_lily_unhealthy',
    'rubber_plant_healthy',
    'rubber_plant_unhealthy',
    'snake_plant_healthy',
    'snake_plant_unhealthy',
  ];

  String getLabel(int index) {
    final label = labels[index];
    final parts = label.split('_');
    if (parts.length < 2) return label;
    final status = parts.last;
    final plantName = parts.sublist(0, parts.length - 1).map((word) => word[0].toUpperCase() + word.substring(1)).join(' ');
    final statusFormatted = status == 'healthy' ? 'Sağlıklı' : 'Sağlıksız';
    return '$plantName $statusFormatted';
  }

  // Add a helper function to return the appropriate emoji based on health_status
  String _getHealthEmoji(String status) {
    if (status.contains("Sağlıklı")) {
      return "😊";
    } else if (status.contains("Sağlıksız")) {
      return "😢";
    } else if (status.contains("Görsel algılanamadı")) {
      return "❓";
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    if (plant == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Plant Details'),
        ),
        body: const Center(
          child: Text('Plant data not available.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(plant!.name),
        backgroundColor: Colors.white,
      ),
      body: latestImageUrl == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image card with rounded borders and shadow
                  Center(
                    child: Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.33,
                          width: double.infinity,
                          child: Image.network(
                            latestImageUrl!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Plant Name and Type
                  Text(
                    plant!.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tür: ${plant!.type}',
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.black54,
                    ),
                  ),
                  const Divider(height: 30, thickness: 1),
                  // Moisture and Health Status Card with icons
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          // Moisture widget
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.opacity,
                                  color: Colors.lightBlue, size: 32),
                              const SizedBox(height: 8),
                              Text(
                                '%$moisture',
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Nem',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black54),
                              ),
                            ],
                          ),
                          // Vertical Divider
                          Container(
                            height: 60,
                            width: 1,
                            color: Colors.grey.shade300,
                          ),
                          // Health Status widget
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.health_and_safety,
                                    color: Colors.redAccent, size: 32),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        health_status,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _getHealthEmoji(health_status),
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Button to navigate to Plant History View
                  Center(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.history, color: Colors.white),
                      label: const Text(
                        'Bitki Geçmişini Göster',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white, // Yazı ve ikon rengi beyaz
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 14),
                        textStyle: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PlantHistoryView(plantId: plant!.id),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

