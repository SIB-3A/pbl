import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:client/services/leave_report_service.dart';
import 'package:client/models/leave_report_model.dart';
import 'package:client/utils/api_wrapper.dart';

class AdminIzinDashboard extends StatefulWidget {
  const AdminIzinDashboard({super.key});

  @override
  State<AdminIzinDashboard> createState() => _AdminIzinDashboardState();
}

class _AdminIzinDashboardState extends State<AdminIzinDashboard> {
  late Future<ApiResponse<LeaveReportResponse>> dashboardFuture;

  @override
  void initState() {
    super.initState();
    dashboardFuture = LeaveReportService.instance.getDashboard();
  }

  Future<void> _refresh() async {
    setState(() {
      dashboardFuture = LeaveReportService.instance.getDashboard();
    });
  }

  String _getMonthName(int month) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Ags',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return months[month];
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF00A8E8),
        foregroundColor: Colors.white,
        title: const Text(
          'Laporan Izin',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: FutureBuilder<ApiResponse<LeaveReportResponse>>(
            future: dashboardFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.blue),
                );
              }

              if (!snapshot.hasData || snapshot.data!.success == false) {
                return Center(
                  child: Text(
                    snapshot.data?.message ?? "Terjadi kesalahan",
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              final data = snapshot.data!.data!;
              final totalEmployees = data.totalEmployees;
              final employeesWithLetters = data.totalEmployeesWithLetters;

              return CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // HEADER (SAMA seperti sebelum)
                  SliverToBoxAdapter(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF00A8E8), Color(0xFF00C4D6)],
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(40),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Laporan Statistik Izin',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 18),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'HRIS ANALYTICS',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Update ${DateTime.now().day} ${_getMonthName(DateTime.now().month)} ${DateTime.now().year}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 30),

                            // STAT CARDS (SAMA seperti sebelum)
                            Row(
                              children: [
                                Expanded(
                                  child: _buildCleanStatCard(
                                    icon: Icons.person_outline_rounded,
                                    value: employeesWithLetters.toString(),
                                    total: totalEmployees.toString(),
                                    label: "Karyawan Ajukan Izin",
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildCleanStatCard(
                                    icon: Icons.pending_actions,
                                    value: data.totalLettersApproved.toString(),
                                    total: data.totalLetters.toString(),
                                    label: "Surat Izin yang sudah diterima",
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 40)),

                  // BUTTON SEMUA KARYAWAN (SAMA)
                  SliverToBoxAdapter(
                    child: Center(
                      child: GestureDetector(
                        onTap: () {
                          context.push(
                            "/admin/all-letters",
                            extra: data.allLetters,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00A8E8),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Text(
                            'SEMUA KARYAWAN',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 24)),

                  // GRID DEPARTEMEN (SAMA)
                  SliverPadding(
                    padding: EdgeInsets.only(
                      left: 20,
                      right: 20,
                      bottom: MediaQuery.of(context).padding.bottom + 100,
                    ),
                    sliver: SliverGrid(
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: screenWidth < 380
                            ? 0.85
                            : (screenWidth < 420 ? 0.95 : 1.1),
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final dept = data.departments[index];
                          return _buildDepartmentCard(
                          name: dept["name"],
                          count: dept["count"],
                          onTap: () {
                            // contoh: buka halaman detail departemen
                            context.push(
                              "/admin/department-detail",
                              extra: dept,
                            );
                          },
                        );

                        },
                        childCount: data.departments.length,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // =============================
  //      UI COMPONENTS (SAMA)
  // =============================

  Widget _buildCleanStatCard({
    required IconData icon,
    required String value,
    required String total,
    required String label,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: screenWidth < 380 ? 16 : 20,
        horizontal: screenWidth < 380 ? 12 : 18,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.22),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: screenWidth < 380 ? 28 : 36, color: Colors.white),
              SizedBox(width: screenWidth < 380 ? 8 : 12),
              Text(
                value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth < 380 ? 32 : 42,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Text(
            "/ $total",
            style: TextStyle(
              color: Colors.white70,
              fontSize: screenWidth < 380 ? 14 : 18,
            ),
          ),
          SizedBox(height: screenWidth < 380 ? 6 : 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: screenWidth < 380 ? 12 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDepartmentCard({
  required String name,
  required String count,
  required VoidCallback onTap,
  }) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF00C4D6),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            child: Icon(Icons.person,
                size: 32, color: const Color(0xFF00A8E8)),
          ),
          const SizedBox(height: 12),
          Text(
            count,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}
