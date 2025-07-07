import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/res/media.dart';
import '../../core/res/styles/app_styles.dart';
import '../../core/widgets/button_without_icon.dart';

class OnboardingScreenOne extends StatefulWidget {
  const OnboardingScreenOne({super.key, this.onTap});
  final Function()? onTap;

  @override
  State<OnboardingScreenOne> createState() => _OnboardingState();
}

class _OnboardingState extends State<OnboardingScreenOne> {
  @override
  Widget build(BuildContext context) {
    // Get the screen size using MediaQuery
    final screenSize = MediaQuery.of(context).size;
    final double imagePadding = 13.0;

    return Scaffold(
      backgroundColor: AppStyles.bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Image Section
            Padding(
              padding: EdgeInsets.all(imagePadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left column with two images
                  Expanded(
                    child: Column(
                      children: [
                        SizedBox(
                          height: screenSize.height * 0.27, // 27% of screen height
                          width: screenSize.width * 0.45, // 45% of screen width
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              Media.manFaceImage,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: screenSize.height * 0.27,
                          width: screenSize.width * 0.45,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              Media.legImage,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Right single image
                  Expanded(
                    child: SizedBox(
                      height: screenSize.height * 0.55, // 55% of screen height
                      width: screenSize.width * 0.45,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          Media.womanFaceImage,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Text and Button Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Welcome Text with "SkinVista" in blue
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: "Welcome to ",
                        style: GoogleFonts.inter(
                          textStyle: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w700,
                            fontSize: 28,
                          ),
                        ),
                        children: [
                          TextSpan(
                            text: "SkinVista",
                            style: TextStyle(
                              color: AppStyles.blue,
                              fontWeight: FontWeight.w700,
                              fontSize: 28,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Subtitle
                    Text(
                      "Your AI-powered skin diagnosis assistant",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        textStyle: TextStyle(
                          color: AppStyles.textColor,
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                    // Continue Button
                    SizedBox(
                      width: double.infinity,
                      child: ButtonWithoutIcon(
                        title: "Continue",
                        color: Colors.white,
                        buttonColor: AppStyles.blue,
                        onTap: widget.onTap,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}