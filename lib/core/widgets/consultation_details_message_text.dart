import 'package:flutter/material.dart';
import 'package:skinvista/core/widgets/text_widget.dart';

import '../res/styles/app_styles.dart';

class ConsultationDetailsMessageText extends StatelessWidget {
  const ConsultationDetailsMessageText({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return TextWidget(
        text: text,
        color: AppStyles.textColor,
        fontWeight: FontWeight.w500,
        fontSize: 15
    );
  }
}
