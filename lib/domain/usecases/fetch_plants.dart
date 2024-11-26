import '../entities/plant.dart';
import '../interfaces/plant_repository.dart';

class FetchPlants {
  final PlantRepository repository;

  FetchPlants(this.repository);

  Future<List<Plant>> call(String userId) {
    return repository.fetchPlants(userId);
  }
}
