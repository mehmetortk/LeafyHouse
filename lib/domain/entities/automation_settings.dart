class AutomationSettings {
  final String plantId;
  final int frequency; // Sulama sıklığı (gün)
  final int amount; // Sulama miktarı (ml)

  AutomationSettings({
    required this.plantId,
    required this.frequency,
    required this.amount,
  });
}
