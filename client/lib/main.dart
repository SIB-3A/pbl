import 'package:client/route.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: "HRIS",
      routerConfig: router,
      theme: ThemeData(textTheme: GoogleFonts.interTextTheme()),
    );
  }
}
