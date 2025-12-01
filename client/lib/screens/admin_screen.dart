import 'package:client/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: "HRIS"),
      body: const Center(child: Text("Admin")),
    );
  }
}
