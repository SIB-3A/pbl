import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminIzinManager extends StatefulWidget {
  const AdminIzinManager({super.key});

  @override
  State<AdminIzinManager> createState() => _AdminIzinManagerState();
}

class _AdminIzinManagerState extends State<AdminIzinManager> {
  String selectedFilter = "All";

  // ---------------- SAMPLE DATA ----------------
  final List<Map<String, dynamic>> izinData = [
    {"status": "Diproses", "color": Colors.orange},
    {"status": "Ditolak", "color": Colors.red},
    {"status": "Diterima", "color": Colors.green},
    {"status": "Diproses", "color": Colors.orange},
    {"status": "Diterima", "color": Colors.green},
  ];

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredData = izinData.where((item) {
      if (selectedFilter == "All") return true;
      return item["status"] == selectedFilter;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ----------------- HEADER -----------------
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 35),
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF0DB4E5),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
              ),
              child: Column(
                children: [
                  // ------------ ROW: BACK, TITLE CENTER, LOGO ------------
                  Row(
                    children: [
                      // BACK BUTTON
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => context.go('/'),
                      ),

                      // TITLE DI TENGAH
                      Expanded(
                        child: Text(
                          "HRIS Manajemen Izin",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      // LOGO DI KANAN
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.apartment, color: Colors.blue),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // CARD IZIN
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.people, size: 35),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "28 / 120",
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "Surat Izin Diproses",
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // SLIDER IZIN
                  SizedBox(
                    height: 120,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        izinCard("Surat Izin Tugas"),
                        izinCard("Surat Izin Cuti Tahunan"),
                        izinCard("Surat Izin Tanpa Gaji"),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ----------------- UPDATE LIST + FILTER -----------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Update List",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  GestureDetector(
                    onTap: () => showFilterSheet(context),
                    child: const Icon(Icons.filter_list, size: 26),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // ----------------- LIST -----------------
            Column(
              children: filteredData
                  .map((item) =>
                      izinListItem(status: item["status"], color: item["color"]))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------- FILTER BOTTOM SHEET -----------------
  void showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              filterOption("All"),
              filterOption("Diproses"),
              filterOption("Diterima"),
              filterOption("Ditolak"),
            ],
          ),
        );
      },
    );
  }

  Widget filterOption(String label) {
    return ListTile(
      title: Text(label),
      trailing: selectedFilter == label
          ? const Icon(Icons.check, color: Colors.blue)
          : null,
      onTap: () {
        setState(() => selectedFilter = label);
        Navigator.pop(context);
      },
    );
  }

  // ----------------- CARD IZIN -----------------
  Widget izinCard(String title) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.mail, size: 40),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // ----------------- ITEM LIST -----------------
  Widget izinListItem({required String status, required Color color}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            offset: const Offset(0, 2),
            blurRadius: 5,
          )
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 25,
            backgroundColor: Colors.blue,
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "TANGGAL/BULAN/TAHUN",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13),
                ),
                SizedBox(height: 5),
                Text(
                  "Full Name\nDepartment :",
                  style: TextStyle(fontSize: 12, height: 1.3),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              border: Border.all(color: color, width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
