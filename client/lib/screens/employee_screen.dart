import 'package:client/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:client/widgets/custom_button.dart';
import 'package:client/widgets/custom_card.dart';
import 'package:go_router/go_router.dart';

class EmployeeScreen extends StatelessWidget {
  const EmployeeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF22A9D6),
      body: Column(
        children: [
          // ===================== HEADER BIRU =====================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
            decoration: const BoxDecoration(
              color: Color(0xFF22A9D6),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Daftar\nKaryawan",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Daftar seluruh data karyawan \n*Hanya admin yang bisa menambah data",
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Image.asset('assets/logoPbl.png', width: 50, height: 50),
              ],
            ),
          ),

          // ===================== KONTEN =====================
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 30, 16, 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: FutureBuilder(
                future: UserService.instance.getUsers(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        "Gagal memuat data karyawan",
                        style: TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  final employees = snapshot.data?.data;

                  if (employees == null || employees.isEmpty) {
                    return Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: CustomButton(
                            backgroundColor: const Color(0xFF22A9D6),
                            child: const Text(
                              "Tambah Data Karyawan",
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: () {
                              context.push("/admin/register");
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Expanded(
                          child: Center(
                            child: Text(
                              "Belum ada data karyawan",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      // Tombol tambah data
                      SizedBox(
                        width: double.infinity,
                        child: CustomButton(
                          backgroundColor: const Color(0xFF22A9D6),
                          child: const Text(
                            "Tambah Data Karyawan",
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            context.push("/admin/register");
                          },
                        ),
                      ),

                      const SizedBox(height: 20),

                      // List Karyawan
                      Expanded(
                        child: ListView.separated(
                          itemCount: employees.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final user = employees[index];

                            final fullName =
                                "${user.employee?.firstName ?? ''} ${user.employee?.lastName ?? ''}"
                                    .trim();

                            // ✅ FIX: Ambil name dari PositionModel
                            final positionName = user.employee?.position?.name;

                            return CustomCard(
                              name: fullName.isEmpty ? "Tanpa Nama" : fullName,
                              position:
                                  positionName, // ✅ Pass String, bukan PositionModel
                              onTap: () {
                                // kalau mau detail di tap card utama
                                context.push(
                                  "/admin/profile-detail",
                                  extra: user.id,
                                );
                              },
                              actionIcon: Icons.edit,
                              onActionTap: () {
                                // Aksi edit (nanti bisa diarahkan ke halaman edit user)
                                debugPrint("Edit diklik untuk ${user.id}");
                              },
                              onInfoTap: () {
                                context.push(
                                  "/admin/profile-detail",
                                  extra: user.id,
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
