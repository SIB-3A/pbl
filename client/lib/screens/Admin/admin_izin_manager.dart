import 'package:flutter/material.dart';

class AdminIzinManager extends StatelessWidget {
  const AdminIzinManager({super.key});

  @override
  Widget build(BuildContext context) {
    // placeholder list of izin requests
    final items = List.generate(6, (i) => {
          'name': 'Karyawan ${i + 1}',
          'date': '2025-11-${10 + i}',
          'status': i % 2 == 0 ? 'pending' : 'approved'
        });

    return Scaffold(
      appBar: AppBar(title: const Text('Admin: Mengelola Izin')),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final it = items[index];
          return Card(
            child: ListTile(
              title: Text(it['name']!),
              subtitle: Text('${it['date']} • Status: ${it['status']}'),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {},
                itemBuilder: (ctx) => [
                  const PopupMenuItem(value: 'masuk', child: Text('Masuk')),
                  const PopupMenuItem(value: 'tugas', child: Text('Tugas')),
                  const PopupMenuItem(value: 'tolak', child: Text('Tolak')),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
