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
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor ??
            Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: isDark ? Colors.black : Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Form Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: isDark 
                      ? BorderSide.none 
                      : BorderSide(color: Colors.green.shade200, width: 1),
                ),
                color: isDark ? Colors.grey[850] : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Bitki Bilgileri",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.green[900],
                        ),
                        textAlign: TextAlign.center, // Add this
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: nameController,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        decoration: InputDecoration(
                          labelText: "Bitki Adı",
                          labelStyle: TextStyle(
                            color: isDark ? Colors.white70 : Colors.green[700],
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark ? Colors.white30 : Colors.green.shade200,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark ? Colors.greenAccent : Colors.green,
                              width: 2,
                            ),
                          ),
                          prefixIcon: Icon(
                            Icons.nature,
                            color: isDark ? Colors.white70 : Colors.green[700],
                          ),
                          filled: true,
                          fillColor: isDark ? Colors.grey[800] : Colors.grey[50],
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: typeController,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        decoration: InputDecoration(
                          labelText: "Bitki Türü",
                          labelStyle: TextStyle(
                            color: isDark ? Colors.white70 : Colors.green[700],
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark ? Colors.white30 : Colors.green.shade200,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark ? Colors.greenAccent : Colors.green,
                              width: 2,
                            ),
                          ),
                          prefixIcon: Icon(
                            Icons.local_florist,
                            color: isDark ? Colors.white70 : Colors.green[700],
                          ),
                          filled: true,
                          fillColor: isDark ? Colors.grey[800] : Colors.grey[50],
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
                  side: isDark 
                      ? BorderSide.none 
                      : BorderSide(color: Colors.green.shade200, width: 1),
                ),
                color: isDark ? Colors.grey[850] : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center( // Add this
                        child: Text(
                          "Bitki Görseli",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.green[900],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center( // Add this
                        child: ImagePickerWidget(
                          onImageSelected: onImageSelected,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Save Button with Gradient
              Container(
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: isDark 
                        ? [Colors.green, Colors.green.shade700]
                        : [Colors.green.shade400, Colors.green.shade700],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () => savePlant(),
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: const Text(
                    "Bitkiyi Kaydet",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
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
