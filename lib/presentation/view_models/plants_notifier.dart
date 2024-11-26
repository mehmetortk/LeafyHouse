import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/plant.dart';
import '../../domain/usecases/fetch_plants.dart';
import '../../domain/usecases/add_plant.dart';
import '../../domain/usecases/delete_plant.dart';
import '../../domain/usecases/update_plant.dart';
import '../../core/di/dependency_injection.dart';
import '../../domain/usecases/add_plant_with_image.dart';

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
  final AddPlantWithImage addPlantWithImage; // Use-Case olarak tanımlı

  PlantsNotifier({
    required this.fetchPlants,
    required this.addPlant,
    required this.deletePlant,
    required this.updatePlant,
    required this.addPlantWithImage,
  }) : super(PlantsState());

  Future<void> addPlantWithImageFile(Plant plant, File? imageFile) async {
    // Method yeniden adlandırıldı
    state = state.copyWith(isLoading: true);
    try {
      await addPlantWithImage(plant, imageFile); // Use-Case kullanımı
      state = state.copyWith(
        plants: [...state.plants, plant],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

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



  Future<void> addNewPlant(Plant plant) async {
    state = state.copyWith(isLoading: true);
    try {
      await addPlant(plant);
      state =
          state.copyWith(plants: [...state.plants, plant], isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }
}

// Provider
final plantsProvider =
    StateNotifierProvider<PlantsNotifier, PlantsState>((ref) {
  final fetchPlants = ref.watch(fetchPlantsProvider);
  final addPlant = ref.watch(addPlantProvider);
  final deletePlant = ref.watch(deletePlantProvider);
  final updatePlant = ref.watch(updatePlantProvider);
  final addPlantWithImage = ref.watch(addPlantWithImageProvider);

  return PlantsNotifier(
    fetchPlants: fetchPlants,
    addPlant: addPlant,
    deletePlant: deletePlant,
    updatePlant: updatePlant,
    addPlantWithImage: addPlantWithImage, // Yeni Use-Case
  );
});
