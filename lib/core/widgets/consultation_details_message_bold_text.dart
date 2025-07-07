import 'package:flutter/material.dart';
import 'package:skinvista/core/widgets/text_widget.dart';

import '../res/styles/app_styles.dart';

class ConsultationDetailsMessageBoldText extends StatelessWidget {
  const ConsultationDetailsMessageBoldText({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return TextWidget(
        text: text,
        color: AppStyles.textColor,
        fontWeight: FontWeight.w700,
        fontSize: 15
    );
  }
}
