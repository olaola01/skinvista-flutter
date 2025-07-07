import 'package:flutter/material.dart';
import 'package:skinvista/core/widgets/text_widget.dart';

class ActionCard extends StatelessWidget {
  final String text;
  final Color color;
  final IconData icon;
  final VoidCallback? onTap;

  const ActionCard({
    super.key,
    required this.text,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap, // Handle tap event
      borderRadius: BorderRadius.circular(16), // Match the container's border radius for ripple effect
      child: Container(
        width: 165,
        height: 124,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: color,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 40.0),
            const SizedBox(height: 10),
            TextWidget(
              text: text,
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ],
        ),
      ),
    );
  }
}