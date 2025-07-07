import 'package:flutter/material.dart';
import 'package:skinvista/core/widgets/text_widget.dart';

import '../res/styles/app_styles.dart';

class DiagnosisDetail extends StatelessWidget {
  final String title;
  final String value;

  const DiagnosisDetail({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextWidget(text: title, color: AppStyles.blueGrey, fontWeight: FontWeight.w500, fontSize: 16),
        TextWidget(text: value, color: AppStyles.blueGreyDark, fontWeight: FontWeight.w500, fontSize: 16),
      ],
    );
  }
}
