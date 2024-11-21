import 'package:flutter/material.dart';
import 'package:leafy_house/firebase_options.dart';
import 'views/auth/loginView.dart';
import 'views/auth/registerView.dart';
import 'views/homepage/homeView.dart';
import 'views/splash_screen/splashScreenView.dart';
import 'views/plant_details/plantDetailsView.dart';
import 'views/automation/automationView.dart';
import 'views/homepage/addPlantView.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'viewmodels/plants_viewmodel.dart';
import 'views/homepage/plantsView.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PlantsViewModel()),
      ],
      child: MyApp(),),);
}

class MyApp extends StatelessWidget {
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
        '/home': (context) => HomeView(),
        '/addPlant': (context) => AddPlantView(),
        '/plantDetail': (context) => PlantDetailView(),
        '/automation': (context) => AutomationView(),
        '/plants': (context) => PlantsView(),
      },
    );
  }
}
