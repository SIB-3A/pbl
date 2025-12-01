import 'dart:ffi';

import 'package:client/models/employee_model.dart';
import 'package:client/models/user_model.dart';
import 'package:client/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:client/widgets/custom_button.dart';
import 'package:client/widgets/custom_card.dart';
import 'package:go_router/go_router.dart';

class EmployeeScreen extends StatelessWidget {
  const EmployeeScreen({super.key});

  Widget employee(
    BuildContext context,
    List<UserModel<EmployeeModel>> employees,
  ) {
    return Padding(
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
              itemCount: employees.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return CustomCard(
                  name:
                      "${employees[index].employee?.firstName} ${employees[index].employee?.lastName}",
                  position: "Ini itu role",
                  onTap: () {},

                  // Opsional: ganti icon action jadi icon edit
                  actionIcon: Icons.edit,

                  // Tambahkan ini supaya ikon muncul
                  onInfoTap: () {
                    context.push(
                      "/admin/profile-detail",
                      extra: employees[index].id,
                    );
                  },
                  onActionTap: () {
                    print("Edit diklik untuk");
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
      body: FutureBuilder(
        future: UserService.instance.getUsers(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return employee(
            context,
            snapshot.data?.data as List<UserModel<EmployeeModel>>,
          );
        },
      ),
    );
  }
}
