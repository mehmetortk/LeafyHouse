import '../../domain/entities/plant.dart';
import '../../domain/interfaces/plant_repository.dart';
import '../datasources/firestore_service.dart';
import '../models/plant.dart';

class PlantRepositoryImpl implements PlantRepository {
  final FirestoreService firestoreService;

  PlantRepositoryImpl(this.firestoreService);

  @override
  Future<List<Plant>> fetchPlants(String userId) async {
    try {
      final querySnapshot = await firestoreService.fetchPlants(userId);
      return querySnapshot.map((model) => model.toEntity()).toList();
    } catch (e) {
      print("Error in fetchPlants: $e");
      throw Exception("Error fetching plants: $e");
    }
  }

  @override
  Future<Plant?> fetchPlantById(String plantId) async {
    try {
      final plantModel = await firestoreService.fetchPlantById(plantId);
      return plantModel?.toEntity();
    } catch (e) {
      throw Exception("Error fetching plant: $e");
    }
  }

  @override
  Future<void> addPlant(Plant plant) {
    // Domain entity'sini modele dönüştür ve Firestore'a gönder
    final model = PlantModel.fromEntity(plant);
    return firestoreService.addPlant(model);
  }

  @override
  Future<void> updatePlant(Plant plant) {
    // Domain entity'sini modele dönüştür ve Firestore'da güncelle
    final model = PlantModel.fromEntity(plant);
    return firestoreService.updatePlant(model);
  }

  @override
  Future<void> deletePlant(String plantId) {
    return firestoreService.deletePlant(plantId);
  }
}
