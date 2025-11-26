import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SuratIjinMenu extends StatelessWidget {
  const SuratIjinMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Menu Surat Ijin')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.edit),
              label: const Text('1. Membuat template surat ijin'),
              onPressed: () => context.push('/surat-ijin/template'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.note_add),
              label: const Text('2. Karyawan itu ijin'),
              onPressed: () => context.push('/surat-ijin/employee'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.manage_accounts),
              label: const Text('3. Admin mengelola ijin'),
              onPressed: () => context.push('/surat-ijin/admin'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.format_list_numbered),
              label: const Text('4. Menghitung sudah berapa kali izin'),
              onPressed: () => context.push('/surat-ijin/count'),
            ),
          ],
        ),
      ),
    );
  }
}
