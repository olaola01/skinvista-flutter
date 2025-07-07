import 'package:flutter/material.dart';
import 'package:skinvista/core/res/styles/app_styles.dart';
import 'package:skinvista/core/widgets/text_widget.dart';

class BulletList extends StatelessWidget {
  final List<String> items;
  final Color bulletColor;

  const BulletList({required this.items, required this.bulletColor, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextWidget(
                text: "• ",
                color: bulletColor,
                fontWeight: FontWeight.w500,
                fontSize: 24),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(left: 5, top: 7.5),
                child: TextWidget(
                    text: item,
                    color: AppStyles.textColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 16),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
