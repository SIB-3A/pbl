import 'package:client/models/employee_model.dart';
import 'package:client/services/employee_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EmployeeListScreen extends StatefulWidget {
  final bool isKaryawanMode;
  const EmployeeListScreen({super.key, required this.isKaryawanMode});

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<EmployeeModel> _employees = [];
  List<EmployeeModel> _filteredEmployees = [];

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadEmployees();
    _searchController.addListener(() {
      _performSearch(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadEmployees() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await EmployeeService.instance.getEmployees();

      if (response.success && response.data != null) {
        setState(() {
          _employees = response.data!;
          _filteredEmployees = _employees;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.message.isEmpty
              ? 'Gagal memuat data karyawan'
              : response.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() => _filteredEmployees = _employees);
      return;
    }

    setState(() {
      _filteredEmployees = _employees.where((emp) {
        return emp.fullName.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  Future<void> _refresh() async {
    return _loadEmployees();
  }

  void _backToRoleSelection() {
    context.go('/role-selection');
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
          onPressed: _backToRoleSelection,
        ),
        title: const Text(
          'Pilih karyawan untuk edit',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(color: const Color(0xFF1B9FE2)),
          Positioned.fill(
            top: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  _buildSearchBar(),
                  const SizedBox(height: 20),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _refresh,
                      child: _buildBody(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Cari karyawan',
        filled: true,
        fillColor: Colors.grey.shade200,
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF1B9FE2)),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Text(
          'Error: $_errorMessage',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (_filteredEmployees.isEmpty) {
      return Center(
        child: Text(
          _searchController.text.isNotEmpty
              ? 'Tidak ditemukan'
              : 'Belum ada data karyawan',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
      itemCount: _filteredEmployees.length,
      itemBuilder: (context, i) {
        return _buildEmployeeCard(_filteredEmployees[i]);
      },
    );
  }

  Widget _buildEmployeeCard(EmployeeModel employee) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () async {
            final result = await context.push<bool>(
              '/employee-detail/${employee.id}',
              extra: {
                'employee': employee,
                'isKaryawanMode': widget.isKaryawanMode,
              },
            );
            if (result == true) _loadEmployees();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: Row(
              children: [
                // AVATAR FOTO ATAU INISIAL
                CircleAvatar(
                  radius: 30,
                  backgroundColor: const Color(0xFF1B7FA8),
                  backgroundImage: employee.profilePhotoUrl != null
                      ? NetworkImage(employee.profilePhotoUrl!)
                      : null,
                  child: employee.profilePhotoUrl == null
                      ? Text(
                          employee.fullName.isNotEmpty
                              ? employee.fullName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(child: _buildEmployeeInfo(employee)),
                _buildArrow(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmployeeInfo(EmployeeModel employee) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          employee.fullName,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF0D8AB8),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.circle, size: 8, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                employee.position?.name ?? 'Tidak ada jabatan',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          employee.department?.name ?? 'Tidak ada department',
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF1B9FE2),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildArrow() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: Color(0xFF1B9FE2),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.arrow_forward_ios,
        color: Colors.white,
        size: 18,
      ),
    );
  }
}
