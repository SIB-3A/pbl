import 'package:flutter/material.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class AllLettersPage extends StatelessWidget {
  final List<dynamic> letters;

  const AllLettersPage({super.key, required this.letters});

  Future<void> exportToExcel() async {
    const url =
        "https://collene-eternal-luba.ngrok-free.dev/api/export-approved-letters";

    try {
      Dio dio = Dio();

      Directory dir = await getApplicationDocumentsDirectory();
      String filePath = "${dir.path}/laporan_cuti_disetujui.xlsx";

      await dio.download(
        url,
        filePath,
        options: Options(responseType: ResponseType.bytes),
      );

      await OpenFilex.open(filePath);

      debugPrint("Excel file downloaded to $filePath");
    } catch (e) {
      debugPrint("ERROR EXPORT: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Laporan Semua Karyawan Cuti',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF00A8E8),
        foregroundColor: Colors.white,
      ),

      body: Column(
        children: [
          // EXPORT BUTTON
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: exportToExcel,
                icon: const Icon(Icons.download),
                label: const Text(
                  "Export Excel",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),

          // LIST
          Expanded(
            child: ListView.builder(
              itemCount: letters.length,
              itemBuilder: (context, index) {
                final item = letters[index];

                // AMBIL LIST CUTI
                final cutiList = (item['cuti_list'] ?? '')
                    .toString()
                    .split(',')
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty)
                    .toList();

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nomor urut + Nama
                        Text(
                          "${index + 1}. ${item['employee_name'] ?? 'Tanpa Nama'}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          "Departemen: ${item['department_name'] ?? '-'}",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              size: 20,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "Total Cuti Disetujui: ${item['total_approved_letters']}",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // Penjabaran jenis cuti
                        const Text(
                          "Jenis Cuti:",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),

                        const SizedBox(height: 4),

                        ...cutiList.map(
                          (cuti) => Padding(
                            padding: const EdgeInsets.only(left: 8, bottom: 3),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "• ",
                                  style: TextStyle(fontSize: 14),
                                ),
                                Expanded(
                                  child: Text(
                                    cuti,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // FOOTER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade200,
            child: Text(
              "Total Karyawan Ditampilkan: ${letters.length}",
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
