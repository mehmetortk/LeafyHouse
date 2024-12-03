import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/plant.dart';
import '../models/automation_settings.dart';

abstract class IFirestoreService {
  Future<List<PlantModel>> fetchPlants(String userId);
  Future<void> addPlant(PlantModel plant);
  Future<void> updatePlant(PlantModel plant);
  Future<void> deletePlant(String plantId);
}

class FirestoreService implements IFirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreService(this._firestore);

  @override
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

  Future<PlantModel?> fetchPlantById(String plantId) async {
    try {
      final docSnapshot =
          await _firestore.collection('plants').doc(plantId).get();
      if (docSnapshot.exists) {
        return PlantModel.fromFirestore(docSnapshot.data()!, docSnapshot.id);
      }
      return null;
    } catch (e) {
      throw Exception("Error fetching plant: $e");
    }
  }

  @override
  Future<void> addPlant(PlantModel plant) async {
    try {
      await _firestore.collection('plants').add(plant.toFirestore());
    } catch (e) {
      throw Exception("Error adding plant: $e");
    }
  }

  @override
  Future<void> updatePlant(PlantModel plant) async {
    await _firestore
        .collection('plants')
        .doc(plant.id)
        .update(plant.toFirestore());
  }

  @override
  Future<void> deletePlant(String plantId) async {
    try {
      await _firestore.collection('plants').doc(plantId).delete();
    } catch (e) {
      throw Exception("Error deleting plant: $e");
    }
  }

  // Otomasyon ayarlarını fetch etme
  Future<AutomationSettingsModel> fetchAutomationSettings(
      String plantId) async {
    try {
      print(
          'FirestoreService - Fetching automation settings for plantId: $plantId');

      final doc =
          await _firestore.collection('automation_settings').doc(plantId).get();

      print('FirestoreService - Document exists: ${doc.exists}');

      if (doc.exists) {
        final data = doc.data()!;
        // Ensure we're using the correct plantId
        data['plantId'] = plantId;
        print('FirestoreService - Found settings: $data');
        return AutomationSettingsModel.fromFirestore(data);
      } else {
        print('FirestoreService - No settings found, creating default');
        // Create default settings for this specific plant
        final defaultSettings = AutomationSettingsModel(
          plantId: plantId,
          frequency: 1,
          amount: 100,
          photoFrequency: 24,
        );
        // Save default settings to Firestore
        await updateAutomationSettings(defaultSettings);
        return defaultSettings;
      }
    } catch (e) {
      print('FirestoreService - Error: $e');
      throw Exception("Error fetching automation settings: $e");
    }
  }

  // Otomasyon ayarlarını güncelleme
  Future<void> updateAutomationSettings(
      AutomationSettingsModel settings) async {
    try {
      print('Updating settings for plantId: ${settings.plantId}'); // Debug için

      await _firestore
          .collection('automation_settings')
          .doc(settings.plantId) // Use plantId as document ID
          .set(settings.toFirestore(), SetOptions(merge: true));

      print('Settings updated successfully'); // Debug için
    } catch (e) {
      print('Error updating settings: $e'); // Debug için
      throw Exception("Error updating automation settings: $e");
    }
  }
}
