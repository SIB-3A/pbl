import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF22A9D6),
      body: SafeArea(
        child: Stack(
          children: [
            // ================= MAIN CONTENT =====================
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),

                  // LOGO
                  Row(children: [Image.asset('assets/logo.png', height: 45)]),

                  const SizedBox(height: 25),

                  // TITLE
                  Text(
                    "Lupa Password",
                    style: const TextStyle(
                      fontSize: 28,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Isi email yang terhubung untuk autentikasi\npenggantian password",
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),

                  const SizedBox(height: 30),

                  // ================= WHITE FORM CARD =================
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Email",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // ================= TEXTFIELD WITH SHADOW =================
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF22A9D6),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey, //black.withOpacity(0.3),
                                blurRadius: 5, // seberapa blur bayangannya
                                spreadRadius: 1, // memperluas area bayangan
                                offset: Offset(
                                  0,
                                  0,
                                ), // bayangan dari semua arah
                              ),
                            ],
                          ),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: "Loisbecket@gmail.com",
                              hintStyle: TextStyle(color: Colors.black87),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF22A9D6), Color(0xFF22A9D6)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Color(
                                  0xFF22A9D6,
                                ), //black.withOpacity(0.3),
                                blurRadius: 5, // seberapa blur bayangannya
                                //  spreadRadius: 1, // memperluas area bayangan
                                offset: Offset(
                                  0,
                                  0,
                                ), // bayangan dari semua arah
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              minimumSize: const Size(double.infinity, 50),
                            ),
                            onPressed: () {},
                            child: const Text(
                              "Kirim Pesan",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 100,
                  ), // biar scroll tidak menutupi bottom bar
                ],
              ),
            ),
            
            // ================ FIXED-BOTTOM NAVIGATOR ================
            // Center(
            //   child: Container(
            //     width: size.width * 0.3,
            //     height: 4,
            //     margin: const EdgeInsets.only(bottom: 12),
            //     decoration: BoxDecoration(
            //       color: Colors.black12,
            //       borderRadius: BorderRadius.circular(20),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
