import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/res/styles/app_styles.dart';
import '../../core/widgets/button_with_icon.dart';
import '../../core/widgets/button_without_icon.dart';
import '../../core/widgets/text_widget.dart';

class OnboardingScreenFour extends StatefulWidget {
  const OnboardingScreenFour({super.key, this.onTap});
  final Function()? onTap;

  @override
  State<OnboardingScreenFour> createState() => _OnboardingState();
}

class _OnboardingState extends State<OnboardingScreenFour> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.bgColor,
      extendBodyBehindAppBar: true,
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center, // Centers the icon inside the circle
                children: [
                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      color: AppStyles.lighterBlue2,
                      border: Border.all(
                        color: AppStyles.blue,
                        width: 0.7,
                      ),
                      borderRadius: BorderRadius.circular(100), // Makes it a circle
                    ),
                  ),
                  Icon(
                    FluentSystemIcons.ic_fluent_reading_mode_filled,
                    size: 80,
                    color: AppStyles.blue,
                  ),
                ],
              ),
              SizedBox(height: 60),
              TextWidget(text: "Get Your Diagnosis", color: AppStyles.textColor, fontWeight: FontWeight.w700, fontSize: 30),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  padding: EdgeInsets.only(top: 12.5),
                  child: Text(
                      "Receive instant analysis of your skin condition with detailed recommendations",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                          textStyle: TextStyle(
                              color: AppStyles.textColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 16))),
                ),
              ),
              const SizedBox(height: 78),
              SizedBox(
                width: double.infinity,
                child: ButtonWithoutIcon(
                  title: "Next",
                  color: Colors.white,
                  buttonColor: AppStyles.blue,
                  onTap: widget.onTap,
                ),
              ),
            ]
        ),
      ),
    );
  }
}
