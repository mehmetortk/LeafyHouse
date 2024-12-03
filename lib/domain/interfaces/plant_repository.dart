import '../entities/plant.dart';

abstract class PlantRepository {
  Future<List<Plant>> fetchPlants(String userId);
  Future<void> addPlant(Plant plant);
  Future<void> deletePlant(String plantId);
  Future<void> updatePlant(Plant plant);
  Future<Plant?> fetchPlantById(String plantId); // Add this method

}
