// lib/views/navigation_bar/navigation_bar.dart
import 'package:flutter/material.dart';
import '../home_page/home_view.dart';
import '../plants/plants_view.dart';
import '../automation/automation_view.dart';
import '../settings/settings_view.dart'; // Ayarlar sayfasını import edin

class MainNavigationBar extends StatefulWidget {
  const MainNavigationBar({super.key});

  @override
  _MainNavigationBarState createState() => _MainNavigationBarState();
}

class _MainNavigationBarState extends State<MainNavigationBar> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomeView(),
    PlantsView(),
    AutomationView(),
    SettingsView(), // Ayarlar sayfasını listeye ekleyin
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // Seçili sayfayı göster
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Ana Sayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grass),
            label: 'Bitkilerim',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_remote),
            label: 'Otomasyon',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Ayarlar',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
