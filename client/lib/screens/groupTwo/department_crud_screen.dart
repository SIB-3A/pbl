import 'package:latlong2/latlong.dart';
import 'package:client/widgets/location_preview_card.dart';
import 'package:client/widgets/map_picker_dialog.dart';
import 'package:client/models/department_model.dart';
import 'package:client/services/department_service.dart';
import 'package:client/widgets/custom_button.dart';
import 'package:client/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DepartmentCrudScreen extends StatefulWidget {
  const DepartmentCrudScreen({super.key});

  @override
  State<DepartmentCrudScreen> createState() => _DepartmentCrudScreenState();
}

class _DepartmentCrudScreenState extends State<DepartmentCrudScreen> {
  List<DepartmentModel> _departments = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadDepartments();
  }

  Future<void> _loadDepartments() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await DepartmentService.instance.getDepartments();

      if (response.success && response.data != null) {
        setState(() {
          _departments = response.data!;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // Di dalam method _showForm, ubah bagian StatefulBuilder:
  Future<void> _showForm([DepartmentModel? dept]) async {
    final isEdit = dept != null;
    final nameCtrl = TextEditingController(text: isEdit ? dept.name : '');

    // Ganti controller manual dengan state untuk peta
    double? latitude = isEdit ? dept.latitude : null;
    double? longitude = isEdit ? dept.longitude : null;
    int? radius = isEdit ? dept.radiusMeters : null;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          bool isSaving = false;

          // Function untuk buka peta
          Future<void> openMapPicker() async {
            if (!mounted) return;

            final locationResult = await Navigator.push(
              dialogContext,
              MaterialPageRoute(
                builder: (context) => MapPickerDialog(
                  initialLocation: (latitude != null && longitude != null)
                      ? LatLng(latitude!, longitude!)
                      : null,
                  initialRadius: radius?.toDouble() ?? 100.0,
                  onLocationSelected: (LatLng location, double radiusValue) {
                    setDialogState(() {
                      latitude = location.latitude;
                      longitude = location.longitude;
                      radius = radiusValue.round();
                    });
                  },
                ),
              ),
            );
            // locationResult tidak digunakan, jadi tidak perlu disimpan
          }

          return PopScope(
            canPop: !isSaving,
            onPopInvoked: (didPop) {
              // Handle pop jika perlu
            },
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: const Color(0xFFF6F6F6),
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F6F6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isEdit ? 'Edit Departemen' : 'Tambah Departemen',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1B7FA8),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.grey),
                            onPressed: isSaving
                                ? null
                                : () => Navigator.pop(dialogContext, false),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Nama Departemen (tetap text field)
                      CustomTextField(
                        controller: nameCtrl,
                        label: "Nama Departemen",
                        hintText: "Contoh: Marketing",
                        enabled: !isSaving,
                      ),
                      const SizedBox(height: 18),

                      // Card untuk preview dan pilih lokasi
                      LocationPreviewCard(
                        latitude: latitude,
                        longitude: longitude,
                        radius: radius,
                        onPickLocation: isSaving ? null : openMapPicker,
                        isLoading: isSaving,
                      ),

                      const SizedBox(height: 20),

                      isSaving
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF1B7FA8),
                              ),
                            )
                          : Row(
                              children: [
                                Expanded(
                                  child: CustomButton(
                                    backgroundColor: Colors.grey[300],
                                    onPressed: () =>
                                        Navigator.pop(dialogContext, false),
                                    child: const Text(
                                      'Batal',
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: CustomButton(
                                    backgroundColor: const Color(0xFF1B7FA8),
                                    onPressed: () async {
                                      // Validasi input
                                      if (nameCtrl.text.trim().isEmpty) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(
                                            dialogContext,
                                          ).showSnackBar(
                                            const SnackBar(
                                              backgroundColor: Colors.red,
                                              content: Text(
                                                'Nama departemen harus diisi',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                        return;
                                      }

                                      if (latitude == null ||
                                          longitude == null ||
                                          radius == null) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(
                                            dialogContext,
                                          ).showSnackBar(
                                            const SnackBar(
                                              backgroundColor: Colors.red,
                                              content: Text(
                                                'Silakan pilih lokasi di peta',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                        return;
                                      }

                                      if (radius == null || radius! <= 0) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(
                                            dialogContext,
                                          ).showSnackBar(
                                            const SnackBar(
                                              backgroundColor: Colors.red,
                                              content: Text(
                                                'Radius harus lebih dari 0',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                        return;
                                      }

                                      setDialogState(() {
                                        isSaving = true;
                                      });

                                      try {
                                        final data = {
                                          'name': nameCtrl.text.trim(),
                                          'latitude': latitude!,
                                          'longitude': longitude!,
                                          'radius_meters': radius!,
                                        };

                                        if (isEdit) {
                                          await DepartmentService.instance
                                              .updateDepartment(dept!.id, data);
                                        } else {
                                          await DepartmentService.instance
                                              .createDepartment(data);
                                        }

                                        // Berhasil, kembalikan true
                                        if (mounted) {
                                          Navigator.pop(dialogContext, true);
                                        }
                                      } catch (e) {
                                        // Jika error, kembalikan isSaving ke false
                                        setDialogState(() {
                                          isSaving = false;
                                        });

                                        if (mounted) {
                                          ScaffoldMessenger.of(
                                            dialogContext,
                                          ).showSnackBar(
                                            SnackBar(
                                              backgroundColor: Colors.red,
                                              content: Text(
                                                'Gagal menyimpan: $e',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                    },
                                    child: const Text(
                                      'Simpan',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );

    // Handle setelah dialog selesai
    if (result == true && mounted) {
      // Tampilkan loading
      setState(() {
        _isProcessing = true;
      });

      try {
        // Load ulang data dari server
        await _loadDepartments();

        setState(() {
          _isProcessing = false;
        });

        // Tampilkan snackbar sukses
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF1B7FA8),
            content: Text(
              isEdit
                  ? 'Departemen berhasil diperbarui'
                  : 'Departemen berhasil ditambahkan',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      } catch (e) {
        setState(() {
          _isProcessing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              'Gagal memuat ulang data: $e',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      }
    }
  }

  Future<void> _deleteDepartment(int id) async {
    // Dapatkan departemen yang akan dihapus untuk ditampilkan di konfirmasi
    final departmentToDelete = _departments.firstWhere((dept) => dept.id == id);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFFF6F6F6),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFF6F6F6),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning, size: 60, color: Colors.orange),
              const SizedBox(height: 16),
              const Text(
                'Konfirmasi Hapus',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Yakin ingin menghapus departemen "${departmentToDelete.name}"?',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      backgroundColor: Colors.grey[300],
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text(
                        'Batal',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      backgroundColor: Colors.red,
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        'Hapus',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true && mounted) {
      setState(() {
        _isProcessing = true;
      });

      try {
        await DepartmentService.instance.deleteDepartment(id);

        // Hapus dari local state
        setState(() {
          _departments.removeWhere((dept) => dept.id == id);
          _isProcessing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF1B7FA8),
            content: Text(
              'Departemen "${departmentToDelete.name}" berhasil dihapus',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      } catch (e) {
        setState(() {
          _isProcessing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              'Gagal menghapus: $e',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      }
    }
  }

  Widget _buildDepartmentCard(DepartmentModel department) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  department.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1B7FA8),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    color: const Color(0xFF1B7FA8),
                    onPressed: _isProcessing
                        ? null
                        : () => _showForm(department),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20),
                    color: Colors.red,
                    onPressed: _isProcessing
                        ? null
                        : () => _deleteDepartment(department.id),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Latitude',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          department.latitude.toStringAsFixed(6),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Longitude',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          department.longitude.toStringAsFixed(6),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Radius',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${department.radiusMeters} meter',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF1B7FA8)),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Terjadi kesalahan',
              style: TextStyle(fontSize: 18, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 24),
            CustomButton(
              backgroundColor: const Color(0xFF1B7FA8),
              onPressed: _loadDepartments,
              child: const Text(
                'Coba Lagi',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_departments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.business, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 24),
            const Text(
              'Belum ada departemen',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Tambahkan departemen pertama Anda',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'List data departemen',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${_departments.length} departemen ditemukan',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            color: const Color(0xFF1B7FA8),
            onRefresh: _loadDepartments,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              children: [
                ..._departments.map(
                  (department) => _buildDepartmentCard(department),
                ),
              ],
            ),
          ),
        ),
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
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Kelola Departemen',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          Container(color: const Color(0xFF1B9FE2)),
          Positioned.fill(
            top: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF6F6F6),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: _isProcessing
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF1B7FA8),
                      ),
                    )
                  : _buildBody(),
            ),
          ),
        ],
      ),
      floatingActionButton: _isProcessing
          ? null
          : FloatingActionButton(
              backgroundColor: const Color(0xFF1B7FA8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 28),
              onPressed: () => _showForm(),
            ),
    );
  }
}
