// lib/views/automation/automation_view.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/plant.dart';
import '../../view_models/automation_notifier.dart';
import 'package:firebase_database/firebase_database.dart';

class AutomationView extends ConsumerStatefulWidget {
  const AutomationView({super.key});

  @override
  _AutomationViewState createState() => _AutomationViewState();
}

class _AutomationViewState extends ConsumerState<AutomationView> {
  bool isWatering = false;
  Timer? timer;
  int seconds = 0;
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();
  late TextEditingController frequencyController;
  late TextEditingController amountController;
  late TextEditingController photoFrequencyController;
  bool _automationEnabled = false;
  Plant? plant;
  bool _controllersInitialized = false;

  @override
  void initState() {
    super.initState();
    frequencyController = TextEditingController();
    amountController = TextEditingController();
    photoFrequencyController = TextEditingController();
    _fetchAutomationStatus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final receivedPlant =
          ModalRoute.of(context)?.settings.arguments as Plant?;
      if (receivedPlant != null) {
        setState(() {
          plant = receivedPlant;
        });
        print('AutomationView - Loading settings for plant ID: ${plant!.id}');
        ref.read(automationProvider.notifier).loadSettings(plant!.id);
      } else {
        print('AutomationView - No plant received');
        Navigator.pop(context);
      }
    });
  }

  Future<void> _fetchAutomationStatus() async {
    final DatabaseReference relayRef =
        FirebaseDatabase.instance.ref('relay/automationEnabled');
    final DataSnapshot snapshot = await relayRef.get();
    if (snapshot.exists) {
      setState(() {
        _automationEnabled = snapshot.value as bool;
      });
    }
  }

  Future<void> _updateManualControl(bool value) async {
    try {
      await _databaseReference.child('relay/manuelControl').set(value);
    } catch (e) {
      print('Error updating manual control: $e');
    }
  }

  Future<void> _toggleAutomationStatus() async {
    final DatabaseReference relayRef =
        FirebaseDatabase.instance.ref('relay/automationEnabled');
    await relayRef.set(!_automationEnabled);
    setState(() {
      _automationEnabled = !_automationEnabled;
    });
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
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        seconds++;
      });
    });
  }

  void stopTimer() {
    timer?.cancel();
    seconds = 0;
  }

  void showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          "Bilgi",
          style: TextStyle(color: Colors.black87),
        ),
        content: const Text("Bu sayfada otomasyon kontrol ayarları bulunmaktadır."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tamam"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final automationState = ref.watch(automationProvider);

    if (automationState.settings != null && !_controllersInitialized) {
      frequencyController.text = automationState.settings!.frequency.toString();
      amountController.text = automationState.settings!.amount.toString();
      photoFrequencyController.text =
          automationState.settings!.photoFrequency.toString();
      _controllersInitialized = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(plant?.name ?? "Otomasyon Ayarları"),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.black87),
            onPressed: showInfoDialog,
          )
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Watering Control Card
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: Colors.transparent, // Card rengini şeffaf yapıyoruz
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFB9F6CA), Color(0xFFDCEDC8)], // Açık yeşil tonlar
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Text(
                            "Sulama Kontrol",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white, // updated to white
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: toggleWatering,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.grey, // Yazı ve ikon rengi
                                elevation: 0, // Gölge kaldırma
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 30), // smaller padding
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  side: BorderSide(color: Colors.grey.shade300),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              child: Text(
                                isWatering
                                    ? "Sulamayı Durdur"
                                    : "Sulamayı Başlat",
                                style: const TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          if (isWatering)
                            Padding(
                              padding: const EdgeInsets.only(top: 12.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.timer,
                                    color: Colors.green,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Süre: ${seconds}s',
                                    style: const TextStyle(fontSize: 18, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Automation Settings Card
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: Colors.transparent,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFB9F6CA), Color(0xFFDCEDC8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Text(
                            "Otomasyon Ayarları",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white, // updated to white
                            ),
                          ),
                          const SizedBox(height: 10),
                          SwitchListTile(
                            title: const Text(
                              "Otomasyon Durumu",
                              style: TextStyle(fontSize: 18, color: Colors.white), // updated to white
                            ),
                            activeColor: Colors.green,
                            value: _automationEnabled,
                            onChanged: (value) async {
                              await _toggleAutomationStatus();
                            },
                          ),
                          // Additional settings fields (frequency, amount, photoFrequency) can be displayed here if needed.
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controllersInitialized = false;
    frequencyController.dispose();
    amountController.dispose();
    photoFrequencyController.dispose();
    super.dispose();
  }
}
