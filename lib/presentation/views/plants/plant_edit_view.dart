import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leafy_house/core/di/dependency_injection.dart';
import 'dart:io';
import '../../../domain/entities/plant.dart';
import '../../view_models/plants_notifier.dart';
import '../../widgets/image_picker_widget.dart';
import '../../../core/utils/ui_helpers.dart';

class PlantEditView extends ConsumerStatefulWidget {
  const PlantEditView({super.key});

  @override
  _PlantEditViewState createState() => _PlantEditViewState();
}

class _PlantEditViewState extends ConsumerState<PlantEditView> {
  late TextEditingController nameController;
  late TextEditingController typeController;
  late Plant plant;
  File? _imageFile;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    plant = ModalRoute.of(context)!.settings.arguments as Plant;
    nameController = TextEditingController(text: plant.name);
    typeController = TextEditingController(text: plant.type);
    _imageFile = plant.imageUrl.isNotEmpty ? File(plant.imageUrl) : null;
  }

  void _onImageSelected(File image) {
    setState(() {
      _imageFile = image;
    });
  }

  void saveChanges() async {
    if (nameController.text.isEmpty) {
      showErrorMessage(context, "Bitki adını boş bırakamazsınız.");
      return;
    }

    try {
      String? newImageUrl;
      if (_imageFile != null) {
        // Yeni bir görsel seçildiyse, önce storage'a yükle
        final imageService = ref.read(imageServiceProvider);
        newImageUrl = await imageService.saveImageToLocalStorage(_imageFile!);
      }

      final updatedPlant = Plant(
        id: plant.id,
        userId: plant.userId,
        name: nameController.text,
        type: typeController.text,
        imageUrl: newImageUrl ?? plant.imageUrl,
      );

      await ref.read(plantsProvider.notifier).updateExistingPlant(updatedPlant);

      showSuccessMessage(context, "Bitki başarıyla güncellendi.");
      Navigator.pop(context, updatedPlant);
    } catch (e) {
      showErrorMessage(context, "Bitki güncellenirken bir hata oluştu: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${plant.name} Düzenle"),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: saveChanges,
            tooltip: "Değişiklikleri Kaydet",
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Image Picker Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ImagePickerWidget(
                    onImageSelected: _onImageSelected,
                    initialImage: _imageFile,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Form fields in a styled container
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
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
              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: saveChanges,
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: const Text(
                    "Bitkiyi Kaydet",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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

  @override
  void dispose() {
    nameController.dispose();
    typeController.dispose();
    super.dispose();
  }
}
