import 'package:client/models/department_model.dart';
import 'package:client/models/employee_model.dart';
import 'package:client/models/position_model.dart';
import 'package:client/services/department_service.dart';
import 'package:client/services/employee_service.dart';
import 'package:client/services/position_service.dart';
import 'package:client/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EditAdminEmployeeScreen extends StatefulWidget {
  final EmployeeModel employee;
  const EditAdminEmployeeScreen({super.key, required this.employee});

  @override
  State<EditAdminEmployeeScreen> createState() => _EditAdminEmployeeScreenState();
}

class _EditAdminEmployeeScreenState extends State<EditAdminEmployeeScreen> {
  String? _status;
  int? _positionId;
  int? _departmentId;

  List<PositionModel> _positions = [];
  List<DepartmentModel> _departments = [];

  bool _isLoading = false;
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _status = widget.employee.employmentStatus.isNotEmpty ? widget.employee.employmentStatus : null;
    _positionId = widget.employee.positionId;
    _departmentId = widget.employee.departmentId;

    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoadingData = true);

    try {
      final positionsResponse = await PositionService.instance.getPositions();
      final departmentsResponse = await DepartmentService.instance.getDepartments();

      if (positionsResponse.success && positionsResponse.data != null) {
        _positions = positionsResponse.data!;
      }

      if (departmentsResponse.success && departmentsResponse.data != null) {
        _departments = departmentsResponse.data!;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingData = false);
      }
    }
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);

    try {
      final data = <String, dynamic>{};

      if (_status != null) data['employment_status'] = _status;
      if (_positionId != null) data['position_id'] = _positionId;
      if (_departmentId != null) data['department_id'] = _departmentId;

      final response = await EmployeeService.instance.updateManagement(
        widget.employee.id,
        data,
      );

      if (mounted) {
        if (response.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data karyawan berhasil diperbarui')),
          );
          context.pop(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.message)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildEmployeeInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: const Color(0xFF1B7FA8),
            backgroundImage: widget.employee.profilePhotoUrl != null
                ? NetworkImage(widget.employee.profilePhotoUrl!)
                : null,
            child: widget.employee.profilePhotoUrl == null
                ? Text(
                    widget.employee.fullName.isNotEmpty
                        ? widget.employee.fullName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 12),
          Text(
            widget.employee.fullName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1B7FA8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required Widget dropdown,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        dropdown,
      ],
    );
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
          onPressed: () => context.pop(false),
        ),
        title: const Text(
          'Edit Data Karyawan',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
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
                          _buildEmployeeInfo(),
                          const SizedBox(height: 24),

                          // Status Karyawan
                          _buildDropdownField(
                            label: "Status Karyawan",
                            dropdown: DropdownButtonFormField<String>(
                              value: _status,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey[50],
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF1B7FA8),
                                    width: 2,
                                  ),
                                ),
                              ),
                              items: [
                                'aktif',
                                'cuti',
                                'resign',
                                'phk',
                              ]
                                  .map(
                                    (s) => DropdownMenuItem(
                                      value: s,
                                      child: Text(_capitalize(s)),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) => setState(() => _status = val),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Posisi
                          _buildDropdownField(
                            label: "Posisi",
                            dropdown: DropdownButtonFormField<int>(
                              value: _positionId,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey[50],
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF1B7FA8),
                                    width: 2,
                                  ),
                                ),
                              ),
                              items: [
                                const DropdownMenuItem<int>(
                                  value: null,
                                  child: Text('Pilih posisi',
                                      style: TextStyle(color: Colors.grey)),
                                ),
                                ..._positions.map(
                                  (p) => DropdownMenuItem<int>(
                                    value: p.id,
                                    child: Text(p.name),
                                  ),
                                ),
                              ],
                              onChanged: (val) => setState(() => _positionId = val),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Departemen
                          _buildDropdownField(
                            label: "Departemen",
                            dropdown: DropdownButtonFormField<int>(
                              value: _departmentId,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey[50],
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF1B7FA8),
                                    width: 2,
                                  ),
                                ),
                              ),
                              items: [
                                const DropdownMenuItem<int>(
                                  value: null,
                                  child: Text('Pilih departemen',
                                      style: TextStyle(color: Colors.grey)),
                                ),
                                ..._departments.map(
                                  (d) => DropdownMenuItem<int>(
                                    value: d.id,
                                    child: Text(d.name),
                                  ),
                                ),
                              ],
                              onChanged: (val) => setState(() => _departmentId = val),
                            ),
                          ),

                          const SizedBox(height: 30),

                          // Tombol simpan
                          _isLoading
                              ? const CircularProgressIndicator()
                              : CustomButton(
                                  backgroundColor: const Color(0xFF1B7FA8),
                                  onPressed: _save,
                                  child: const Text(
                                    'Simpan Perubahan',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
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

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}