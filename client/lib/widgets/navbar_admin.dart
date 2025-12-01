import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavbarAdmin extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const NavbarAdmin({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: navigationShell.currentIndex,
      onTap: (index) {
        navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        );
      },
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.work), label: "Employee"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Employee"),
      ],
    );
  }
}
