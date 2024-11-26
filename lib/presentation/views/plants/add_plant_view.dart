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

      // Kullanıcı ID'sini alın
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        showErrorMessage(context, "Oturum açmış bir kullanıcı bulunamadı.");
        return;
      }

      final userId = user.uid; // Firebase'den kullanıcı ID'sini çekiyoruz

      final notifier = ref.read(plantsProvider.notifier);
      final plant = Plant(
        id: '', // Firestore tarafından otomatik atanacak
        userId: userId, // Kullanıcı ID'sini buraya ekliyoruz
        name: nameController.text,
        type: typeController.text,
        moisture: 0, // Varsayılan değer
        health: 'Sağlıklı', // Varsayılan değer
        imageUrl: '', // Görsel URL'si daha sonra güncellenecek
      );

      await notifier.addPlantWithImageFile(plant, imageFile).then((_) {
        showSuccessMessage(context, "Bitki başarıyla eklendi.");
        Navigator.pop(context);
      }).catchError((e) {
        showErrorMessage(context, "Bitki kaydedilirken hata: $e");
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Yeni Bitki Ekle")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Bitki Adı"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: typeController,
                decoration: const InputDecoration(labelText: "Bitki Türü"),
              ),
              const SizedBox(height: 10),
              ImagePickerWidget(
                onImageSelected: onImageSelected,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: savePlant,
                child: const Text("Bitkiyi Kaydet"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
