import 'dart:io';
import 'package:flutter/material.dart';
import '../res/styles/app_styles.dart';

class ResultModal extends StatelessWidget {
  final String imagePath;
  final bool isAcceptable;
  final VoidCallback? onProceed;
  final VoidCallback? onRetake;

  const ResultModal({
    super.key,
    required this.imagePath,
    required this.isAcceptable,
    this.onProceed,
    this.onRetake,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppStyles.darkSecondary.withOpacity(0.9), // Darker base from app theme
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppStyles.primaryColor.withOpacity(0.5), width: 2), // Primary blue border
          boxShadow: [
            BoxShadow(
              color: AppStyles.primaryColor.withOpacity(0.3), // Primary blue glow
              blurRadius: 15,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isAcceptable ? AppStyles.success : AppStyles.deepWarning, // Success green or warning yellow
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isAcceptable
                        ? AppStyles.success.withOpacity(0.4)
                        : AppStyles.deepWarning.withOpacity(0.4),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  File(imagePath),
                  width: 220,
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isAcceptable ? "Image Accepted" : "Image Rejected",
              style: TextStyle(
                color: isAcceptable ? AppStyles.success : AppStyles.deepWarning, // Green or yellow
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
                shadows: [
                  Shadow(
                    color: AppStyles.primaryColor.withOpacity(0.5), // Primary blue shadow
                    blurRadius: 5,
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              isAcceptable
                  ? "Ready for analysis."
                  : "Please retake the image.",
              style: TextStyle(
                color: AppStyles.blueGrey50.withOpacity(0.7), // Light grey for secondary text
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isAcceptable && onProceed != null)
                  _buildButton(
                    text: "Proceed",
                    color: AppStyles.success, // Green for proceed
                    onPressed: onProceed!,
                  )
                else if (!isAcceptable && onRetake != null)
                  _buildButton(
                    text: "Retake",
                    color: AppStyles.deepWarning, // Yellow for retake
                    onPressed: onRetake!,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.9),
          foregroundColor: AppStyles.bgColor, // Light background color for contrast
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 5,
          shadowColor: color.withOpacity(0.5),
        ).copyWith(
          overlayColor: WidgetStateProperty.all(color.withOpacity(0.2)),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: AppStyles.bgColor, // Ensure text is readable
          ),
        ),
      ),
    );
  }
}