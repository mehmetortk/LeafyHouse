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

  AutomationNotifier({
    required this.fetchSettings,
    required this.updateSettings,
  }) : super(AutomationState());

  void clearSettings() {
    print('AutomationNotifier - Clearing settings');
    state = AutomationState();
  }

  Future<void> loadSettings(String plantId) async {
    try {
      print('AutomationNotifier - Loading settings for plant ID: $plantId');
      state = AutomationState(isLoading: true);
      
      final settings = await fetchSettings(plantId);
      print('AutomationNotifier - Received settings: ${settings.frequency}, ${settings.amount}, ${settings.photoFrequency}');
      
      if (mounted) {
        state = AutomationState(
          settings: settings,
          isLoading: false,
        );
      }
    } catch (e) {
      print('AutomationNotifier - Error loading settings: $e');
      if (mounted) {
        state = AutomationState(
          isLoading: false,
          errorMessage: e.toString(),
        );
      }
    }
  }

  Future<void> saveSettings(AutomationSettings settings) async {
    try {
      state = AutomationState(isLoading: true, settings: state.settings);
      await updateSettings(settings);
      state = AutomationState(
        settings: settings,
        isLoading: false,
      );
    } catch (e) {
      state = AutomationState(
        settings: state.settings,
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
