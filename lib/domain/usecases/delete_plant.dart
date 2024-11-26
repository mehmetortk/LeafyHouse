import '../interfaces/plant_repository.dart';

class DeletePlant {
  final PlantRepository repository;

  DeletePlant(this.repository);

  Future<void> call(String plantId) {
    return repository.deletePlant(plantId);
  }
}
