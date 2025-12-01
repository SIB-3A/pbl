import 'package:client/services/user_service.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("HRIS")),
      body: FutureBuilder(
        future: UserService.instance.getLoggedInUser(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return Center(
            child: Text(snapshot.data?.data?.employee?.address ?? ""),
          );
        },
      ),
    );
  }
}
