import 'package:flutter/material.dart';

class IzinCountView extends StatelessWidget {
  const IzinCountView({super.key});

  @override
  Widget build(BuildContext context) {
    // placeholder counts
    final counts = {
      'Karyawan 1': 2,
      'Karyawan 2': 0,
      'Karyawan 3': 5,
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Hitung Izin')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: counts.entries
            .map((e) => Card(
                  child: ListTile(
                    title: Text(e.key),
                    trailing: Text('${e.value} kali'),
                  ),
                ))
            .toList(),
      ),
    );
  }
}
