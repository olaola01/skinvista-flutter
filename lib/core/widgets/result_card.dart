import 'package:flutter/material.dart';
import 'package:skinvista/core/widgets/text_widget.dart';

import '../res/styles/app_styles.dart';
import 'bullet_list.dart';

class ResultCard extends StatelessWidget {
  final Color bulletColor;
  final List<String> items;
  final String title;

  const ResultCard({super.key, required this.bulletColor, required this.items, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      width: 398,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),
      ),
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 5),
            TextWidget(
                text: title,
                color: AppStyles.textColor,
                fontWeight: FontWeight.w600,
                fontSize: 18),
            SizedBox(height: 10),
            BulletList(
              items: items,
              bulletColor: bulletColor,
            ),
          ],
        ),
      ),
    );
  }
}
