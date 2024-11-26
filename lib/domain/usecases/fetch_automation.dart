import '../entities/automation_settings.dart';
import '../interfaces/automation_repository.dart';

class FetchAutomationSettings {
  final AutomationRepository repository;

  FetchAutomationSettings(this.repository);

  Future<AutomationSettings> call(String plantId) {
    return repository.fetchAutomationSettings(plantId);
  }
}
