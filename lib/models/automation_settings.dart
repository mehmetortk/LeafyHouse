class AutomationSettings {
  final String plantId;
  final int frequency; // Sulama sıklığı (gün)
  final int amount;    // Sulama miktarı (ml)

  AutomationSettings({
    required this.plantId,
    required this.frequency,
    required this.amount,
  });

  // Firestore'dan veri dönüştürme metodu
  factory AutomationSettings.fromFirestore(Map<String, dynamic> data) {
    return AutomationSettings(
      plantId: data['plantId'] as String,
      frequency: data['frequency'] as int,
      amount: data['amount'] as int,
    );
  }

  // Firestore'a veri yazma metodu
  Map<String, dynamic> toFirestore() {
    return {
      'plantId': plantId,
      'frequency': frequency,
      'amount': amount,
    };
  }
}
