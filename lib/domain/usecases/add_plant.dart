import '../entities/plant.dart';
import '../interfaces/plant_repository.dart';
import '../../data/datasources/image_service.dart';
import 'dart:io';

class AddPlant {
  final PlantRepository repository;
  final ImageService imageService;

  AddPlant(this.repository, this.imageService);

  Future<void> call(Plant plant, File? imageFile) async {
    String imageUrl = plant.imageUrl;

    // Görsel varsa, yerel depolamaya kaydet
    if (imageFile != null) {
      imageUrl = await imageService.saveImageToLocalStorage(imageFile);
    }

    // Yeni bitki için boş ID ile oluştur
    final newPlant = Plant(
      id: '', // Boş ID ile oluştur, repository yeni ID atayacak
      userId: plant.userId,
      name: plant.name,
      type: plant.type,
      moisture: plant.moisture,
      health: plant.health,
      imageUrl: imageUrl,
    );

    await repository.addPlant(newPlant);
  }
}