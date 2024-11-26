import '../entities/plant.dart';
import '../interfaces/plant_repository.dart';

class UpdatePlant {
  final PlantRepository repository;

  UpdatePlant(this.repository);

  Future<void> call(Plant plant) {
    return repository.updatePlant(plant);
  }
}
