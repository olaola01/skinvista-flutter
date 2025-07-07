import 'package:flutter/material.dart';
import 'package:skinvista/core/widgets/text_widget.dart';

import '../res/styles/app_styles.dart';

class ResultMatchWidget extends StatelessWidget {
  final String match;
  final double fontSize;
  final double containerWidth;
  final double containerHeight;

  const ResultMatchWidget({super.key, required this.match, required this.fontSize, this.containerWidth = 90, this.containerHeight = 26});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: containerWidth,
      height: containerHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppStyles.lightPurple,
      ),
      alignment: Alignment.center,
      child: TextWidget(
        text: match,
        color: AppStyles.deepPurple,
        fontSize: fontSize,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
