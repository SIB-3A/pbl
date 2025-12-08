import 'package:flutter/material.dart';

class LegendItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const LegendItem({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}