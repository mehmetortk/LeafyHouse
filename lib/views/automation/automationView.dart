import 'package:flutter/material.dart';
import '../../models/automation_settings.dart';
import '../../models/plant.dart';
import '../../services/firestore_service.dart';

class AutomationView extends StatefulWidget {
  @override
  _AutomationViewState createState() => _AutomationViewState();
}

class _AutomationViewState extends State<AutomationView> {
  late TextEditingController frequencyController;
  late TextEditingController amountController;
  late Plant plant;
  AutomationSettings? settings;
  bool isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    plant = ModalRoute.of(context)!.settings.arguments as Plant;
    fetchAutomationSettings();
  }

  void fetchAutomationSettings() async {
    try {
      // FirestoreService üzerinden AutomationSettings verisini al
      settings = await FirestoreService().getAutomationSettings(plant.id!);
      if (settings == null) {
        // Eğer ayarlar mevcut değilse, varsayılan ayarlar oluştur
        settings = AutomationSettings(
          plantId: plant.id!,
          frequency: 1, // Varsayılan sulama sıklığı (gün)
          amount: 100,   // Varsayılan sulama miktarı (ml)
        );
        // Oluşturulan varsayılan ayarları Firestore'a kaydet
        await FirestoreService().saveAutomationSettings(settings!);
      }
      // Controller'ları ayarlarla başlat
      frequencyController = TextEditingController(text: settings!.frequency.toString());
      amountController = TextEditingController(text: settings!.amount.toString());
    } catch (e) {
      // Hata durumunda kullanıcıyı bilgilendirin
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Otomasyon ayarları alınırken bir hata oluştu: $e")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void saveChanges() async {
    try {
      final updatedSettings = AutomationSettings(
        plantId: plant.id!,
        frequency: int.parse(frequencyController.text),
        amount: int.parse(amountController.text),
      );
      await FirestoreService().saveAutomationSettings(updatedSettings);
      Navigator.pop(context, updatedSettings);
    } catch (e) {
      // Hata durumunda kullanıcıyı bilgilendirin
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ayarlar kaydedilirken bir hata oluştu: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Otomasyon Ayarları"),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: frequencyController,
                    decoration: InputDecoration(labelText: "Sulama Sıklığı (gün)"),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: amountController,
                    decoration: InputDecoration(labelText: "Sulama Miktarı (ml)"),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: saveChanges,
                    child: Text("Kaydet"),
                  ),
                ],
              ),
            ),
    );
  }
}
