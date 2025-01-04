import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/plant.dart';
import 'package:firebase_database/firebase_database.dart';

class PlantInfoDetailsView extends ConsumerStatefulWidget {
  const PlantInfoDetailsView({Key? key}) : super(key: key);

  @override
  _PlantInfoDetailsViewState createState() => _PlantInfoDetailsViewState();
}

class _PlantInfoDetailsViewState extends ConsumerState<PlantInfoDetailsView> {
  Plant? plant;
  bool isWatering = false;
  Timer? timer;
  int seconds = 0;
  int moisture = 0;

  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Retrieve the Plant object from the navigation arguments
    plant = ModalRoute.of(context)?.settings.arguments as Plant?;
    if (plant != null) {
    _fetchMoistureData();
    }
  }

  void toggleWatering() {
    setState(() {
      isWatering = !isWatering;
      if (isWatering) {
        startTimer();
        _updateManualControl(true);

      } else {
        stopTimer();
        _updateManualControl(false);
      }
    });
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        seconds++;
      });
    });
  }

  void stopTimer() {
    timer?.cancel();
    seconds = 0;
  }
  
  Future<void> _updateManualControl(bool value) async {
    try {
      await _databaseReference.child('relay/manuelControl').set(value);
    } catch (e) {
      print('Error updating manual control: $e');
    }
  }
  Future<void> _fetchMoistureData() async {
    try {
      final moistureRef = _databaseReference.child('plant/moisture');
      moistureRef.onValue.listen((event) {
        final double newMoisture = event.snapshot.value as double;
        setState(() {
          moisture = newMoisture.toInt();
        });
        print('Moisture data fetched: $newMoisture');
      });
    } catch (e) {
      print('Error fetching moisture data: $e');
    }
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
            Text('Sağlık Durumu: ${plant!.health}'),
            // Add more fields as necessary
            SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: toggleWatering,
                    child: Text(isWatering ? 'Sulamayı Durdur' : 'Sulamayı Başlat'),
                  ),
                  if (isWatering)
                    Text(
                      'Süre: ${seconds}s',
                      style: TextStyle(fontSize: 18),
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
