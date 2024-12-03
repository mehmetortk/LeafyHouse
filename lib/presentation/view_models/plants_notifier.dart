import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/plant.dart';
import '../../domain/usecases/fetch_plants.dart';
import '../../domain/usecases/add_plant.dart';
import '../../domain/usecases/delete_plant.dart';
import '../../domain/usecases/update_plant.dart';
import '../../domain/usecases/fetch_plant_by_id.dart';
import '../../core/di/dependency_injection.dart';

class PlantsState {
  final List<Plant> plants;
  final bool isLoading;
  final String? errorMessage;

  PlantsState({
    this.plants = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  PlantsState copyWith({
    List<Plant>? plants,
    bool? isLoading,
    String? errorMessage,
  }) {
    return PlantsState(
      plants: plants ?? this.plants,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class PlantsNotifier extends StateNotifier<PlantsState> {
  final FetchPlants fetchPlants;
  final AddPlant addPlant;
  final DeletePlant deletePlant;
  final UpdatePlant updatePlant;
  final FetchPlantById fetchPlantById;

  PlantsNotifier({
    required this.fetchPlants,
    required this.addPlant,
    required this.deletePlant,
    required this.updatePlant,
    required this.fetchPlantById,
  }) : super(PlantsState());

  Future<void> loadPlants(String userId) async {
    print("Starting loadPlants for userId: $userId");
    try {
      state = state.copyWith(isLoading: true);
      print("Fetching plants...");
      final plants = await fetchPlants(userId);
      print("Plants fetched: $plants");
      state = state.copyWith(plants: plants, isLoading: false);
    } catch (e) {
      print("Error in loadPlants: $e");
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<Plant?> getPlantById(String plantId) async {
    try {
      final plant = await fetchPlantById(plantId);
      return plant;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return null;
    }
  }

  Future<void> addNewPlant(Plant plant, File? imageFile) async {
    // Method yeniden adlandırıldı
    state = state.copyWith(isLoading: true);
    try {
      await addPlant(plant, imageFile); // Use-Case kullanımı
      await loadPlants(plant.userId);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> updateExistingPlant(Plant plant) async {
    state = state.copyWith(isLoading: true);
    try {
      await updatePlant(plant);
      await loadPlants(plant.userId);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> removePlant(String plantId, Plant plant) async {
    state = state.copyWith(isLoading: true);
    try {
      await deletePlant(plantId);
      await loadPlants(plant.userId);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  // Error mesajını temizlemek için yardımcı metot
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

// Provider
final plantsProvider =
    StateNotifierProvider<PlantsNotifier, PlantsState>((ref) {
  final fetchPlants = ref.watch(fetchPlantsProvider);
  final addPlant = ref.watch(addPlantProvider);
  final deletePlant = ref.watch(deletePlantProvider);
  final updatePlant = ref.watch(updatePlantProvider);
  final fetchPlantById = ref.watch(fetchPlantByIdProvider);

  return PlantsNotifier(
    fetchPlants: fetchPlants,
    addPlant: addPlant,
    deletePlant: deletePlant,
    updatePlant: updatePlant,
    fetchPlantById: fetchPlantById,
  );
});
