import 'package:client/services/auth_service.dart';
import 'package:client/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: "Informasi Profil"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Data diri pegawai",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),

            const SizedBox(height: 16),

            // Form fields
            const _ProfileField(title: "Nama Awal", value: "John"),
            const _ProfileField(title: "Nama Akhir", value: "Doe"),
            const _ProfileField(title: "Email", value: "JohnDoe@gmail.com"),
            const _ProfileField(title: "Jenis Kelamin", value: "Pria"),
            const _ProfileField(
              title: "Alamat",
              value: "Jalan Jakarta no. 10, Jakarta Indonesia",
            ),
            const _ProfileField(title: "Jabatan", value: "Front-End Developer"),
            const _ProfileField(
              title: "Departemen",
              value: "Teknologi Informasi",
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () async {
                  await AuthService.instance.logout(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Logout",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget Custom untuk Field
class _ProfileField extends StatelessWidget {
  final String title;
  final String value;

  const _ProfileField({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        TextField(
          readOnly: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xffe8e8e8),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            hintText: value,
            hintStyle: const TextStyle(color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
