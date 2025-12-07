import 'package:client/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo atau Judul
              const Text(
                'HRIS System',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(29, 97, 231, 1),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Pilih mode akses Anda',
                style: TextStyle(
                  fontSize: 18,
                  color: Color.fromRGBO(108, 114, 120, 1),
                ),
              ),
              const SizedBox(height: 80),

              // Tombol Mode Karyawan
              CustomButton(
                backgroundColor: const Color.fromRGBO(29, 97, 231, 1),
                onPressed: () {
                  context.go('/employee-list');
                },
                child: const Text(
                  'Mode Karyawan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Tombol Mode Admin
              CustomButton(
                backgroundColor: const Color.fromRGBO(29, 97, 231, 1),
                onPressed: () {
                  context.go('/admin-dashboard');
                },
                child: const Text(
                  'Mode Admin',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 50),
              const Text(
                '© 2025 HRIS Company',
                style: TextStyle(
                  color: Color.fromRGBO(108, 114, 120, 1),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
