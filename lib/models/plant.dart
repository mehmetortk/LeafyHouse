class Plant {
  final String? id; // Make id nullable
  final String userId;
  final String name;
  final String type;
  final int moisture;
  final String health;

  Plant({
    this.id, // id can be null
    required this.userId,
    required this.name,
    required this.type,
    required this.moisture,
    required this.health,
  });

  // Firestore'dan veri dönüştürme metodu
  factory Plant.fromFirestore(Map<String, dynamic> data, String id) {
    return Plant(
      id: id,
      userId: data['userId'] as String,
      name: data['name'] as String,
      type: data['type'] as String,
      moisture: (data['moisture'] ?? 0) as int, // Default değer kontrolü
      health: data['health'] as String,
    );
  }

  // Firestore'a veri yazma metodu
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'type': type,
      'moisture': moisture,
      'health': health,
    };
  }
}
