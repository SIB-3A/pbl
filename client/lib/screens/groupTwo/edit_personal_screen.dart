import 'dart:io';

import 'package:client/models/employee_model.dart';
import 'package:client/services/employee_service.dart';
import 'package:client/widgets/custom_button.dart';
import 'package:client/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class EditPersonalScreen extends StatefulWidget {
  final EmployeeModel employee;
  const EditPersonalScreen({super.key, required this.employee});

  @override
  State<EditPersonalScreen> createState() => _EditPersonalScreenState();
}

class _EditPersonalScreenState extends State<EditPersonalScreen> {
  late TextEditingController _firstNameCtrl;
  late TextEditingController _lastNameCtrl;
  late TextEditingController _addressCtrl;
  String? _gender;
  bool _isLoading = false;

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _firstNameCtrl = TextEditingController(text: widget.employee.firstName);
    _lastNameCtrl = TextEditingController(text: widget.employee.lastName);
    _addressCtrl = TextEditingController(text: widget.employee.address);
    _gender = widget.employee.gender;
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? picked =
          await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (picked != null) {
        setState(() => _selectedImage = File(picked.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal pilih gambar: $e')));
      }
    }
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);

    try {
      final data = <String, dynamic>{};

      if (_gender != null) data['gender'] = _gender;
      if (_firstNameCtrl.text.trim().isNotEmpty)
        data['first_name'] = _firstNameCtrl.text.trim();
      if (_lastNameCtrl.text.trim().isNotEmpty)
        data['last_name'] = _lastNameCtrl.text.trim();
      if (_addressCtrl.text.trim().isNotEmpty)
        data['address'] = _addressCtrl.text.trim();

      // Panggil service dengan support upload file
      final response = await EmployeeService.instance.updateProfile(
        widget.employee.id,
        data,
        profilePhoto: _selectedImage,
      );

      if (!mounted) return;

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data pribadi berhasil diperbarui')),
        );

        // RETURN TRUE untuk tanda berhasil
        context.pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildAvatar() {
    final hasLocal = _selectedImage != null;
    final hasRemote = widget.employee.profilePhotoUrl != null && !hasLocal;

    ImageProvider? imageProvider;
    if (hasLocal) {
      imageProvider = FileImage(_selectedImage!);
    } else if (hasRemote) {
      imageProvider = NetworkImage(widget.employee.profilePhotoUrl!);
    }

    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: const Color(0xFF1B7FA8),
            backgroundImage: imageProvider,
            child: imageProvider == null
                ? Text(
                    widget.employee.fullName.isNotEmpty
                        ? widget.employee.fullName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          Positioned(
            bottom: -2,
            right: -2,
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 20,
                  color: Color(0xFF1B7FA8),
                ),
              ),
            ),
          ),
        ],
      ),
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
          'Edit Data Pribadi',
          style: TextStyle(color: Colors.white),
        ),
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
                          _buildAvatar(),
                          const SizedBox(height: 24),

                          // Input fields
                          CustomTextField(
                            controller: _firstNameCtrl,
                            label: "Nama Depan",
                            hintText: "Masukkan nama depan",
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _lastNameCtrl,
                            label: "Nama Belakang",
                            hintText: "Masukkan nama belakang",
                          ),
                          const SizedBox(height: 16),

                          // Gender
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Jenis Kelamin",
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                value: _gender,
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
                                items: const [
                                  DropdownMenuItem(
                                      value: 'L', child: Text('Laki-laki')),
                                  DropdownMenuItem(
                                      value: 'P', child: Text('Perempuan')),
                                ],
                                onChanged: (val) => setState(() => _gender = val),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          CustomTextField(
                            controller: _addressCtrl,
                            label: "Alamat",
                            hintText: "Masukkan alamat lengkap",
                            maxLines: 3,
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
}
