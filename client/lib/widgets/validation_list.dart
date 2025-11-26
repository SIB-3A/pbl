import 'package:flutter/material.dart';

class ValidationList extends StatelessWidget {
  final List<Map<String, dynamic>> items;

  const ValidationList({super.key, required this.items});

  void _showValidationDialog(BuildContext context, Map<String, dynamic> item) {
    final TextEditingController tanggalController = TextEditingController();
    final TextEditingController catatanController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Validasi Surat – ${item['nama']}'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Departemen: ${item['departemen']}'),
                Text('Tanggal Pengajuan: ${item['tanggal']}'),
                const SizedBox(height: 12),
                const Text(
                  'Isi Surat:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(item['surat']),
                const SizedBox(height: 16),
                TextField(
                  controller: tanggalController,
                  decoration: const InputDecoration(
                    labelText: 'Tanggal Keputusan',
                    hintText: 'YYYY-MM-DD',
                  ),
                ),
                TextField(
                  controller: catatanController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Catatan'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Logic Reject
                Navigator.pop(context);
              },
              child: const Text('Tolak'),
            ),
            ElevatedButton(
              onPressed: () {
                // Logic Acc
                Navigator.pop(context);
              },
              child: const Text('Setujui'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = items[index];

        return ListTile(
          title: Text(item['nama']),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Departemen: ${item['departemen']}'),
              Text('Tanggal: ${item['tanggal']}'),
            ],
          ),
          trailing: Text(
            item['status'],
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: item['status'] == 'Diterima'
                  ? Colors.green
                  : item['status'] == 'Ditolak'
                  ? Colors.red
                  : Colors.orange,
            ),
          ),
          onTap: () => _showValidationDialog(context, item),
        );
      },
    );
  }
}
