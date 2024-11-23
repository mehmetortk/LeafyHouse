class Plant {
  final String id;
  final String userId;
  final String name;
  final String type;
  final int moisture;
  final String health;
  final String imageUrl;

  Plant({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.moisture,
    required this.health,
    required this.imageUrl,
  });

  // Firestore'dan veri dönüştürme
  factory Plant.fromFirestore(Map<String, dynamic> data, String id) {
    return Plant(
      id: id,
      userId: data['userId'] ?? '', // Varsayılan boş string
      name: data['name'] ?? 'Bilinmeyen Bitki', // Varsayılan ad
      type: data['type'] ?? 'Bilinmeyen Tür', // Varsayılan tür
      moisture: data['moisture'] ?? 0, // Varsayılan nem oranı
      health: data['health'] ?? 'Bilinmiyor', // Varsayılan sağlık durumu
      imageUrl: data['imageUrl'] ?? '', // Varsayılan boş string
    );
  }

  // Firestore'a veri yazma
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'type': type,
      'moisture': moisture,
      'health': health,
      'imageUrl': imageUrl,
    };
  }
}
