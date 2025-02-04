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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${plant.name} Düzenle",
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor ??
            Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: isDark ? Colors.black : Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        ImagePickerWidget(
                          onImageSelected: _onImageSelected,
                          initialImage: _imageFile,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
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
                    onPressed: saveChanges,
                    icon: const Icon(Icons.save, color: Colors.white),
                    label: const Text(
                      "Değişiklikleri Kaydet",
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
