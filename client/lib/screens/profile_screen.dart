import 'package:client/models/employee_model.dart';
import 'package:client/services/auth_service.dart';
import 'package:client/services/employee_service.dart'; // ✅ GANTI DARI UserService
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

final storage = FlutterSecureStorage();

class ProfileScreen extends StatefulWidget {
  final int? userId; // Jika ada → Admin mode, Jika null → Employee mode

  const ProfileScreen({super.key, this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  EmployeeModel? _employee; // ✅ GANTI dari UserModel ke EmployeeModel
  bool _isLoading = true;
  bool _isAdminMode = false;
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    // Get current logged-in user ID
    final userIdStr = await storage.read(key: "userId");
    _currentUserId = userIdStr != null ? int.tryParse(userIdStr) : null;

    // Determine mode: Admin viewing employee OR Employee viewing self
    _isAdminMode = widget.userId != null && widget.userId != _currentUserId;

    await _loadEmployeeData();
  }

  Future<void> _loadEmployeeData() async {
    setState(() => _isLoading = true);

    try {
      // ✅ Use widget.userId if provided (admin mode), else use current user ID
      final targetUserId = widget.userId ?? _currentUserId;

      if (targetUserId == null) {
        setState(() => _isLoading = false);
        return;
      }

      // ✅ LANGSUNG DARI EMPLOYEE SERVICE
      final response = await EmployeeService.instance.getEmployeeById(
        targetUserId,
      );

      if (response.success && response.data != null) {
        setState(() {
          _employee = response.data;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(response.message)));
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memuat data: $e')));
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
        leading: _isAdminMode
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => context.pop(),
              )
            : null,
        title: Text(
          _isAdminMode ? "Detail Karyawan" : "Profil Saya",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Image.asset('assets/logoPbl.png', width: 45, height: 45),
          ),
        ],
      ),
      body: _isLoading
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
                          // ✅ AVATAR WITH EDIT BUTTON
                          Stack(
                            children: [
                              Center(
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundColor: const Color(0xFF1B7FA8),
                                  // ✅ SAMA SEPERTI EMPLOYEE_SCREEN
                                  backgroundImage:
                                      _employee?.profilePhotoUrl != null
                                      ? NetworkImage(
                                          _employee!.profilePhotoUrl!,
                                        )
                                      : null,
                                  child: _employee?.profilePhotoUrl == null
                                      ? Text(
                                          _employee?.fullName.isNotEmpty == true
                                              ? _employee!.fullName[0]
                                                    .toUpperCase()
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

                              // ✅ EDIT BUTTON (EMPLOYEE MODE ONLY)
                              if (!_isAdminMode && _employee != null)
                                Positioned(
                                      left:
                                          MediaQuery.of(context).size.width -
                                              100,
                                      top: 0,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: const Color.fromARGB(
                                            255,
                                            84,
                                            172,
                                            255,
                                          ),
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.2),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.edit,
                                            color: Color.fromARGB(
                                              255,
                                              255,
                                              144,
                                              17,
                                            ),
                                            size: 24,
                                          ),
                                      onPressed: () async {
                                        final result = await context.push(
                                          '/employee/edit-personal/${_employee!.id}',
                                          extra: _employee,
                                        );

                                        if (result == true && mounted) {
                                          await _loadEmployeeData();
                                        }
                                      },
                                    ),
                                  ),
                                ),
                            ],
                          ),

                          const SizedBox(height: 25),

                          // ✅ INFO CARDS
                          _buildInfoCard(
                            "Nama Depan",
                            _employee?.firstName ?? "-",
                          ),
                          _buildInfoCard(
                            "Nama Belakang",
                            _employee?.lastName ?? "-",
                          ),
                          _buildInfoCard(
                            "Email",
                            _employee?.user?.email ?? "-",
                          ),
                          _buildInfoCard(
                            "Jenis Kelamin",
                            _employee?.gender == 'L'
                                ? "Laki-laki"
                                : _employee?.gender == 'P'
                                ? "Perempuan"
                                : "-",
                          ),
                          _buildInfoCard("Alamat", _employee?.address ?? "-"),
                          _buildInfoCard(
                            "Status",
                            _employee?.employmentStatus ?? "-",
                          ),
                          _buildInfoCard(
                            "Posisi",
                            _employee?.position?.name ?? "-",
                          ),
                          _buildInfoCard(
                            "Departemen",
                            _employee?.department?.name ?? "-",
                          ),

                          const SizedBox(height: 25),

                          // ✅ INFORMASI GAJI BUTTON (BOTH MODES)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4CB050),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: () {
                                context.push("/payroll");
                              },
                              icon: const Icon(
                                Icons.account_balance_wallet,
                                color: Colors.white,
                              ),
                              label: const Text(
                                "Informasi Gaji",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                          // ✅ EDIT BUTTON (ADMIN MODE ONLY)
                          if (_isAdminMode) ...[
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF1A53B),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                onPressed: () async {
                                  if (_employee != null) {
                                    final result = await context.push(
                                      '/admin/edit-employee',
                                      extra: _employee!.id,
                                    );

                                    if (result == true && mounted) {
                                      await _loadEmployeeData();
                                    }
                                  }
                                },
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  "Edit Data Karyawan",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],

                          // ✅ LOGOUT BUTTON (EMPLOYEE MODE ONLY)
                          if (!_isAdminMode) ...[
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                onPressed: () async {
                                  await AuthService.instance.logout(context);
                                },
                                icon: const Icon(
                                  Icons.logout,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  "Logout",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(height: 20),
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
