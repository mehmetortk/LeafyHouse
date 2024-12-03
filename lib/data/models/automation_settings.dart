import '../../domain/entities/automation_settings.dart';

class AutomationSettingsModel {
  final String plantId;
  final int frequency;
  final int amount;
  final int photoFrequency;
  AutomationSettingsModel({
    required this.plantId,
    required this.frequency,
    required this.amount,
    required this.photoFrequency,
  });

  factory AutomationSettingsModel.fromFirestore(Map<String, dynamic> data) {
    return AutomationSettingsModel(
      plantId: data['plantId'],
      frequency: data['frequency'],
      amount: data['amount'],
      photoFrequency: data['photoFrequency'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'plantId': plantId,
      'frequency': frequency,
      'amount': amount,
      'photoFrequency': photoFrequency,
    };
  }

  AutomationSettings toEntity() {
    return AutomationSettings(
      plantId: plantId,
      frequency: frequency,
      amount: amount,
      photoFrequency: photoFrequency,
    );
  }

  factory AutomationSettingsModel.fromEntity(AutomationSettings entity) {
    return AutomationSettingsModel(
      plantId: entity.plantId,
      frequency: entity.frequency,
      amount: entity.amount,
      photoFrequency: entity.photoFrequency,
    );
  }
}
