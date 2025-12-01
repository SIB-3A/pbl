import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final String name;
  final String position;
  final String? imageUrl;

  final VoidCallback? onTap;
  final VoidCallback? onInfoTap;
  final VoidCallback? onActionTap;

  final IconData infoIcon;
  final IconData actionIcon;

  const CustomCard({
    super.key,
    required this.name,
    required this.position,
    this.imageUrl,
    this.onTap,
    this.onInfoTap,
    this.onActionTap,
    this.infoIcon = Icons.info_outline,
    this.actionIcon = Icons.sync,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.blue.shade300, width: 2),
          color: Colors.white,
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 26,
              backgroundColor: Colors.grey.shade300,
              backgroundImage: (imageUrl != null && imageUrl!.isNotEmpty)
                  ? NetworkImage(imageUrl!)
                  : null,
              child: (imageUrl == null || imageUrl!.isEmpty)
                  ? const Icon(Icons.person, size: 30, color: Colors.white)
                  : null,
            ),

            const SizedBox(width: 12),

            // Name + Position
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(position, style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
            ),

            // Info Icon (optional)
            if (onInfoTap != null)
              IconButton(
                onPressed: onInfoTap,
                icon: Icon(infoIcon, color: Colors.blue),
              ),

            // Action Icon (optional)
            if (onActionTap != null)
              IconButton(
                onPressed: onActionTap,
                icon: Icon(actionIcon, color: Colors.blue),
              ),
          ],
        ),
      ),
    );
  }
}
