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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    plant = ModalRoute.of(context)?.settings.arguments as Plant?;
    if (plant != null) {
      _fetchMoistureData();
      _loadModelAndClassifyImage();
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
          String label = maxConfidence > 0.5 ? getLabel(maxIndex) : 'Görsel algılanamadı! \nBu bir bitki görseli olmayabilir veya veri setinde mevcut olmayan bir bitki olabilir.';

          setState(() {
            health_status = label;
          });
          print('Health status updated to: $health_status');
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
    final statusFormatted = status == 'healthy' ? 'Healthy' : 'Unhealthy';
    return '$plantName $statusFormatted';
  }

  @override
  Widget build(BuildContext context) {
    if (plant == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Plant Details'),
        ),
        body: Center(
          child: Text('Plant data not available.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(plant!.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.3,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: plant!.imageUrl.isNotEmpty
                      ? Image.file(
                          File(plant!.imageUrl),
                          fit: BoxFit.cover,
                        )
                      : Placeholder(),
                ),
              ),
            ),
            SizedBox(height: 16),
            // Display plant name
            Text(
              plant!.name,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            // Display plant type
            Text(
              'Tür: ${plant!.type}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            // Display other plant details
            Text('Nem Oranı: %$moisture'),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: 'Sağlık Durumu: '),
                  TextSpan(
                    text: health_status,
                    style: TextStyle(fontWeight: FontWeight.bold),
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
