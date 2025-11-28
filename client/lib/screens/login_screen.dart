import 'package:client/services/auth_service.dart';
import 'package:client/widgets/custom_button.dart';
import 'package:client/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;

  // @override
  // void initState() {
  //   super.initState();
  //   _emailController.text = '';
  //   _passwordController.text = '';
  // }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> handleLogin() async {
    await AuthService.instance.login(
      _emailController.text,
      _passwordController.text,
    );
  }

  Widget header() {
    return Container(
      margin: EdgeInsets.only(bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: AlignmentGeometry.centerLeft,
            child: Text(
              'Masuk',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
            ),
          ),
          SizedBox(height: 10),
          Align(
            alignment: AlignmentGeometry.centerLeft,
            child: Text(
              'Isi email dan password yang sesuai!',
              style: TextStyle(color: Color.fromRGBO(108, 114, 120, 1)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HRIS', style: TextStyle(fontWeight: FontWeight.bold)),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsetsGeometry.all(20),
          child: Column(
            children: [
              header(),
              // email field
              Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Email',
                      style: TextStyle(color: Color.fromRGBO(108, 114, 120, 1)),
                    ),
                  ),
                  SizedBox(height: 5),
                  CustomTextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                ],
              ),
              SizedBox(height: 20),
              // password field
              Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Password',
                      style: TextStyle(color: Color.fromRGBO(108, 114, 120, 1)),
                    ),
                  ),
                  SizedBox(height: 5),
                  CustomTextField(
                    controller: _passwordController,
                    obscureText: _obscureText,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                        size: 16,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: () {},
                  child: Text(
                    "Lupa Password",
                    style: TextStyle(color: Color.fromRGBO(29, 97, 231, 1)),
                  ),
                ),
              ),

              SizedBox(height: 20),
              // button
              CustomButton(
                backgroundColor: const Color.fromRGBO(29, 97, 231, 1),
                onPressed: handleLogin,
                child: Text("Masuk"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
