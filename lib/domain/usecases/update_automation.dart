import '../entities/automation_settings.dart';
import '../interfaces/automation_repository.dart';

class UpdateAutomationSettings {
  final AutomationRepository repository;

  UpdateAutomationSettings(this.repository);

  Future<void> call(AutomationSettings settings) {
    return repository.updateAutomationSettings(settings);
  }
}
