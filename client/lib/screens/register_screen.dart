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
    // TODO: call your API here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppbar(title: "Daftar Akun Karyawan"),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: FormBuilder(
            key: _formKey,
            child: Column(
              children: [
                // LOGO
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 20),
                  child: Center(
                    child: SizedBox(
                      height: 60,
                      child: Image.asset('assets/logoo.png'),
                    ),
                  ),
                ),

                const Text(
                  "Daftar akun karyawan\n*hanya admin yang bisa menambahkan data",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),

                const SizedBox(height: 20),

                // --------- FORM FIELDS ---------- //
                _formTextField(name: "nama", label: "Nama Panjang"),

                _formTextField(
                  name: "email",
                  label: "Email",
                  keyboardType: TextInputType.emailAddress,
                  validator: FormBuilderValidators.compose([
                    requiredField("Email"),
                    FormBuilderValidators.email(errorText: "Email tidak valid"),
                  ]),
                ),

                _formDropdownGender(),

                _formTextField(name: "alamat", label: "Alamat"),

                _formTextField(name: "jabatan", label: "Jabatan"),

                _formTextField(name: "departemen", label: "Departemen"),

                _formPasswordField(),

                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0094FF),
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
      ),
    );
  }

  // ---------- REUSABLE FORM FIELD COMPONENTS ---------- //

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
}
