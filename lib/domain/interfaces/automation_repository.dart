import '../entities/automation_settings.dart';

abstract class AutomationRepository {
  Future<AutomationSettings> fetchAutomationSettings(String plantId);
  Future<void> updateAutomationSettings(AutomationSettings settings);
}
