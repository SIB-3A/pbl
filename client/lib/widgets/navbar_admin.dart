import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavbarAdmin extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const NavbarAdmin({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: navigationShell.currentIndex,
      type: BottomNavigationBarType.fixed,    
      onTap: (index) {
        navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        );
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.work), label: "Employee"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        BottomNavigationBarItem(icon: Icon(Icons.fingerprint), label: "Attendance"),
        BottomNavigationBarItem(icon: Icon(Icons.schedule), label: "Schedule"),
      ],
    );
  }
}

