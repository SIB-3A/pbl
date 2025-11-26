import 'package:client/screens/home_screen.dart';
import 'package:client/screens/login_screen.dart';
import 'package:client/screens/Admin/surat_ijin_menu.dart' as admin_ijin;
import 'package:client/screens/Karyawan/surat_ijin_menu.dart' as karyawan_ijin;
import 'package:client/screens/Admin/template_editor.dart';
import 'package:client/screens/Karyawan/employee_izin_form.dart';
import 'package:client/screens/Admin/admin_izin_manager.dart';
import 'package:client/screens/Admin/izin_count_view.dart';
import 'package:client/screens/Admin/home_admin.dart';
import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(
  initialLocation: "/home",
  redirect: (context, state) {
    return;
  },
  routes: [
    GoRoute(
      path: "/",
      name: "home",
      builder: (context, state) => const HomeAdmin(),
    ),
    GoRoute(
      path: "/home",
      name: "home_alt",
      builder: (context, state) => const HomeAdmin(),
    ),
    GoRoute(
      path: "/login",
      name: "login",
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: "/surat-ijin",
      name: "surat_ijin",
      builder: (context, state) => const admin_ijin.SuratIjinMenu(),
      routes: [
        GoRoute(
          path: 'template',
          name: 'si_template',
          builder: (context, state) => const TemplateEditor(),
        ),
        GoRoute(
          path: 'employee',
          name: 'si_employee',
          builder: (context, state) => const EmployeeIzinForm(),
        ),
        GoRoute(
          path: 'admin',
          name: 'si_admin',
          builder: (context, state) => const AdminIzinManager(),
        ),
        GoRoute(
          path: 'count',
          name: 'si_count',
          builder: (context, state) => const IzinCountView(),
        ),
      ],
    ),
  ],
);
