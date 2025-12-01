import 'package:flutter/material.dart';
import 'package:client/widgets/custom_card.dart';

class EmployeeAttendanceScreen extends StatelessWidget {
  const EmployeeAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final employees = List.generate(
      6,
      (index) => {"name": "Andi Budi Carmen", "role": "Front-End Developer"},
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ------------------ HEADER ------------------
              const Text(
                "Daftar Kehadiran\nKaryawan",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
              ),

              const SizedBox(height: 6),

              const Text(
                "Daftar kehadiran karyawan\n*hanya admin yang bisa tambah/hapus data",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),

              const SizedBox(height: 20),

              // ------------------ LIST EMPLOYEES ------------------
              Expanded(
                child: ListView.separated(
                  itemCount: employees.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return CustomCard(
                      name: employees[index]["name"]!,
                      position: employees[index]["role"]!,
                      onTap: () {},

                      // Tambahkan ini supaya ikon muncul
                      onInfoTap: () {
                        print("Info diklik untuk ${employees[index]['name']}");
                      }
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
