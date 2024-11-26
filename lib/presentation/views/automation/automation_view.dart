// lib/views/automation/automation_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/automation_settings.dart';
import '../../../domain/entities/plant.dart';
import '../../view_models/automation_notifier.dart';
import '../../../core/utils/ui_helpers.dart'; // Hata ve başarı mesajları için

class AutomationView extends ConsumerStatefulWidget {
  const AutomationView({super.key});

  @override
  _AutomationViewState createState() => _AutomationViewState();
}

class _AutomationViewState extends ConsumerState<AutomationView> {
  late TextEditingController frequencyController;
  late TextEditingController amountController;
  Plant? plant;

  @override
  void initState() {
    super.initState();
    frequencyController = TextEditingController();
    amountController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final receivedPlant = ModalRoute.of(context)?.settings.arguments as Plant?;
    if (receivedPlant == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Otomasyon için bir bitki seçilmedi.")),
        );
        Navigator.pop(context);
      });
    } else {
      plant = receivedPlant;
      // Bitki seçildiğinde otomasyon ayarlarını fetch et
      final automationNotifier = ref.read(automationProvider.notifier);
      automationNotifier.fetchSettings(plant!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final automationState = ref.watch(automationProvider);

    // Ayarlar yüklendiğinde controller'ları güncelle
    if (automationState.settings != null &&
        frequencyController.text.isEmpty &&
        amountController.text.isEmpty) {
      frequencyController.text = automationState.settings!.frequency.toString();
      amountController.text = automationState.settings!.amount.toString();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(plant?.name ?? "Otomasyon Ayarları"),
      ),
      body: automationState.isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: frequencyController,
                    decoration:
                        InputDecoration(labelText: "Sulama Sıklığı (gün)"),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: amountController,
                    decoration:
                        InputDecoration(labelText: "Sulama Miktarı (ml)"),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      // Girişlerin doğruluğunu kontrol et
                      if (frequencyController.text.isEmpty ||
                          amountController.text.isEmpty) {
                        showErrorMessage(
                            context, "Lütfen tüm alanları doldurun.");
                        return;
                      }

                      int? frequency = int.tryParse(frequencyController.text);
                      int? amount = int.tryParse(amountController.text);

                      if (frequency == null || amount == null) {
                        showErrorMessage(context, "Geçerli sayılar giriniz.");
                        return;
                      }

                      final updatedSettings = AutomationSettings(
                        plantId: plant!.id,
                        frequency: frequency,
                        amount: amount,
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
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    frequencyController.dispose();
    amountController.dispose();
    super.dispose();
  }
}
