import '../../domain/entities/automation_settings.dart';
import '../../domain/interfaces/automation_repository.dart';
import '../datasources/firestore_service.dart';
import '../models/automation_settings.dart';

class AutomationRepositoryImpl implements AutomationRepository {
  final FirestoreService firestoreService;

  AutomationRepositoryImpl(this.firestoreService);

  @override
  Future<AutomationSettings> fetchAutomationSettings(String plantId) async {
    // Firestore'dan veri al ve domain modeline dönüştür
    final model = await firestoreService.fetchAutomationSettings(plantId);
    return model.toEntity(); // Modelden domain'e dönüşüm
  }

  @override
  Future<void> updateAutomationSettings(AutomationSettings settings) {
    // Domain modelini Firestore için uygun modele dönüştür ve kaydet
    final model = AutomationSettingsModel.fromEntity(settings);
    return firestoreService.updateAutomationSettings(model);
  }
}
