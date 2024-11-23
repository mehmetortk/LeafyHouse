import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/plant.dart';
import '../models/automation_settings.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Plant>> fetchPlants(String userId) async {
    final querySnapshot = await _firestore
        .collection('plants')
        .where('userId', isEqualTo: userId)
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>; // Firestore'dan gelen veri
      return Plant.fromFirestore(data, doc.id); // Veri modeli dönüştürme
    }).toList();
  }

  Future<Plant> addPlant(Plant plant) async {
    final docRef =
        await _firestore.collection('plants').add(plant.toFirestore());
    final id = docRef.id;
    return Plant(
      id: id,
      userId: plant.userId,
      name: plant.name,
      type: plant.type,
      moisture: plant.moisture,
      health: plant.health,
      imageUrl: plant.imageUrl,
    );
  }

  Future<AutomationSettings?> getAutomationSettings(String plantId) async {
    try {
      final doc =
          await _firestore.collection('automationSettings').doc(plantId).get();
      if (doc.exists) {
        return AutomationSettings.fromFirestore(doc.data()!);
      } else {
        return null;
      }
    } catch (e) {
      print("AutomationSettings alırken hata: $e");
      return null;
    }
  }

  Future<void> saveAutomationSettings(AutomationSettings settings) async {
    try {
      await _firestore
          .collection('automationSettings')
          .doc(settings.plantId)
          .set(settings.toFirestore());
    } catch (e) {
      print("AutomationSettings kaydederken hata: $e");
      throw e; // Hatanın üst katmanlarda da yakalanmasını sağlamak için yeniden fırlat
    }
  }

  Future<void> deletePlant(String plantId) async {
    await _firestore.collection('plants').doc(plantId).delete();
  }

  Future<void> updatePlant(Plant plant) async {
    await _firestore
        .collection('plants')
        .doc(plant.id)
        .update(plant.toFirestore());
  }

  Future<void> updateAutomationSettings(AutomationSettings settings) async {
    await _firestore
        .collection('automationSettings')
        .doc(settings.plantId)
        .update(settings.toFirestore());
  }
}
