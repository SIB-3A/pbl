import 'package:flutter/material.dart';

class Employee {
  final String name;
  final int totalCuti;
  final List<String> jenisCuti;

  Employee({
    required this.name,
    required this.totalCuti,
    required this.jenisCuti,
  });
}

class DepartmentDetailPage extends StatefulWidget {
  final Map<String, dynamic> departmentData;

  const DepartmentDetailPage({
    super.key,
    required this.departmentData,
  });

  @override
  State<DepartmentDetailPage> createState() => _DepartmentDetailPageState();
}

class _DepartmentDetailPageState extends State<DepartmentDetailPage> {
  final TextEditingController searchController = TextEditingController();

  List<Employee> employees = [];
  List<Employee> filteredEmployees = [];

  @override
  void initState() {
    super.initState();

    // --- SAMPLE DATA sementara (nanti bisa diganti data API) ---
    employees = [
      Employee(
        name: "Aditya Yuhanda",
        totalCuti: 2,
        jenisCuti: [
          "Surat Izin Cuti Tahunan",
          "Surat Izin Tugas Perusahaan",
        ],
      ),
      Employee(
        name: "Larasati Putri",
        totalCuti: 1,
        jenisCuti: [
          "Surat Izin Tugas Perusahaan",
        ],
      ),
    ];

    filteredEmployees = List.from(employees);

    searchController.addListener(_runFilter);
  }

  void _runFilter() {
    String keyword = searchController.text.toLowerCase();

    setState(() {
      filteredEmployees = employees.where((e) {
        return e.name.toLowerCase().contains(keyword);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dept = widget.departmentData;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Laporan Dept ${dept['name']}"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // HEADER
              _buildHeader(dept),

              const SizedBox(height: 20),

              // LIST OTOMATIS DARI filteredEmployees
              ...filteredEmployees.asMap().entries.map((entry) {
                final index = entry.key + 1;
                final e = entry.value;

                return _buildEmployeeCard(
                  index: index,
                  name: e.name,
                  totalCuti: e.totalCuti,
                  jenisCuti: e.jenisCuti,
                );
              }).toList(),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // =============================== UI COMPONENTS ===============================

  Widget _buildHeader(Map<String, dynamic> dept) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 25, 20, 40),
      decoration: const BoxDecoration(
        color: Color(0xFF00A8E8),
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Dept. ${dept['name']}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Manager : Maisya",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 25),

          // Box jumlah karyawan + search field
          Row(
            children: [
              _buildEmployeeCountBox(dept),
              const SizedBox(width: 12),
              _buildSearchBox(),
            ],
          ),

          const SizedBox(height: 20),

          _buildExportButton(),
        ],
      ),
    );
  }

  Widget _buildEmployeeCountBox(Map<String, dynamic> dept) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.person, size: 32),
          const SizedBox(width: 8),
          Text(
            "${dept['count']} ",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSearchBox() {
    return Expanded(
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "Search",
                ),
              ),
            ),
            const Icon(Icons.search),
          ],
        ),
      ),
    );
  }

  Widget _buildExportButton() {
    return GestureDetector(
      onTap: () {
        // TODO: Export Excel
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF4CAF50),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.download, color: Colors.white),
            SizedBox(width: 8),
            Text(
              "Export Excel",
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeCard({
    required int index,
    required String name,
    required int totalCuti,
    required List<String> jenisCuti,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$index. $name",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Departemen: IT Development",
            style: TextStyle(fontSize: 15),
          ),
          const SizedBox(height: 6),

          Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 6),
              Text(
                "Total Cuti Disetujui: $totalCuti",
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          const Text(
            "Jenis Cuti:",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 6),
          ...jenisCuti.map((e) => Padding(
                padding: const EdgeInsets.only(left: 12, bottom: 4),
                child: Text("• $e"),
              )),
        ],
      ),
    );
  }
}
