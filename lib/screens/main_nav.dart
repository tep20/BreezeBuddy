import 'package:flutter/material.dart';
import 'dashboard.dart';
import 'jurnal.dart';
import 'statistik.dart';
import 'profil.dart';
import 'audio.dart'; // Pastikan mengimpor file yang benar

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    JurnalScreen(),
    const OceanSoundPlayerScreen(), // Menggunakan kelas yang benar dari audio.dart
    StatistikScreen(),
    const ProfilScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.book), label: 'Jurnal'),
          NavigationDestination(icon: Icon(Icons.music_note), label: 'Audio'),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Statistik'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}