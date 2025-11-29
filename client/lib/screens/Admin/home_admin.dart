import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeAdmin extends StatelessWidget {
  const HomeAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HRIS')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Selamat datang',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            Card(
              child: ListTile(
                leading: const Icon(Icons.description),
                title: const Text('Menu Surat Izin'),
                subtitle: const Text('Membuat dan mengelola surat izin'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/surat-ijin'),
              ),
            ),
            const SizedBox(height: 12),
            // other menu placeholders
            Card(
              child: ListTile(
                leading: const Icon(Icons.people),
                title: const Text('Karyawan'),
                subtitle: const Text('Menu karyawan lainnya'),
                onTap: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
