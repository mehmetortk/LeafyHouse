import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leafy_house/core/di/dependency_injection.dart';
import '../../domain/entities/automation_settings.dart';
import '../../domain/usecases/fetch_automation.dart';
import '../../domain/usecases/update_automation.dart';

class AutomationState {
  final AutomationSettings? settings;
  final bool isLoading;
  final String? errorMessage;

  AutomationState({
    this.settings,
    this.isLoading = false,
    this.errorMessage,
  });

  AutomationState copyWith({
    AutomationSettings? settings,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AutomationState(
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class AutomationNotifier extends StateNotifier<AutomationState> {
  final FetchAutomationSettings fetchSettings;
  final UpdateAutomationSettings updateSettings;

  AutomationNotifier(
      {required this.fetchSettings, required this.updateSettings})
      : super(AutomationState());

  Future<void> loadSettings(String plantId) async {
    state = state.copyWith(isLoading: true);
    try {
      final settings = await fetchSettings(plantId);
      state = state.copyWith(settings: settings, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> saveSettings(AutomationSettings settings) async {
    state = state.copyWith(isLoading: true);
    try {
      await updateSettings(settings);
      state = state.copyWith(settings: settings, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }
}

// Provider
final automationProvider =
    StateNotifierProvider<AutomationNotifier, AutomationState>((ref) {
  final fetchSettings = ref.watch(fetchAutomationSettingsProvider);
  final updateSettings = ref.watch(updateAutomationSettingsProvider);
  return AutomationNotifier(
      fetchSettings: fetchSettings, updateSettings: updateSettings);
});
