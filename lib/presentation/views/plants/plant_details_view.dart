// lib/views/plant_details/plant_details_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../../../domain/entities/plant.dart';
import '../../view_models/plants_notifier.dart';
import '../../widgets/image_picker_widget.dart';
import '../../../core/utils/ui_helpers.dart';

class PlantDetailView extends ConsumerStatefulWidget {
  const PlantDetailView({super.key});

  @override
  _PlantDetailViewState createState() => _PlantDetailViewState();
}

class _PlantDetailViewState extends ConsumerState<PlantDetailView> {
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
    _imageFile = image;
  }

  void saveChanges() async {
    if (nameController.text.isEmpty) {
      showErrorMessage(context, "Bitki adını boş bırakamazsınız.");
      return;
    }

    try {
      final updatedPlant = Plant(
        id: plant.id,
        userId: plant.userId,
        name: nameController.text,
        type: typeController.text,
        moisture: plant.moisture,
        health: plant.health,
        imageUrl: plant.imageUrl, // Görsel kaydedildikten sonra güncellenecek
      );

      await ref.read(plantsProvider.notifier).addPlantWithImage(
            updatedPlant,
            _imageFile,
          );

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
        title: Text("${plant.name} Detayları"),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: saveChanges,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              ImagePickerWidget(
                onImageSelected: _onImageSelected,
                initialImage: _imageFile,
              ),
              SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Bitki Adı"),
              ),
              SizedBox(height: 10),
              TextField(
                controller: typeController,
                decoration: InputDecoration(labelText: "Bitki Türü"),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: saveChanges,
                child: Text("Değişiklikleri Kaydet"),
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
