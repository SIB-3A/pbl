import 'package:client/widgets/navbar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: "/home",
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return Scaffold(
          body: navigationShell,
          bottomNavigationBar: Navbar(navigationShell: navigationShell),
        );
      },
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
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
      ],
    ),

    // non-nav pages (full screen)
    GoRoute(path: "/login", builder: (context, state) => const LoginScreen()),
  ],
);
