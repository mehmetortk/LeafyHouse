import '../../domain/entities/plant.dart';

class PlantModel {
  final String id;
  final String userId;
  final String name;
  final String type;
  final String imageUrl;

  PlantModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.imageUrl,
  });

  // Firestore'dan veri alma
  factory PlantModel.fromFirestore(Map<String, dynamic> data, String id) {
    return PlantModel(
      id: id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? 'Unknown Plant',
      type: data['type'] ?? 'Unknown Type',
      imageUrl: data['imageUrl'] ?? '',
    );
  }

  // Firestore'a veri yazma
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'type': type,
      'imageUrl': imageUrl,
    };
  }

  // Domain katmanına dönüştürme
  Plant toEntity() {
    return Plant(
      id: id,
      userId: userId,
      name: name,
      type: type,
      imageUrl: imageUrl,
    );
  }

  // Domain katmanından dönüşüm
  factory PlantModel.fromEntity(Plant plant) {
    return PlantModel(
      id: plant.id,
      userId: plant.userId,
      name: plant.name,
      type: plant.type,
      imageUrl: plant.imageUrl,
    );
  }
}
