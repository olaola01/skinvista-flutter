import 'package:flutter/material.dart';
import 'package:skinvista/core/widgets/result_match_widget.dart';
import 'package:skinvista/core/widgets/text_widget.dart';

import '../res/styles/app_styles.dart';

class DiagnosisCard extends StatelessWidget {
  final String title;
  final String date;
  final String match;
  final VoidCallback? onTap;

  const DiagnosisCard({
    super.key,
    required this.title,
    required this.date,
    required this.match,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap, // Handle tap event
      borderRadius: BorderRadius.circular(16), // Match the container's border radius for ripple effect
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 11),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                TextWidget(
                  text: title,
                  color: AppStyles.textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                const SizedBox(height: 5),
                TextWidget(
                  text: date,
                  color: AppStyles.blueGrey,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                const SizedBox(height: 23),
                ResultMatchWidget(match: match, fontSize: 14),
              ],
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppStyles.textColor,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}