import 'package:flutter/material.dart';
import 'package:skinvista/core/res/styles/app_styles.dart';
import 'package:skinvista/core/widgets/text_widget.dart';

class AppDoubleText extends StatelessWidget {
  final String bigText;
  final String smallText;
  final VoidCallback? onSmallTextTap;

  const AppDoubleText({
    super.key,
    required this.bigText,
    required this.smallText,
    this.onSmallTextTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextWidget(
            text: bigText,
            color: AppStyles.textColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          GestureDetector(
            onTap: onSmallTextTap,
            child: TextWidget(
              text: smallText,
              color: AppStyles.blue,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}