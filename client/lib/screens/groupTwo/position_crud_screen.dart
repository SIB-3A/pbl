import 'package:client/models/position_model.dart';
import 'package:client/services/position_service.dart';
import 'package:client/widgets/custom_button.dart';
import 'package:client/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PositionCrudScreen extends StatefulWidget {
  const PositionCrudScreen({super.key});

  @override
  State<PositionCrudScreen> createState() => _PositionCrudScreenState();
}

class _PositionCrudScreenState extends State<PositionCrudScreen> {
  List<PositionModel> _positions = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadPositions();
  }

  Future<void> _loadPositions() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await PositionService.instance.getPositions();

      if (response.success && response.data != null) {
        setState(() {
          _positions = response.data!;
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

  Future<void> _showForm([PositionModel? pos]) async {
    final isEdit = pos != null;
    final nameCtrl = TextEditingController(text: isEdit ? pos.name : '');
    final rateRegulerCtrl = TextEditingController(
      text: isEdit ? pos.rateReguler.toStringAsFixed(0) : '',
    );
    final rateOvertimeCtrl = TextEditingController(
      text: isEdit ? pos.rateOvertime.toStringAsFixed(0) : '',
    );

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          bool isSaving = false;
          
          return WillPopScope(
            onWillPop: () async => !isSaving,
            child: Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              backgroundColor: const Color(0xFFF6F6F6),
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(24),
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
                            isEdit ? 'Edit Posisi' : 'Tambah Posisi',
                            style: const TextStyle(
                              fontSize: 20,
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
                      const SizedBox(height: 24),

                      CustomTextField(
                        controller: nameCtrl,
                        label: "Nama Posisi",
                        hintText: "Contoh: Manager",
                        enabled: !isSaving,
                      ),
                      const SizedBox(height: 16),

                      CustomTextField(
                        controller: rateRegulerCtrl,
                        label: "Rate Regular",
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: false,
                        ),
                        hintText: "50000",
                        enabled: !isSaving,
                      ),
                      const SizedBox(height: 16),

                      CustomTextField(
                        controller: rateOvertimeCtrl,
                        label: "Rate Overtime",
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: false,
                        ),
                        hintText: "75000",
                        enabled: !isSaving,
                      ),

                      const SizedBox(height: 30),

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
                                    onPressed: () => Navigator.pop(dialogContext, false),
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
                                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                                          const SnackBar(
                                            backgroundColor: Colors.red,
                                            content: Text(
                                              'Nama posisi harus diisi',
                                              style: TextStyle(color: Colors.white),
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      if (rateRegulerCtrl.text.isEmpty ||
                                          double.tryParse(rateRegulerCtrl.text) == null) {
                                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                                          const SnackBar(
                                            backgroundColor: Colors.red,
                                            content: Text(
                                              'Rate regular harus angka',
                                              style: TextStyle(color: Colors.white),
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      if (rateOvertimeCtrl.text.isEmpty ||
                                          double.tryParse(rateOvertimeCtrl.text) == null) {
                                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                                          const SnackBar(
                                            backgroundColor: Colors.red,
                                            content: Text(
                                              'Rate overtime harus angka',
                                              style: TextStyle(color: Colors.white),
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      setDialogState(() {
                                        isSaving = true;
                                      });

                                      try {
                                        final data = {
                                          'name': nameCtrl.text.trim(),
                                          'rate_reguler':
                                              double.tryParse(rateRegulerCtrl.text) ?? 0.0,
                                          'rate_overtime':
                                              double.tryParse(rateOvertimeCtrl.text) ?? 0.0,
                                        };

                                        if (isEdit) {
                                          await PositionService.instance.updatePosition(
                                            pos!.id,
                                            data,
                                          );
                                        } else {
                                          await PositionService.instance.createPosition(
                                            data,
                                          );
                                        }

                                        // Berhasil, kembalikan true
                                        Navigator.pop(dialogContext, true);
                                      } catch (e) {
                                        // Jika error, kembalikan isSaving ke false
                                        setDialogState(() {
                                          isSaving = false;
                                        });
                                        
                                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                                          SnackBar(
                                            backgroundColor: Colors.red,
                                            content: Text(
                                              'Gagal menyimpan: $e',
                                              style: const TextStyle(color: Colors.white),
                                            ),
                                          ),
                                        );
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

    // Jika form disimpan dengan sukses (result = true)
    if (result == true && mounted) {
      // Tampilkan loading
      setState(() {
        _isProcessing = true;
      });

      try {
        // Load ulang data dari server
        await _loadPositions();
        
        setState(() {
          _isProcessing = false;
        });

        // Tampilkan snackbar sukses
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF1B7FA8),
            content: Text(
              isEdit ? 'Posisi berhasil diperbarui' : 'Posisi berhasil ditambahkan',
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

  Future<void> _deletePosition(int id) async {
    // Dapatkan posisi yang akan dihapus untuk ditampilkan di konfirmasi
    final positionToDelete = _positions.firstWhere((pos) => pos.id == id);
    
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
                'Yakin ingin menghapus posisi "${positionToDelete.name}"?',
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
        await PositionService.instance.deletePosition(id);
        
        // Hapus dari local state
        setState(() {
          _positions.removeWhere((pos) => pos.id == id);
          _isProcessing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF1B7FA8),
            content: Text(
              'Posisi "${positionToDelete.name}" berhasil dihapus',
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

  Widget _buildPositionCard(PositionModel position) {
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
                  position.name,
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
                        : () => _showForm(position),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20),
                    color: Colors.red,
                    onPressed: _isProcessing
                        ? null
                        : () => _deletePosition(position.id),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rate Regular',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rp ${position.rateReguler.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
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
                      'Rate Overtime',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rp ${position.rateOvertime.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
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
              style: TextStyle(
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 24),
            CustomButton(
              backgroundColor: const Color(0xFF1B7FA8),
              onPressed: _loadPositions,
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

    if (_positions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.list_alt,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            const Text(
              'Belum ada posisi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Tambahkan posisi pertama Anda',
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
                'List data posisi karyawan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${_positions.length} posisi ditemukan',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            color: const Color(0xFF1B7FA8),
            onRefresh: _loadPositions,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              children: [
                ..._positions.map((position) => _buildPositionCard(position)),
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
          'Kelola Posisi',
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