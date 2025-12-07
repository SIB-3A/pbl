import 'package:client/models/employee_model.dart';
import 'package:client/services/employee_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EmployeeDetailScreen extends StatefulWidget {
  final EmployeeModel initialEmployee;
  final bool isKaryawanMode;

  const EmployeeDetailScreen({
    super.key,
    required this.initialEmployee,
    required this.isKaryawanMode,
  });

  @override
  State<EmployeeDetailScreen> createState() => _EmployeeDetailScreenState();
}

class _EmployeeDetailScreenState extends State<EmployeeDetailScreen> {
  late EmployeeModel _employee;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _employee = widget.initialEmployee;
  }

  Future<void> _refreshEmployee() async {
    setState(() => _isLoading = true);

    try {
      final response = await EmployeeService.instance.getEmployeeById(
        _employee.id,
      );

      if (response.success && response.data != null) {
        setState(() {
          _employee = response.data!;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.message)),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B9FE2),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1B9FE2),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            context.pop(true);
          },
        ),
        title: Text(
          _employee.fullName,
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshEmployee,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : Stack(
              children: [
                Container(color: const Color(0xFF1B9FE2)),
                Positioned.fill(
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF6F6F6),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Avatar tanpa ikon kamera
                          Center(
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: const Color(0xFF1B7FA8),
                              backgroundImage: _employee.profilePhotoUrl != null
                                  ? NetworkImage(_employee.profilePhotoUrl!)
                                  : null,
                              child: _employee.profilePhotoUrl == null
                                  ? Text(
                                      _employee.fullName.isNotEmpty
                                          ? _employee.fullName[0].toUpperCase()
                                          : '?',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 40,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : null,
                            ),
                          ),

                          const SizedBox(height: 25),

                          _buildInfoCard("Nama Depan", _employee.firstName),
                          _buildInfoCard("Nama Belakang", _employee.lastName),
                          _buildInfoCard(
                            "Jenis Kelamin",
                            _employee.gender == 'L'
                                ? "Laki-laki"
                                : "Perempuan",
                          ),
                          _buildInfoCard("Alamat", _employee.address),
                          _buildInfoCard("Status", _employee.employmentStatus),
                          _buildInfoCard(
                            "Posisi",
                            _employee.position?.name ?? "-",
                          ),
                          _buildInfoCard(
                            "Departemen",
                            _employee.department?.name ?? "-",
                          ),

                          const SizedBox(height: 25),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1B7FA8),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 30),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(36),
                                ),
                              ),
                              onPressed: () async {
                                final result = await context.push<bool>(
                                  widget.isKaryawanMode
                                      ? '/employee/edit-personal/${_employee.id}'
                                      : '/employee/edit-management/${_employee.id}',
                                  extra: _employee,
                                );

                                if (result == true) {
                                  await _refreshEmployee();
                                }
                              },
                              child: Text(
                                widget.isKaryawanMode
                                    ? "Edit Data Pribadi"
                                    : "Edit Status, Posisi & Departemen",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B7FA8),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(4, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              value.isEmpty ? "-" : value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
