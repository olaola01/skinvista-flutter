import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skinvista/core/widgets/button_with_icon.dart';
import 'package:skinvista/core/widgets/text_widget.dart';

import '../core/res/styles/app_styles.dart';
import '../core/widgets/button_without_icon.dart';

class EmailSuccess extends StatelessWidget {
  const EmailSuccess({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.bgColor,
      extendBodyBehindAppBar: true,
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Stack(
            alignment: Alignment.center,
            // Centers the icon inside the circle
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppStyles.lightSuccess,
                  borderRadius: BorderRadius.circular(100), // Makes it a circle
                ),
              ),
              Icon(
                Icons.check,
                size: 56,
                color: AppStyles.success,
              ),
            ],
          ),
          SizedBox(height: 20),
          TextWidget(
              text: "Email Sent Successfully",
              color: AppStyles.textColor,
              fontWeight: FontWeight.w600,
              fontSize: 24),
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.only(top: 12.5),
            child: Text(
                "Your consultation request has been sent to Dr. Sarah Johnson.",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    textStyle: TextStyle(
                        color: AppStyles.textColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 16))),
          ),
          SizedBox(height: 25),
          ButtonWithIcon(
              title: "View Consultation History",
              icon: FluentSystemIcons.ic_fluent_history_regular,
              color: Colors.white,
              buttonColor: AppStyles.blue,
              onTap: () => {
                Navigator.pushNamed(context, '/consultations')
              }
          ),
          SizedBox(height: 12),
          ButtonWithoutIcon(
              title: "Return to Home",
              color: Colors.black,
              buttonColor: Colors.white,
              onTap: () => {
                Navigator.pushNamed(context, '/dashboard')
              }
          ),
        ]),
      ),
    );
  }
}
