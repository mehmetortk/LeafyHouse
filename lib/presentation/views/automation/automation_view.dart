// lib/views/automation/automation_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/automation_settings.dart';
import '../../../domain/entities/plant.dart';
import '../../view_models/automation_notifier.dart';
import '../../../core/utils/ui_helpers.dart';
import 'package:firebase_database/firebase_database.dart';

class AutomationView extends ConsumerStatefulWidget {
  const AutomationView({super.key});

  @override
  _AutomationViewState createState() => _AutomationViewState();
}

class _AutomationViewState extends ConsumerState<AutomationView> {
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

  Future<void> _toggleAutomationStatus() async {
    final DatabaseReference relayRef =
        FirebaseDatabase.instance.ref('relay/automationEnabled');
    await relayRef.set(!_automationEnabled);
    setState(() {
      _automationEnabled = !_automationEnabled;
    });
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
                    TextField(
                      controller: frequencyController,
                      decoration: const InputDecoration(
                          labelText: "Sulama Sıklığı (gün)"),
                      keyboardType: TextInputType.number,
                      onChanged: (value) =>
                          setState(() {}), // TextField değişimini takip et
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: amountController,
                      decoration: const InputDecoration(
                          labelText: "Sulama Miktarı (ml)"),
                      keyboardType: TextInputType.number,
                      onChanged: (value) =>
                          setState(() {}), // TextField değişimini takip et
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: photoFrequencyController,
                      decoration: const InputDecoration(
                          labelText: "Fotoğraf Çekme Sıklığı (saat)"),
                      keyboardType: TextInputType.number,
                      onChanged: (value) =>
                          setState(() {}), // TextField değişimini takip et
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        // Girişlerin doğruluğunu kontrol et
                        if (frequencyController.text.isEmpty ||
                            amountController.text.isEmpty ||
                            photoFrequencyController.text.isEmpty) {
                          showErrorMessage(
                              context, "Lütfen tüm alanları doldurun.");
                          return;
                        }

                        int? frequency = int.tryParse(frequencyController.text);
                        int? amount = int.tryParse(amountController.text);
                        int? photoFrequency =
                            int.tryParse(photoFrequencyController.text);

                        if (frequency == null ||
                            amount == null ||
                            photoFrequency == null) {
                          showErrorMessage(context, "Geçerli sayılar giriniz.");
                          return;
                        }

                        final updatedSettings = AutomationSettings(
                          plantId: plant!.id,
                          frequency: frequency,
                          amount: amount,
                          photoFrequency: photoFrequency,
                        );

                        await ref
                            .read(automationProvider.notifier)
                            .saveSettings(updatedSettings);

                        // Güncellenmiş state'i okuyarak kontrol et
                        final updatedState = ref.read(automationProvider);

                        if (updatedState.errorMessage != null) {
                          showErrorMessage(context,
                              "Ayarlar kaydedilirken bir hata oluştu: ${updatedState.errorMessage}");
                        } else {
                          showSuccessMessage(
                              context, "Ayarlar başarıyla kaydedildi!");
                          Navigator.pop(context);
                        }
                      },
                      child: Text("Kaydet"),
                    ),
                    const SizedBox(height: 10), // Add some spacing
                    ElevatedButton(
                      onPressed: _toggleAutomationStatus,
                      child: Text(_automationEnabled
                          ? "Otomasyonu durdur"
                          : "Otomasyonu aktif et"),
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
