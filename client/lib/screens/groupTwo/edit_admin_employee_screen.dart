import 'package:client/models/department_model.dart';
import 'package:client/models/employee_model.dart';
import 'package:client/models/position_model.dart';
import 'package:client/models/user_model.dart';
import 'package:client/services/department_service.dart';
import 'package:client/services/employee_service.dart';
import 'package:client/services/position_service.dart';
import 'package:client/services/user_service.dart';
import 'package:client/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EditAdminEmployeeScreen extends StatefulWidget {
  final int employeeId;

  const EditAdminEmployeeScreen({super.key, required this.employeeId});

  @override
  State<EditAdminEmployeeScreen> createState() =>
      _EditAdminEmployeeScreenState();
}

class _EditAdminEmployeeScreenState extends State<EditAdminEmployeeScreen> {
  // Controllers
  final TextEditingController _emailController = TextEditingController();

  // State variables
  String? _status;
  int? _positionId;
  int? _departmentId;

  List<PositionModel> _positions = [];
  List<DepartmentModel> _departments = [];

  EmployeeModel? _employee;
  UserModel<EmployeeModel>? _user;

  bool _isLoading = false;
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoadingData = true);

    try {
      // Load employee data
      final employeeResponse = await EmployeeService.instance.getEmployeeById(
        widget.employeeId,
      );

      // ✅ DEBUG LOG
      debugPrint('=== EMPLOYEE RESPONSE ===');
      debugPrint('Success: ${employeeResponse.success}');
      debugPrint('Data: ${employeeResponse.data}');

      if (employeeResponse.success && employeeResponse.data != null) {
        _employee = employeeResponse.data!;

        // ✅ DEBUG LOG
        debugPrint('Employee ID: ${_employee!.id}');
        debugPrint('Employee User ID: ${_employee!.userId}');
        debugPrint('Employee Full Name: ${_employee!.fullName}');

        // Set initial values
        _status = _employee!.employmentStatus.isNotEmpty
            ? _employee!.employmentStatus
            : null;
        _positionId = _employee!.positionId;
        _departmentId = _employee!.departmentId;

        // ✅ DEBUG LOG
        debugPrint('Initial Status: $_status');
        debugPrint('Initial Position ID: $_positionId');
        debugPrint('Initial Department ID: $_departmentId');

        // Load user data for email
        if (_employee!.userId != null) {
          // ✅ DEBUG LOG
          debugPrint('=== FETCHING USER DATA ===');
          debugPrint('User ID to fetch: ${_employee!.userId}');

          final userResponse = await UserService.instance.getUser(
            _employee!.userId,
          );

          // ✅ DEBUG LOG
          debugPrint('=== USER RESPONSE ===');
          debugPrint('Success: ${userResponse.success}');
          debugPrint('Message: ${userResponse.message}');
          debugPrint('Data: ${userResponse.data}');

          if (userResponse.success && userResponse.data != null) {
            _user = userResponse.data;

            // ✅ DEBUG LOG
            debugPrint('User Email: ${_user!.email}');
            debugPrint('User ID: ${_user!.id}');

            _emailController.text = _user!.email;

            // ✅ FORCE REBUILD
            setState(() {});
          } else {
            debugPrint('❌ Failed to load user: ${userResponse.message}');
          }
        } else {
          debugPrint('❌ Employee userId is null');
        }
      } else {
        debugPrint('❌ Failed to load employee: ${employeeResponse.message}');
      }

      // Load positions
      final positionsResponse = await PositionService.instance.getPositions();
      if (positionsResponse.success && positionsResponse.data != null) {
        _positions = positionsResponse.data!;
        debugPrint('✅ Loaded ${_positions.length} positions');
      }

      // Load departments
      final departmentsResponse = await DepartmentService.instance
          .getDepartments();
      if (departmentsResponse.success && departmentsResponse.data != null) {
        _departments = departmentsResponse.data!;
        debugPrint('✅ Loaded ${_departments.length} departments');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ ERROR in _loadData: $e');
      debugPrint('Stack trace: $stackTrace');

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memuat data: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingData = false);
      }
    }
  }

  Future<void> _save() async {
    // ✅ VALIDATION
    if (_employee == null) {
      debugPrint('❌ Employee is null');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data karyawan tidak ditemukan'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // ✅ DEBUG LOG
      debugPrint('=== SAVING DATA ===');
      debugPrint('Employee ID: ${_employee!.id}');
      debugPrint('Status: $_status');
      debugPrint('Position ID: $_positionId');
      debugPrint('Department ID: $_departmentId');
      debugPrint('Email: ${_emailController.text}');

      // 1. Update employee data
      final employeeData = <String, dynamic>{};

      if (_status != null) employeeData['employment_status'] = _status;
      if (_positionId != null) employeeData['position_id'] = _positionId;
      if (_departmentId != null) employeeData['department_id'] = _departmentId;

      debugPrint('Employee data to update: $employeeData');

      // ✅ ONLY UPDATE IF THERE'S DATA
      if (employeeData.isNotEmpty) {
        final employeeResponse = await EmployeeService.instance
            .updateManagement(_employee!.id, employeeData);

        debugPrint('Employee update response: ${employeeResponse.success}');
        debugPrint('Employee update message: ${employeeResponse.message}');

        if (!employeeResponse.success) {
          throw Exception('Gagal update employee: ${employeeResponse.message}');
        }
      }

      // 2. Update user email if changed
      if (_user != null && _emailController.text != _user!.email) {
        debugPrint('=== UPDATING EMAIL ===');
        debugPrint('Old email: ${_user!.email}');
        debugPrint('New email: ${_emailController.text}');

        final userData = {'email': _emailController.text};

        final userResponse = await UserService.instance.updateUser(
          _user!.id,
          userData,
        );

        debugPrint('User update response: ${userResponse.success}');
        debugPrint('User update message: ${userResponse.message}');

        if (!userResponse.success) {
          throw Exception('Gagal update email: ${userResponse.message}');
        }
      } else {
        debugPrint('Email tidak berubah atau user null');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Data karyawan berhasil diperbarui'),
            backgroundColor: Colors.green,
          ),
        );

        // ✅ DELAY SEBELUM POP
        await Future.delayed(const Duration(milliseconds: 500));

        if (mounted) {
          context.pop(true);
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ ERROR in _save: $e');
      debugPrint('Stack trace: $stackTrace');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Gagal menyimpan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildEmployeeInfo() {
    if (_employee == null) return const SizedBox.shrink();

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
            backgroundImage: _employee!.profilePhotoUrl != null
                ? NetworkImage(_employee!.profilePhotoUrl!)
                : null,
            child: _employee!.profilePhotoUrl == null
                ? Text(
                    _employee!.fullName.isNotEmpty
                        ? _employee!.fullName[0].toUpperCase()
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
            _employee!.fullName,
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

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1B7FA8), width: 2),
            ),
          ),
        ),
      ],
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
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
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

                          // ✅ EMAIL FIELD (NEW)
                          _buildTextField(
                            label: "Email",
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                          ),

                          const SizedBox(height: 16),

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
                              items: ['aktif', 'cuti', 'resign', 'phk']
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
                                  child: Text(
                                    'Pilih posisi',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                                ..._positions.map(
                                  (p) => DropdownMenuItem<int>(
                                    value: p.id,
                                    child: Text(p.name),
                                  ),
                                ),
                              ],
                              onChanged: (val) =>
                                  setState(() => _positionId = val),
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
                                  child: Text(
                                    'Pilih departemen',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                                ..._departments.map(
                                  (d) => DropdownMenuItem<int>(
                                    value: d.id,
                                    child: Text(d.name),
                                  ),
                                ),
                              ],
                              onChanged: (val) =>
                                  setState(() => _departmentId = val),
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
