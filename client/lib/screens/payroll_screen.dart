import 'package:client/models/payroll_model.dart';
import 'package:client/services/position_service.dart';
import 'package:client/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';

class PayrollScreen extends StatelessWidget {
  const PayrollScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: ""),
      backgroundColor: Colors.white,
      body: FutureBuilder(
        future: PositionService.instance.getUserPayroll(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          return payrollSection(context, snapshot.data?.data);
        },
      ),
    );
  }

  Stack payrollSection(BuildContext context, PayrollModel? position) {
    return Stack(
      children: [
        // Background biru atas
        Container(
          height: 200,
          decoration: const BoxDecoration(
            color: Color(0xFF06A8E0),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
        ),

        // Konten utama
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Judul & subtitle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Gaji",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Pembayaran gaji (per jam)",
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),

                    // Logo
                    Image(
                      image: AssetImage("assets/logoPbl.png"),
                      height: 40,
                      color: Colors.white,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Card Putih
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Jabatan
                          const Text(
                            "Jabatan",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            readOnly: true,
                            decoration: InputDecoration(
                              hintText: position?.name,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Gaji Regular
                          const Text(
                            "Gaji Reguler",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDFF6DD),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text("Rp. ${position?.rateReguler} /jam"),
                          ),

                          const SizedBox(height: 16),

                          // Gaji Lembur
                          const Text(
                            "Gaji Lembur",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDFF6DD),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text("Rp. ${position?.rateOvertime} /jam"),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
