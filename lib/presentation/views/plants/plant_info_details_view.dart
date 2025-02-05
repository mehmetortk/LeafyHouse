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

      final ListResult result = await FirebaseStorage.instance.ref('images').listAll();
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

        // Veritabanında bu görsel için zaten bir sonuç olup olmadığını kontrol et
        final historyRef = _databaseReference.child('plant_history');
        final snapshot = await historyRef.orderByChild('imageUrl').equalTo(imageUrl).once();

        if (snapshot.snapshot.value != null) {
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

          double maxConfidence = output[0].reduce((a, b) => a > b ? a : b);
          int maxIndex = output[0].indexOf(maxConfidence);
          String label = maxConfidence > 0.63
              ? getLabel(maxIndex)
              : 'Görsel algılanamadı!\nBu bir bitki görseli olmayabilir veya veri setinde mevcut olmayan bir bitki olabilir.';

          setState(() {
            health_status = label;
          });

          // Sonucu veritabanına kaydet
          await _databaseReference.child('plant_history').push().set({
            'imageUrl': imageUrl,
            'label': label,
            'date': DateTime.now().toIso8601String(),
          });
        } else {
          setState(() {
            health_status = 'Görsel algılanamadı!';
          });
        }
      } else {
        setState(() {
          health_status = 'Görsel algılanamadı!';
        });
      }
    } catch (e) {
      setState(() {
        health_status = 'Görsel algılanamadı!';
      });
    }
  }

  List<double> imageToByteListFloat32(img.Image image, int inputSize, double mean, double std) {
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
      });
    } catch (e) {
      // Hata yönetimi
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
    final plantName = parts.sublist(0, parts.length - 1)
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
    final statusFormatted = status == 'healthy' ? 'Sağlıklı' : 'Sağlıksız';
    return '$plantName $statusFormatted';
  }

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (plant == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Plant Details'),
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        ),
        body: const Center(child: Text('Plant data not available.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          plant!.name,
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
        backgroundColor: isDark 
            ? const Color(0xFF1E1E1E)  // Dark mode için koyu gri
            : const Color(0xFF2E7D32), // Light mode için yeşil
        centerTitle: true,
        elevation: isDark ? 0 : 2,
      ),
      backgroundColor: isDark ? Colors.black : Colors.grey[100],
      body: latestImageUrl == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Üst Görsel Bölümü - Stack içinde image ve overlay title
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.35,
                          width: double.infinity,
                          child: Image.network(
                            latestImageUrl!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.35,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              isDark ? Colors.black54 : Colors.black26,
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        left: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              plant!.name,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    blurRadius: 4.0,
                                    color: Colors.black45,
                                    offset: const Offset(2, 2),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tür: ${plant!.type}',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Bilgi Kartı (Nem ve Sağlık)
                  Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    color: isDark ? Colors.grey[850] : Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12), // vertical padding'i arttırdık
                      child: IntrinsicHeight( // IntrinsicHeight ekledikxw
                        child: Row(
                          children: [
                            Expanded(
                              child: Row( // Column yerine Row kullandık
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12), // Padding'i azalttık
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: isDark
                                            ? [Colors.blueGrey, Colors.blue]
                                            : [Colors.lightBlue[300]!, Colors.blue], // Light modda mavi tonları
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.opacity,
                                      size: 24, // Icon boyutunu küçülttük
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column( // İç içe Column
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '%$moisture',
                                        style: TextStyle(
                                          fontSize: 20, // Font boyutunu küçülttük
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? Colors.white : Colors.green[900],
                                        ),
                                      ),
                                      Text(
                                        'Nem',
                                        style: TextStyle(
                                          fontSize: 14, // Font boyutunu küçülttük
                                          color: isDark ? Colors.white70 : Colors.grey[800],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 100, // Yüksekliği arttırdık
                              width: 1,
                              color: isDark ? Colors.white30 : Colors.grey[300],
                            ),
                            Expanded(
                              child: Row( // Column yerine Row kullandık
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12), // Padding'i azalttık
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: isDark
                                            ? [Colors.deepOrange, Colors.orange]
                                            : [Colors.orange[300]!, Colors.deepOrange], // Light modda turuncu tonları
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.health_and_safety,
                                      size: 24, // Icon boyutunu küçülttük
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded( // Sağlık durumu metni için Expanded
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            health_status,
                                            maxLines: 4, // Maksimum satır sayısını arttırdık
                                            overflow: TextOverflow.ellipsis, // Taşma durumunda ...
                                            style: TextStyle(
                                              fontSize: 12, // Font boyutunu küçülttük
                                              height: 1.3, // Satır aralığını ayarladık
                                              fontWeight: FontWeight.bold,
                                              color: isDark ? Colors.white : Colors.black87,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Geçmişe Git Butonu
                  Center(
                    child: ElevatedButton.icon(
                      icon: const Icon(
                        Icons.history,
                        color: Colors.white, // Always white
                      ),
                      label: const Text(
                        'Bitki Geçmişini Göster',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // Always white
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark
                            ? Theme.of(context).colorScheme.secondary
                            : Colors.greenAccent[400],
                        padding: const EdgeInsets.symmetric(
                            horizontal: 36, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 4,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlantHistoryView(plantId: plant!.id),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[850] : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Bitki Durumu',
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getHealthEmoji(health_status),
                          style: const TextStyle(fontSize: 40),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}