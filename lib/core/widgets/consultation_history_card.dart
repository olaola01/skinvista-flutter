import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:skinvista/core/widgets/text_widget.dart';
import '../res/styles/app_styles.dart';

class ConsultationHistoryCard extends StatelessWidget {
  final String title;
  final String topic;
  final String timeline;
  final VoidCallback? onTap;

  const ConsultationHistoryCard({
    super.key,
    required this.title,
    required this.topic,
    required this.timeline,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        height: 134,
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
                  text: "Regarding: $topic",
                  color: AppStyles.blueGreyDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                const SizedBox(height: 23),
                Row(
                  children: [
                    Icon(
                      FluentSystemIcons.ic_fluent_clock_regular,
                      color: AppStyles.blueGrey,
                      size: 18,
                    ),
                    const SizedBox(width: 5),
                    TextWidget(
                      text: "Sent $timeline",
                      color: AppStyles.blueGrey,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ],
                ),
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