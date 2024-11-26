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
import 'presentation/views/plants/plant_details_view.dart';
import 'presentation/views/automation/automation_view.dart';
import 'presentation/views/settings/settings_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Leafy House',
      theme: ThemeData(primarySwatch: Colors.green),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/login': (context) => LoginView(),
        '/register': (context) => RegisterView(),
        '/home': (context) => MainNavigationBar(),
        '/addPlant': (context) => AddPlantView(),
        '/plantDetail': (context) => PlantDetailView(),
        '/automation': (context) => AutomationView(),
        '/plants': (context) => PlantsView(),
        '/settings': (context) => SettingsView(),
      },
    );
  }
}
