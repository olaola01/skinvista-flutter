import 'package:flutter/material.dart';
import 'package:skinvista/core/widgets/text_widget.dart';

class ButtonWithoutIcon extends StatelessWidget {
  final String title;
  final Color color;
  final Color buttonColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final Function()? onTap;

  const ButtonWithoutIcon({
    super.key,
    required this.title,
    required this.color,
    required this.buttonColor,
    this.borderRadius,
    this.padding, this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          shadowColor: Colors.transparent,
          backgroundColor: buttonColor,
          padding: padding ?? const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 12),
          ),
        ),
        child: TextWidget(
          text: title,
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    );
  }
}
