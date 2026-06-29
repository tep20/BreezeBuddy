import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login.dart';
import 'screens/main_nav.dart';
import 'screens/dashboard.dart';
import 'screens/jurnal.dart';
import 'screens/audio.dart';
import 'screens/statistik.dart';
import 'screens/profil.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Cek status login di SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('is_logged_in') ?? false;

  runApp(BreezeBuddyApp(isLoggedIn: isLoggedIn));
}

class BreezeBuddyApp extends StatelessWidget {
  final bool isLoggedIn;
  const BreezeBuddyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'BreezeBuddy',
          theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal, brightness: Brightness.light),
          darkTheme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal, brightness: Brightness.dark),
          themeMode: currentMode,
          // Arahkan ke MainNavigation jika sudah login, jika belum ke LoginScreen
          home: isLoggedIn ? const MainNavigation() : const LoginScreen(),
        );
      },
    );
  }
}