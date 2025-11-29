import 'package:flutter/material.dart';

class EmployeeIzinForm extends StatefulWidget {
  const EmployeeIzinForm({super.key});

  @override
  State<EmployeeIzinForm> createState() => _EmployeeIzinFormState();
}

class _EmployeeIzinFormState extends State<EmployeeIzinForm> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();

  @override
  void dispose() {
    _dateController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Form Izin Karyawan')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _dateController,
              decoration: const InputDecoration(labelText: 'Tanggal (YYYY-MM-DD)'),
              keyboardType: TextInputType.datetime,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _reasonController,
              decoration: const InputDecoration(labelText: 'Alasan Izin'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: ElevatedButton(onPressed: () {}, child: const Text('Kirim Izin'))),
              ],
            )
          ],
        ),
      ),
    );
  }
}
