import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../../../domain/entities/plant.dart';
import '../../widgets/image_picker_widget.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../view_models/plants_notifier.dart';

class AddPlantView extends ConsumerWidget {
  const AddPlantView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final typeController = TextEditingController();
    File? imageFile;

    void onImageSelected(File image) {
      imageFile = image;
    }

    void savePlant() async {
      if (nameController.text.isEmpty || imageFile == null) {
        showErrorMessage(context, "Lütfen bir isim ve görsel seçiniz.");
        return;
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        showErrorMessage(context, "Oturum açmış bir kullanıcı bulunamadı.");
        return;
      }

      final userId = user.uid;

      final notifier = ref.read(plantsProvider.notifier);
      final plant = Plant(
        id: '', // Firestore tarafından otomatik atanacak
        userId: userId, 
        name: nameController.text,
        type: typeController.text,
        imageUrl: '', // Görsel URL'si daha sonra güncellenecek
      );

      await notifier.addNewPlant(plant, imageFile).then((_) {
        showSuccessMessage(context, "Bitki başarıyla eklendi.");
        Navigator.pop(context);
      }).catchError((e) {
        showErrorMessage(context, "Bitki kaydedilirken hata: $e");
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Yeni Bitki Ekle"),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Form fields in Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: "Bitki Adı",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.nature),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: typeController,
                        decoration: InputDecoration(
                          labelText: "Bitki Türü",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.local_florist),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Image Picker Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ImagePickerWidget(
                    onImageSelected: onImageSelected,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Save Button
              ElevatedButton.icon(
                onPressed: savePlant,
                icon: const Icon(Icons.save, color: Colors.white),
                label: const Text(
                  "Bitkiyi Kaydet",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle:
                      const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
