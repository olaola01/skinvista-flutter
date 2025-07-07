import 'package:flutter/material.dart';
import 'package:skinvista/screens/onboarding/onboarding_screen_three.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../core/res/styles/app_styles.dart';
import 'onboarding_screen_five.dart';
import 'onboarding_screen_four.dart';
import 'onboarding_screen_one.dart';
import 'onboarding_screen_six.dart';
import 'onboarding_screen_two.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  static final PageController _controller = PageController(initialPage: 0);

  final List<Widget> _pages = [
    OnboardingScreenOne(onTap: (){
      _controller.animateToPage(1, duration: const Duration(milliseconds: 500), curve: Curves.easeIn);(duration: const Duration(milliseconds: 500), curve: Curves.easeIn);
    }),
    OnboardingScreenTwo(onTap: (){
      _controller.animateToPage(2, duration: const Duration(milliseconds: 500), curve: Curves.easeIn);(duration: const Duration(milliseconds: 500), curve: Curves.easeIn);
    }),
    OnboardingScreenThree(onTap: (){
      _controller.animateToPage(3, duration: const Duration(milliseconds: 500), curve: Curves.easeIn);(duration: const Duration(milliseconds: 500), curve: Curves.easeIn);
    }),
    OnboardingScreenFour(onTap: (){
      _controller.animateToPage(4, duration: const Duration(milliseconds: 500), curve: Curves.easeIn);(duration: const Duration(milliseconds: 500), curve: Curves.easeIn);
    }),
    OnboardingScreenFive(onTap: (){
      _controller.animateToPage(5, duration: const Duration(milliseconds: 500), curve: Curves.easeIn);(duration: const Duration(milliseconds: 500), curve: Curves.easeIn);
    }),
    OnboardingScreenSix(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.bgColor,
      extendBodyBehindAppBar: true,
      body: Padding(
        padding: const EdgeInsets.only(bottom: 60.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: PageView(
              controller: _controller,
              children: _pages
            )),
            SmoothPageIndicator(
              controller: _controller,
              count: _pages.length,
              effect: JumpingDotEffect(
                dotHeight: 10,
                dotColor: AppStyles.lighterBlue2,
                dotWidth: 10,
                // type: WormType.thinUnderground,
              ),
            ),
          ]
        ),
      ),
    );
  }
}