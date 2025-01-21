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

  // Added watering-related functions
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

  @override
  Widget build(BuildContext context) {
    final automationState = ref.watch(automationProvider);

    // Sadece bir kez controller'ları güncelle
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
      ),
      body: automationState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              // Klavye açıldığında overflow olmaması için
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: toggleWatering,
                        child: Text(
                            isWatering ? 'Sulamayı Durdur' : 'Sulamayı Başlat'),
                      ),
                    ),
                    if (isWatering)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Text(
                          'Süre: ${seconds}s',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _toggleAutomationStatus,
                        child: Text(_automationEnabled
                            ? "Otomasyonu Durdur"
                            : "Otomasyonu Aktif Et"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _controllersInitialized = false; // Reset the flag
    frequencyController.dispose();
    amountController.dispose();
    photoFrequencyController.dispose();
    super.dispose();
  }
}
