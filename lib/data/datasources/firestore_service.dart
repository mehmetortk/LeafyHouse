import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/plant.dart';
import '../models/automation_settings.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Bitkileri fetch etme
  Future<List<PlantModel>> fetchPlants(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('plants')
          .where('userId', isEqualTo: userId)
          .get();

      return querySnapshot.docs.map((doc) {
        return PlantModel.fromFirestore(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      throw Exception("Error fetching plants: $e");
    }
  }

  // Bitki ekleme
  Future<void> addPlant(PlantModel plant) async {
    try {
      await _firestore.collection('plants').add(plant.toFirestore());
    } catch (e) {
      throw Exception("Error adding plant: $e");
    }
  }

  // Bitki güncelleme
  Future<void> updatePlant(PlantModel plant) async {
    await _firestore
        .collection('plants')
        .doc(plant.id)
        .update(plant.toFirestore());
  }

  // Bitki silme
  Future<void> deletePlant(String plantId) async {
    await _firestore.collection('plants').doc(plantId).delete();
  }

  // Otomasyon ayarlarını fetch etme
  Future<AutomationSettingsModel> fetchAutomationSettings(
      String plantId) async {
    final doc =
        await _firestore.collection('automation_settings').doc(plantId).get();
    if (doc.exists) {
      return AutomationSettingsModel.fromFirestore(doc.data()!);
    } else {
      throw Exception("Automation settings not found for plantId: $plantId");
    }
  }

  // Otomasyon ayarlarını güncelleme
  Future<void> updateAutomationSettings(
      AutomationSettingsModel settings) async {
    await _firestore
        .collection('automation_settings')
        .doc(settings.plantId)
        .set(settings.toFirestore());
  }
}
