// lib/router.dart
import 'package:go_router/go_router.dart';

import 'package:client/screens/login_screen.dart';
import 'package:client/screens/home_screen.dart';
import 'package:client/screens/placeholder_screen.dart';
import 'package:client/screens/Admin/home_admin.dart';
import 'package:client/screens/Admin/all_letters_page.dart';
//import 'package:client/screens/Admin/home_admin_main_screen.dart';
import 'package:client/screens/Admin/izin_laporan_menu.dart';
import 'package:client/screens/Admin/admin_izin_manager.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),

    // HOME SCREEN WITH 6 MENU BUTTONS
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),

    // EXISTING SCREENS
    GoRoute(
      path: '/laporan-izin',
      name: 'laporan_izin',
      builder: (context, state) => const AdminIzinDashboard(),
    ),

    GoRoute(
      path: '/kelola-izin',
      name: 'kelola_izin',
      builder: (context, state) => const AdminIzinManager(),
    ),

    // PLACEHOLDER ROUTES FOR FUTURE SCREENS
    GoRoute(
      path: '/absensi',
      name: 'absensi',
      builder: (context, state) => const PlaceholderScreen(title: 'Absensi'),
    ),

    GoRoute(
      path: '/karyawan',
      name: 'karyawan',
      builder: (context, state) => const PlaceholderScreen(title: 'Karyawan'),
    ),

    GoRoute(
      path: '/payroll',
      name: 'payroll',
      builder: (context, state) => const PlaceholderScreen(title: 'Payroll'),
    ),

    GoRoute(
      path: '/pengaturan',
      name: 'pengaturan',
      builder: (context, state) => const PlaceholderScreen(title: 'Pengaturan'),
    ),

    GoRoute(
      path: '/admin/all-letters',
      builder: (context, state) {
        final letters = state.extra as List<dynamic>;
        return AllLettersPage(letters: letters);
      },
    ),

    // // ADMIN SHELL (keeping existing structure)
    // ShellRoute(
    //   builder: (context, state, child) => AdminHomeMain(child: child),
    //   routes: [
    //     GoRoute(
    //       path: '/admin-home',
    //       name: 'admin_home',
    //       pageBuilder: (context, state) =>
    //           const NoTransitionPage(child: AdminHomeScreen()),
    //     ),
    //   ],
    // ),
  ],
);