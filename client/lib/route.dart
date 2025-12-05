// lib/router.dart
import 'package:client/screens/employee_screen.dart';
import 'package:client/screens/login_screen.dart';
import 'package:client/screens/forgot_password_screen.dart';
import 'package:client/screens/profile_screen.dart';
import 'package:client/screens/change_password_screen.dart';
import 'package:client/screens/register_screen.dart';
import 'package:client/services/auth_service.dart';
import 'package:client/widgets/navbar_admin.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'screens/admin_screen.dart';
import 'widgets/navbar_user.dart';
import 'package:client/screens/login_screen.dart';
import 'package:client/screens/placeholder_screen.dart';
import 'package:client/screens/Group_1/home_screen.dart';
import 'package:client/screens/Group_1/Admin/all_letters_page.dart';
import 'package:client/screens/Group_1/Admin/add_template_screen.dart';
import 'package:client/screens/Group_1/Admin/list_template_screen.dart';
import 'package:client/screens/Group_1/Admin/edit_template_screen.dart';
import 'package:client/screens/Group_1/Admin/izin_laporan_menu.dart';
import 'package:client/screens/Group_1/Admin/admin_izin_manager.dart';
import 'package:client/screens/Group_1/Admin/department_detail_page.dart';


final storage = FlutterSecureStorage();

final GoRouter router = GoRouter(
  initialLocation: "/home",

  // redirect: (context, state) {
  //   return AuthService.instance.redirectUser(state);
  // },
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => Scaffold(
        body: navigationShell,
        bottomNavigationBar: NavbarAdmin(navigationShell: navigationShell),
      ),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: "/admin",
              builder: (context, state) => const AdminScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: "/admin/employee",
              builder: (context, state) => const EmployeeScreen(),
            ),
            GoRoute(
              path: "/admin/profile-detail",
              builder: (context, state) {
                return ProfileScreen(userId: state.extra as int);
              },
            ),
            GoRoute(
              path: "/admin/register",
              builder: (context, state) => const RegisterScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: "/admin/profile",
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => Scaffold(
        body: navigationShell,
        bottomNavigationBar: NavbarUser(navigationShell: navigationShell),
      ),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: "/home",
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: "/profile",
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),

    GoRoute(path: "/login", builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: "/forgot-password",
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: "/change-password",
      builder: (context, state) => const ChangePasswordScreen(),
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

    GoRoute(
      path: '/admin/template/add',
      builder: (context, state) => const AddTemplateScreen(),
    ),

    GoRoute(
      path: '/admin/template/list',
      builder: (context, state) => const ListTemplateScreen(),
    ),

    GoRoute(
  path: "/admin/template/edit",
  builder: (context, state) {
    final data = state.extra as Map;
    return EditTemplateScreen(template: data);
  },
  ),

  GoRoute(
    path: '/admin/department-detail',
    builder: (context, state) {
      final dept = state.extra as Map<String, dynamic>;
      return DepartmentDetailPage(departmentData: dept);
    },
  ),


  ],
);
