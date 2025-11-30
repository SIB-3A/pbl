import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:client/widgets/menu_button.dart';
import 'package:client/widgets/validation_list.dart';

class SuratIjinMenu extends StatelessWidget {
  const SuratIjinMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Menu Surat Ijin')),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SuratIjinContent(),
      ),
    );
  }
}

class SuratIjinContent extends StatelessWidget {
  const SuratIjinContent({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy Data Validation
    final items = [
      {
        'nama': 'Budi Santoso',
        'departemen': 'HRD',
        'tanggal': '2025-01-12',
        'status': 'Diproses',
        'surat':
            'Saya mengajukan cuti tahunan selama 3 hari mulai tanggal 15 Januari 2025.',
      },
      {
        'nama': 'Sinta Lestari',
        'departemen': 'Finance',
        'tanggal': '2025-01-10',
        'status': 'Ditolak',
        'surat':
            'Saya mengajukan cuti tugas ke kantor pusat mulai tanggal 20 Januari 2025.',
      },
      {
        'nama': 'Dewi Anggraini',
        'departemen': 'IT',
        'tanggal': '2025-01-09',
        'status': 'Diterima',
        'surat':
            'Saya mengajukan cuti tanpa gaji selama 5 hari mulai tanggal 18 Januari 2025.',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MenuButton(
          title: 'Template Surat Cuti Tahunan',
          icon: Icons.description,
          onTap: () => context.push('/surat-ijin/template-cuti-tahunan'),
        ),
        const SizedBox(height: 12),
        MenuButton(
          title: 'Template Surat Cuti Tugas',
          icon: Icons.assignment,
          onTap: () => context.push('/surat-ijin/template-cuti-tugas'),
        ),
        const SizedBox(height: 12),
        MenuButton(
          title: 'Template Surat Cuti Tanpa Gaji',
          icon: Icons.money_off,
          onTap: () => context.push('/surat-ijin/template-cuti-tanpa-gaji'),
        ),

        const SizedBox(height: 24),

        const Text(
          'Validasi Surat',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 12),

        Expanded(child: ValidationList(items: items)),
      ],
    );
  }
}
