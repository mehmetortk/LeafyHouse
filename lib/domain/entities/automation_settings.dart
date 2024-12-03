class AutomationSettings {
  final String plantId;
  final int frequency; // Sulama sıklığı (gün)
  final int amount; // Sulama miktarı (ml)
  final int photoFrequency; // Fotoğraf çekme sıklığı (gün)
  AutomationSettings({
    required this.plantId,
    required this.frequency,
    required this.amount,
    required this.photoFrequency,
  });
}
