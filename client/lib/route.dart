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
import 'package:flutter_secure_storage/flutter_secure_storage.dart';  
import 'package:client/models/employee_model.dart';  
import 'package:client/screens/groupTwo/admin_dashboard_screen.dart';  
import 'package:client/screens/groupTwo/department_crud_screen.dart';  
import 'package:client/screens/groupTwo/edit_admin_employee_screen.dart';  
import 'package:client/screens/groupTwo/edit_personal_screen.dart';  
import 'package:client/screens/groupTwo/employee_detail_screen.dart';  
import 'package:client/screens/groupTwo/employee_list_screen.dart';  
import 'package:client/screens/groupTwo/position_crud_screen.dart';  
import 'package:client/screens/groupTwo/role_selection_screen.dart';  
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'screens/admin_screen.dart';
import 'widgets/navbar_user.dart';

final storage = FlutterSecureStorage();

final GoRouter router = GoRouter(
  initialLocation: "/login",
  redirect: (context, state) {
    return AuthService.instance.redirectUser(state);
  },
  routes: [
    // ========================================
    // ADMIN SHELL ROUTES
    // ========================================
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => Scaffold(
        body: navigationShell,
        bottomNavigationBar: NavbarAdmin(navigationShell: navigationShell),
      ),
      branches: [
        // Branch 1: Admin Dashboard
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: "/admin",
              builder: (context, state) => const AdminScreen(),
            ),
          ],
        ),
        
        // Branch 2: Employee Management
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: "/admin/employee",
              builder: (context, state) => const EmployeeScreen(),
            ),
            // ✅ UPDATED: Profile detail untuk admin view employee
            GoRoute(
              path: "/admin/profile-detail",
              builder: (context, state) {
                final userId = state.extra as int?;
                return ProfileScreen(userId: userId);
              },
            ),
            GoRoute(
              path: "/admin/register",
              builder: (context, state) => const RegisterScreen(),
            ),
            // ✅ EDIT EMPLOYEE (ADMIN MODE)
            GoRoute(
              path: "/admin/edit-employee",
              builder: (context, state) {
                final employeeId = state.extra as int?;
                if (employeeId == null) {
                  return const Scaffold(
                    body: Center(
                      child: Text('Error: ID karyawan tidak ditemukan'),
                    ),
                  );
                }
                return EditAdminEmployeeScreen(employeeId: employeeId);
              },
            ),
          ],
        ),
        
        // Branch 3: Admin Profile & Settings (OWN PROFILE)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: "/admin/profile",
              builder: (context, state) => const ProfileScreen(), // No userId = own profile
            ),
          ],
        ),
        
        // Branch 4: Attendance
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: "/admin/attendance",
              builder: (context, state) => const AttendanceScreen(),
            ),
          ],
        ),
        
        // Branch 5: Schedule
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

    // ========================================
    // USER SHELL ROUTES
    // ========================================
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => Scaffold(
        body: navigationShell,
        bottomNavigationBar: NavbarUser(navigationShell: navigationShell),
      ),
      branches: [
        // Branch 1: Home
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: "/home",
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        
        // Branch 2: Profile (EMPLOYEE OWN PROFILE)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: "/profile",
              builder: (context, state) => const ProfileScreen(), // No userId = own profile
            ),
          ],
        ),
        
        // Branch 3: Attendance
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

    // ========================================
    // NON-SHELL ROUTES (Full Screen)
    // ========================================

    // ✅ EDIT PERSONAL (EMPLOYEE MODE)
    GoRoute(
      path: "/employee/edit-personal/:id",
      builder: (context, state) {
        final employee = state.extra as EmployeeModel?;

        if (employee == null) {
          return const Scaffold(
            body: Center(child: Text('Error: Data karyawan tidak ditemukan')),
          );
        }

        return EditPersonalScreen(employee: employee);
      },
    ),

    // Payroll (requires auth)
    GoRoute(
      path: "/payroll",
      builder: (context, state) => const PayrollScreen(),
    ),

    // Authentication routes (PUBLIC)
    GoRoute(
      path: "/login",
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: "/forgot-password",
      builder: (context, state) => ForgotPasswordScreen(),
    ),
    GoRoute(
      path: "/change-password",
      builder: (context, state) => const ChangePasswordScreen(),
    ),

    // ========================================
    // GROUP TWO ROUTES (LEGACY - OPTIONAL)
    // ========================================

    GoRoute(
      path: "/role-selection",
      builder: (context, state) => const RoleSelectionScreen(),
    ),

    GoRoute(
      path: "/employee-list",
      builder: (context, state) =>
          const EmployeeListScreen(isKaryawanMode: true),
    ),

    // ⚠️ DEPRECATED: Use ProfileScreen instead
    GoRoute(
      path: "/employee-detail/:id",
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;

        if (extra == null) {
          return const Scaffold(
            body: Center(child: Text('Error: Data karyawan tidak ditemukan')),
          );
        }

        final employee = extra['employee'] as EmployeeModel;
        final isKaryawanMode = extra['isKaryawanMode'] as bool;

        return EmployeeDetailScreen(
          initialEmployee: employee,
          isKaryawanMode: isKaryawanMode,
        );
      },
    ),

    GoRoute(
      path: "/admin-dashboard",
      builder: (context, state) => const AdminDashboardScreen(),
    ),

    GoRoute(
      path: "/admin/positions",
      builder: (context, state) => const PositionCrudScreen(),
    ),

    GoRoute(
      path: "/admin/departments",
      builder: (context, state) => const DepartmentCrudScreen(),
    ),

    GoRoute(
      path: "/admin/employee-list",
      builder: (context, state) =>
          const EmployeeListScreen(isKaryawanMode: false),
    ),
  ],
);