import 'package:client/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Admin'),
        backgroundColor: const Color.fromRGBO(29, 97, 231, 1),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.go('/role-selection'),
          tooltip: 'Kembali ke Menu Utama',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Selamat datang, Admin!',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(29, 97, 231, 1),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // Edit Employee Management
            CustomButton(
              backgroundColor: const Color.fromRGBO(29, 97, 231, 1),
              onPressed: () {
                context.push('/admin/employee-list');
              },
              child: const Text(
                'Edit Status, Posisi & Departemen Karyawan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),

            // Manage Positions
            CustomButton(
              backgroundColor: const Color.fromRGBO(29, 97, 231, 1),
              onPressed: () {
                context.push('/admin/positions');
              },
              child: const Text(
                'Kelola Posisi',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Manage Departments
            CustomButton(
              backgroundColor: const Color.fromRGBO(29, 97, 231, 1),
              onPressed: () {
                context.push('/admin/departments');
              },
              child: const Text(
                'Kelola Departemen',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const Spacer(),

            // Footer
            const Text(
              'HRIS System v1.0',
              style: TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
