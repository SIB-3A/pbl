import 'package:client/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool isObscure = true;

  // --------- CENTRALIZED VALIDATOR ---------- //
  String? Function(String?) requiredField(String label) {
    return FormBuilderValidators.required(errorText: "$label harus diisi");
  }

  // --------- HANDLE REGISTER ---------- //
  void handleRegister() {
    if (!_formKey.currentState!.saveAndValidate()) return;

    final form = _formKey.currentState!.value;
    print("REGISTER DATA:");
    print(form);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // =============== CUSTOM APPBAR =============== //
      appBar: const CustomAppbar(
        title: "Tambah Data Karyawan", // judul hanya di sini
      ),

      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // =============== HEADER BARU =============== //
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 16, bottom: 22),
                decoration: const BoxDecoration(
                  color: Color(0xFF22A9D6),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    // LOGO PUTIH
                    SizedBox(
                      height: 55,
                      child: Image.asset('assets/logoputih.png'),
                    ),
                    const SizedBox(height: 14),

                    // DESKRIPSI SINGKAT (tanpa judul)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 26),
                      child: Text(
                        "Lengkapi data karyawan dengan benar ",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // =============== FORM =============== //
              Padding(
                padding: const EdgeInsets.all(20),
                child: FormBuilder(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 10),

                      // Nama Depan & Belakang
                      _formNameFields(),

                      // Email
                      _formTextField(
                        name: "email",
                        label: "Email",
                        keyboardType: TextInputType.emailAddress,
                        validator: FormBuilderValidators.compose([
                          requiredField("Email"),
                          FormBuilderValidators.email(
                            errorText: "Email tidak valid",
                          ),
                        ]),
                      ),

                      // Gender
                      _formDropdownGender(),

                      // Alamat
                      _formTextField(name: "alamat", label: "Alamat"),

                      // Jabatan
                      _formDropdownJabatan(),

                      // Departemen
                      _formDropdownDepartemen(),

                      // Password
                      _formPasswordField(),

                      const SizedBox(height: 25),

                      // BUTTON REGISTER
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                              0xFF22A9D6,
                            ), // 🔵 warna disamakan
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: handleRegister,
                          child: const Text(
                            "Daftar Karyawan Baru",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------- REUSABLE FIELD -------------- //

  Widget _formTextField({
    required String name,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          FormBuilderTextField(
            name: name,
            keyboardType: keyboardType,
            validator: validator ?? requiredField(label),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _formDropdownGender() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Jenis Kelamin",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          FormBuilderDropdown<String>(
            name: "jenis_kelamin",
            validator: requiredField("Jenis Kelamin"),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            hint: const Text("Pilih"),
            items: const [
              DropdownMenuItem(value: "P", child: Text("Pria")),
              DropdownMenuItem(value: "L", child: Text("Wanita")),
            ],
          ),
        ],
      ),
    );
  }

  Widget _formPasswordField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Set Password",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          FormBuilderTextField(
            name: "password",
            obscureText: isObscure,
            validator: FormBuilderValidators.compose([
              requiredField("Password"),
              FormBuilderValidators.minLength(
                6,
                errorText: "Password minimal 6 karakter",
              ),
            ]),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.shade100,
              suffixIcon: IconButton(
                icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => isObscure = !isObscure),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =============== NAME FIELD (ROW) =============== //
  Widget _formNameFields() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Nama Depan",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                FormBuilderTextField(
                  name: "nama_depan",
                  validator: requiredField("Nama Depan"),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Nama Belakang",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                FormBuilderTextField(
                  name: "nama_belakang",
                  validator: requiredField("Nama Belakang"),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =============== JABATAN DROPDOWN =============== //
  Widget _formDropdownJabatan() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Jabatan", style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          FormBuilderDropdown<String>(
            name: "jabatan",
            validator: requiredField("Jabatan"),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            hint: const Text("Pilih Jabatan"),
            items: const [
              DropdownMenuItem(value: "manager", child: Text("Manager")),
              DropdownMenuItem(value: "supervisor", child: Text("Supervisor")),
              DropdownMenuItem(value: "staff", child: Text("Staff")),
              DropdownMenuItem(value: "intern", child: Text("Intern")),
            ],
          ),
        ],
      ),
    );
  }

  // =============== DEPARTEMEN DROPDOWN =============== //
  Widget _formDropdownDepartemen() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Departemen",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          FormBuilderDropdown<String>(
            name: "departemen",
            validator: requiredField("Departemen"),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            hint: const Text("Pilih Departemen"),
            items: const [
              DropdownMenuItem(value: "hr", child: Text("HR")),
              DropdownMenuItem(value: "finance", child: Text("Finance")),
              DropdownMenuItem(value: "it", child: Text("IT")),
              DropdownMenuItem(value: "marketing", child: Text("Marketing")),
            ],
          ),
        ],
      ),
    );
  }
}
