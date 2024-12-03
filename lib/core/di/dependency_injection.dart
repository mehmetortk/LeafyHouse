import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/datasources/firestore_service.dart';
import '../../data/datasources/image_service.dart';
import '../../data/repositories/plant_repository_impl.dart';
import '../../data/repositories/automation_repository_impl.dart';
import '../../domain/interfaces/plant_repository.dart';
import '../../domain/interfaces/automation_repository.dart';
import '../../domain/usecases/fetch_plants.dart';
import '../../domain/usecases/add_plant.dart';
import '../../domain/usecases/fetch_automation.dart';
import '../../domain/usecases/update_automation.dart';
import '../../domain/usecases/delete_plant.dart';
import '../../domain/usecases/update_plant.dart';
import '../../domain/usecases/fetch_plant_by_id.dart';

// Firestore Service Provider
final firestoreServiceProvider = Provider((ref) => FirestoreService(FirebaseFirestore.instance));

// Image Service Provider
final imageServiceProvider = Provider((ref) => ImageService());

// Plant Repository Provider
final plantRepositoryProvider = Provider<PlantRepository>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return PlantRepositoryImpl(firestoreService);
});

// Automation Repository Provider
final automationRepositoryProvider = Provider<AutomationRepository>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return AutomationRepositoryImpl(firestoreService);
});

// UseCase Providers for Plants
final fetchPlantsProvider = Provider((ref) {
  final repository = ref.watch(plantRepositoryProvider);
  return FetchPlants(repository);
});
final fetchPlantByIdProvider = Provider((ref) {
  final repository = ref.watch(plantRepositoryProvider);
  return FetchPlantById(repository);
});
final addPlantProvider = Provider((ref) {
  final repository = ref.watch(plantRepositoryProvider);
  final imageService = ref.watch(imageServiceProvider);
  return AddPlant(repository, imageService);
});

final deletePlantProvider = Provider((ref) {
  final repository = ref.watch(plantRepositoryProvider);
  return DeletePlant(repository);
});

final updatePlantProvider = Provider((ref) {
  final repository = ref.watch(plantRepositoryProvider);
  return UpdatePlant(repository);
});

// UseCase Providers for Automation Settings
final fetchAutomationSettingsProvider = Provider((ref) {
  final repository = ref.watch(automationRepositoryProvider);
  return FetchAutomationSettings(repository);
});

final updateAutomationSettingsProvider = Provider((ref) {
  final repository = ref.watch(automationRepositoryProvider);
  return UpdateAutomationSettings(repository);
});
