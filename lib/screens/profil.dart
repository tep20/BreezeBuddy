import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/custom_widgets.dart';
import 'login.dart';
import 'profil_edit.dart'; 
import 'pengaturan.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  _ProfilScreenState createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  String userName = "Tito";
  String userEmail = "tito@email.com";
  String? imagePath;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('user_name') ?? "Tito";
      userEmail = prefs.getString('user_email') ?? "tito@email.com";
      imagePath = prefs.getString('profile_image');
    });
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', false);
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F1F2),
      appBar: AppBar(title: const Text("Profil"), backgroundColor: Colors.transparent),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: imagePath != null ? FileImage(File(imagePath!)) : const AssetImage('assets/images/profile.jpg') as ImageProvider,
            ),
            const SizedBox(height: 20),
            Text(userName, style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(userEmail, style: GoogleFonts.poppins(color: Colors.grey)),
            const SizedBox(height: 30),
            _buildMenuCard(context, icon: Icons.person_outline, title: "Edit Profil", onTap: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfilScreen()));
              _loadUserData(); // Refresh data setelah balik
            }),
            _buildMenuCard(context, icon: Icons.settings, title: "Pengaturan", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PengaturanScreen()))),
            _buildMenuCard(context, icon: Icons.logout, title: "Logout", color: Colors.red, onTap: () => _logout(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, {required IconData icon, required String title, Color? color, required VoidCallback onTap}) {
    return Container(margin: const EdgeInsets.only(bottom: 15), child: NeumorphicContainer(child: ListTile(leading: Icon(icon, color: color ?? Colors.teal), title: Text(title, style: GoogleFonts.poppins(color: color ?? Colors.black87)), trailing: const Icon(Icons.chevron_right), onTap: onTap)));
  }
}