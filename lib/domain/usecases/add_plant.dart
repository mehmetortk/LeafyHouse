import '../entities/plant.dart';
import '../interfaces/plant_repository.dart';

class AddPlant {
  final PlantRepository repository;

  AddPlant(this.repository);

  Future<void> call(Plant plant) {
    return repository.addPlant(plant);
  }
}
