import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Simulasi loading 3 detik
    Future.delayed(const Duration(seconds: 3), () {
      // Cek kondisi login di sini (nanti bisa diganti logic asli)
      bool isLoggedIn = false;

      if (isLoggedIn) {
        // Jika sudah login, lempar ke Home
        if (mounted) context.go('/');
      } else {
        // Jika belum login, lempar ke Login
        if (mounted) context.go('/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logoo.png', width: 2500),
            const SizedBox(height: 25),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
