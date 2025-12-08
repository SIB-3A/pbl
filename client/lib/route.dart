import 'package:client/screens/employee_screen.dart';
import 'package:client/screens/home_screen.dart';
import 'package:client/screens/login_screen.dart';
import 'package:client/screens/attendance_screen.dart';
import 'package:client/screens/schedule_screen.dart';
import 'package:client/screens/payroll_screen.dart';
import 'package:client/screens/forgot_password_screen.dart';
import 'package:client/screens/profile_screen.dart';
import 'package:client/screens/change_password_screen.dart';
import 'package:client/screens/register_screen.dart';
import 'package:client/services/auth_service.dart';
import 'package:client/widgets/navbar_admin.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'screens/admin_screen.dart';
import 'widgets/navbar_user.dart';

final GoRouter router = GoRouter(
  initialLocation: "/login",
  redirect: (context, state) {
    return AuthService.instance.redirectUser(state);
  },
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
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: "/admin/attendance",
              builder: (context, state) => const AttendanceScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: "/admin/schedule",
              builder: (context, state) => const ScheduleScreen(),
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
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: "/attendance",
              builder: (context, state) => const AttendanceScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: "/payroll",
      builder: (context, state) => const PayrollScreen(),
    ),
    GoRoute(path: "/login", builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: "/forgot-password",
      builder: (context, state) => ForgotPasswordScreen(),
    ),
    GoRoute(
      path: "/change-password",
      builder: (context, state) => const ChangePasswordScreen(),
    ),
  ],
);
