import '../entities/plant.dart';
import '../interfaces/plant_repository.dart';

class FetchPlantById {
  final PlantRepository repository;

  FetchPlantById(this.repository);

  Future<Plant?> call(String plantId) {
    return repository.fetchPlantById(plantId);
  }
}