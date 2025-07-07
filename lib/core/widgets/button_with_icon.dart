import 'package:flutter/material.dart';
import 'package:skinvista/core/widgets/text_widget.dart';

class ButtonWithIcon extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Color buttonColor;
  final bool usePadding;
  final bool useBorder;
  final Function()? onTap;

  const ButtonWithIcon({super.key, required this.title, required this.icon, required this.color, required this.buttonColor, this.usePadding = true, this.useBorder = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: usePadding ? EdgeInsets.symmetric(horizontal: 16) : EdgeInsets.zero,
      width: double.infinity,
      height: 58,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: useBorder ? Border.all(
            color: Colors.blue,
            width: 1,
          ) : null,
        ),
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
              shadowColor: Colors.transparent,
              backgroundColor: buttonColor,
              padding: EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              )),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center, // Centers the content
            children: [
              Icon(icon, color: color, size: 24), // Save icon
              const SizedBox(width: 8), // Space between icon and text
              TextWidget(
                text: title,
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
