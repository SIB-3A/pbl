import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreenAdmin extends StatelessWidget {
  const HomeScreenAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // HEADER (pinned at top)
            SliverToBoxAdapter(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(
                  24,
                  MediaQuery.of(context).padding.top + 20,
                  24,
                  30,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF00A1D6), Color(0xFF00C4D6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Selamat Datang',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'HRIS Sistem',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.white.withOpacity(0.3),
                          child: const Icon(
                            Icons.business,
                            size: 36,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Pilih menu untuk memulai',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // SPACING
            const SliverToBoxAdapter(child: SizedBox(height: 30)),

            // MENU GRID
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: MediaQuery.of(context).size.width > 400
                      ? 1.1
                      : 1.0,
                ),
                delegate: SliverChildListDelegate([
                  // ✅ MENU 1: Laporan Izin
                  _buildMenuCard(
                    context,
                    icon: Icons.analytics,
                    title: 'Laporan Izin',
                    subtitle: 'Lihat laporan dan analisis',
                    color: const Color(0xFF3674B5),
                    onTap: () => context.pushNamed('laporan_izin'),
                  ),

                  // ✅ MENU 2: Kelola Izin
                  _buildMenuCard(
                    context,
                    icon: Icons.assignment,
                    title: 'Kelola Izin',
                    subtitle: 'Kelola pengajuan izin',
                    color: const Color(0xFF3674B5),
                    onTap: () => context.pushNamed('kelola_izin'),
                  ),

                  // ✅ MENU 3: Kelola Posisi (route: /admin/positions)
                  _buildMenuCard(
                    context,
                    icon: Icons.work_outline,
                    title: 'Kelola Posisi',
                    subtitle: 'Manajemen jabatan',
                    color: const Color(0xFF4E71FF),
                    onTap: () => context.push('/admin/positions'),
                  ),

                  // ✅ MENU 4: Kelola Departemen (route: /admin/departments)
                  _buildMenuCard(
                    context,
                    icon: Icons.business_outlined,
                    title: 'Kelola Departemen',
                    subtitle: 'Manajemen departemen',
                    color: const Color(0xFF4E71FF),
                    onTap: () => context.push('/admin/departments'),
                  ),

                  // ✅ MENU 5: Payroll (route: /payroll)
                  _buildMenuCard(
                    context,
                    icon: Icons.payment,
                    title: 'Payroll',
                    subtitle: 'Sistem penggajian',
                    color: const Color(0xFF00A9FF),
                    onTap: () => context.push('/payroll'),
                  ),
                ]),
              ),
            ),

            // SPACING + FOOTER
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.18),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 36, color: Colors.white),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
