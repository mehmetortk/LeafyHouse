import 'package:flutter/material.dart';
import '../models/plant.dart';
import '../services/firestore_service.dart';

class PlantsViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<Plant> _plants = [];

  List<Plant> get plants => _plants;

  Future<void> fetchPlants(String userId) async {
    _plants = await _firestoreService.fetchPlants(userId);
    notifyListeners();
  }

  Future<void> addPlant(Plant plant) async {
    final newPlant = await _firestoreService.addPlant(plant);
    _plants.add(newPlant);
    notifyListeners();
  }

  Future<void> deletePlant(String plantId) async {
    await _firestoreService.deletePlant(plantId);
    _plants.removeWhere((plant) => plant.id == plantId);
    notifyListeners();
  }

  Future<void> updatePlant(Plant plant) async {
    await _firestoreService.updatePlant(plant);
    final index = _plants.indexWhere((p) => p.id == plant.id);
    if (index != -1) {
      _plants[index] = plant;
      notifyListeners();
    }
  }
}
