import 'package:flutter/material.dart';
import 'package:client/widgets/custom_button.dart';
import 'package:client/widgets/custom_card.dart';

class EmployeeScreen extends StatelessWidget {
  final List<Map<String, String>> employees;

  const EmployeeScreen({super.key, this.employees = const []});

  @override
  Widget build(BuildContext context) {
    final data = employees.isNotEmpty
        ? employees
        : List.generate(
            6,
            (index) => {
              "name": "Andi Budi Carmen",
              "role": "Front-End Developer",
            },
          );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Daftar Karyawan",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Daftar seluruh data karyawan\n*Hanya admin yang bisa tambah/hapus",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    backgroundColor: Colors.blue,
                    child: const Text("Data Baru"),
                    onPressed: () {},
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomButton(
                    backgroundColor: Colors.red,
                    child: const Text("Hapus Akun"),
                    onPressed: () {},
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView.separated(
                itemCount: data.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return CustomCard(
                    name: data[index]['name']!,
                    position: data[index]['role']!,
                    onTap: () {},

                    // Opsional: ganti icon action jadi icon edit
                    actionIcon: Icons.edit,

                    // Tambahkan ini supaya ikon muncul
                    onInfoTap: () {
                      print("Info diklik untuk ${data[index]['name']}");
                    },
                    onActionTap: () {
                      print("Edit diklik untuk ${data[index]['name']}");
                    },

                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
