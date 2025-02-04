// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'presentation/views/splash_screen/splash_screen_view.dart';
import 'presentation/views/auth/login_view.dart';
import 'presentation/views/auth/register_view.dart';
import 'presentation/views/navigation_bar/navigation_bar.dart';
import 'presentation/views/plants/plants_view.dart';
import 'presentation/views/plants/add_plant_view.dart';
import 'presentation/views/plants/plant_edit_view.dart';
import 'presentation/views/plants/plant_info_details_view.dart';
import 'presentation/views/automation/automation_view.dart';
import 'presentation/views/settings/settings_view.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'presentation/providers/theme_provider.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("FCM Arka Plan Mesajı: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  final fcm = FirebaseMessaging.instance;
  await fcm.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  await fcm.subscribeToTopic('imageUploads');

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final currentTheme = isDark ? themeNotifier.darkTheme : themeNotifier.lightTheme;
    return MaterialApp(
      theme: currentTheme,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => LoginView(),
        '/register': (context) => RegisterView(),
        '/home': (context) => MainNavigationBar(),
        '/addPlant': (context) => AddPlantView(),
        '/plantEdit': (context) => PlantEditView(),
        '/automation': (context) => AutomationView(),
        '/plants': (context) => PlantsView(),
        '/settings': (context) => SettingsView(),
        '/plantInfoDetails': (context) => PlantInfoDetailsView(),
      },
    );
  }
}
