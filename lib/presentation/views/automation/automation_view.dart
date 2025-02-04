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
        ref.read(automationProvider.notifier).loadSettings(plant!.id);
      } else {
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
        backgroundColor: Theme.of(context).dialogBackgroundColor,
        title: Text(
          "Bilgi",
          style: TextStyle(
              color: Theme.of(context).textTheme.headlineSmall?.color),
        ),
        content: Text(
          "Bu sayfada otomasyon kontrol ayarları bulunmaktadır.",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Tamam",
              style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Theme.of(context).colorScheme.secondary
                      : Colors.green),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final automationState = ref.watch(automationProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (automationState.settings != null && !_controllersInitialized) {
      frequencyController.text =
          automationState.settings!.frequency.toString();
      amountController.text = automationState.settings!.amount.toString();
      photoFrequencyController.text =
          automationState.settings!.photoFrequency.toString();
      _controllersInitialized = true;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor ??
            Theme.of(context).scaffoldBackgroundColor,
        title: Text(plant?.name ?? "Otomasyon Ayarları"),
        actions: [
          IconButton(
            icon: Icon(
              Icons.info_outline,
              color: isDark ? Colors.white : Colors.green[900],
            ),
            onPressed: showInfoDialog,
          )
        ],
      ),
      backgroundColor: isDark ? Colors.black : Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Watering Control Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: isDark
                      ? BorderSide.none
                      : const BorderSide(color: Colors.green, width: 1),
                ),
                color: isDark ? null : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        "Sulama Kontrol",
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Theme.of(context).colorScheme.secondary : Colors.green,
                            ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: toggleWatering,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark
                                ? Theme.of(context).colorScheme.background
                                : Colors.greenAccent,
                            foregroundColor: isDark
                                ? Theme.of(context).textTheme.labelLarge?.color
                                : Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 30),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                              side: isDark
                                  ? BorderSide.none
                                  : const BorderSide(color: Colors.green, width: 1),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          child: Text(
                            isWatering ? "Sulamayı Durdur" : "Sulamayı Başlat",
                          ),
                        ),
                      ),
                      if (isWatering)
                        Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.timer,
                                color: isDark ? Theme.of(context).colorScheme.secondary : Colors.green,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Süre: ${seconds}s',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: isDark ? null : Colors.green[900],
                                    ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Automation Settings Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: isDark
                      ? BorderSide.none
                      : const BorderSide(color: Colors.green, width: 1),
                ),
                color: isDark ? null : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        "Otomasyon Ayarları",
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Theme.of(context).colorScheme.secondary : Colors.green,
                            ),
                      ),
                      const SizedBox(height: 10),
                      SwitchListTile(
                        title: Text(
                          "Otomasyon Durumu",
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: isDark ? Theme.of(context).colorScheme.secondary : Colors.green,
                                fontSize: 18,
                              ),
                        ),
                        activeColor: isDark
                            ? Theme.of(context).colorScheme.secondary
                            : Colors.greenAccent,
                        value: _automationEnabled,
                        onChanged: (value) async {
                          await _toggleAutomationStatus();
                        },
                      ),
                      // Ek ayar alanları eklenebilir.
                    ],
                  ),
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
    _controllersInitialized = false;
    frequencyController.dispose();
    amountController.dispose();
    photoFrequencyController.dispose();
    super.dispose();
  }
}
