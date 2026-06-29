import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_nav.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Variabel untuk toggle antara Login dan Register
  bool isRegister = false;
  final emailController = TextEditingController();
  final passController = TextEditingController();
  final nameController = TextEditingController();

  Future<void> handleAuth() async {
    final prefs = await SharedPreferences.getInstance();

    if (isRegister) {
      // Logika Registrasi
      if (nameController.text.isEmpty ||
          emailController.text.isEmpty ||
          passController.text.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Mohon isi semua data!')));
        return;
      }
      await prefs.setString('user_email', emailController.text);
      await prefs.setString('user_pass', passController.text);
      await prefs.setString('user_name', nameController.text);

      // Setelah daftar, kembali ke mode login
      setState(() => isRegister = false);
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Akun berhasil dibuat! Silakan login.')),
        );
    } else {
      // Logika Login
      String? savedEmail = prefs.getString('user_email');
      String? savedPass = prefs.getString('user_pass');

      if (emailController.text == savedEmail &&
          passController.text == savedPass &&
          savedEmail != null) {
        await prefs.setBool('is_logged_in', true);
        if (mounted)
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainNavigation()),
          );
      } else {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Email atau Password salah!')),
          );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F1F2),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Image.asset('assets/images/logo.jpg', height: 120),
              const SizedBox(height: 20),
              Text(
                isRegister ? "Create Account" : "Sign In",
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Field Nama hanya muncul saat mode Registrasi
              if (isRegister) ...[
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
              ],

              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: passController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 25),

              FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: handleAuth,
                child: Text(isRegister ? 'Register' : 'Log In'),
              ),

              // Tombol untuk pindah mode antara Login dan Register
              TextButton(
                onPressed: () => setState(() => isRegister = !isRegister),
                child: Text(
                  isRegister
                      ? 'Sudah punya akun? Login'
                      : 'Belum punya akun? Register',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
