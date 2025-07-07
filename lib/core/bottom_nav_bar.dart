import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skinvista/bloc/diagnosis/delete_diagnosis_bloc.dart'; // Add this import
import 'package:skinvista/bloc/diagnosis/fetch_diagnoses_bloc.dart'; // Add this import
import 'package:skinvista/bloc/diagnosis/save_diagnosis_bloc.dart';
import 'package:skinvista/bloc/game_score/save_game_score_bloc.dart';
import 'package:skinvista/bloc/leaderboard/leaderboard_bloc.dart';
import 'package:skinvista/core/locator.dart';
import 'package:skinvista/core/res/styles/app_styles.dart';
import 'package:skinvista/screens/consultations.dart';
import 'package:skinvista/screens/home.dart';
import 'package:skinvista/screens/leaderboard.dart';
import 'package:skinvista/screens/profile.dart';
import 'package:skinvista/screens/scan.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  final appScreens = [
    const Home(),
    const Scan(),
    const LeaderboardPage(),
    const Consultations(),
    const Profile(),
  ];

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<SaveDiagnosisBloc>(),
        ),
        BlocProvider(
          create: (context) => getIt<DeleteDiagnosisBloc>(), // Add this provider
        ),
        BlocProvider(
          create: (context) => getIt<FetchDiagnosesBloc>(), // Add this provider
        ),
        BlocProvider(
          create: (context) => getIt<SaveGameScoreBloc>(),
        ),
        BlocProvider(
          create: (context) => getIt<LeaderboardBloc>(),
        ),
        // Add other BLoCs for Consultations, Profile if needed
      ],
      child: Scaffold(
        body: appScreens[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: AppStyles.blue,
          unselectedItemColor: const Color(0xFF526400),
          showSelectedLabels: false,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(FluentSystemIcons.ic_fluent_home_regular),
              activeIcon: Icon(FluentSystemIcons.ic_fluent_home_filled),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(FluentSystemIcons.ic_fluent_camera_regular),
              activeIcon: Icon(FluentSystemIcons.ic_fluent_camera_filled),
              label: "Scan",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.gamepad),
              activeIcon: Icon(Icons.gamepad),
              label: "Game",
            ),
            BottomNavigationBarItem(
              icon: Icon(FluentSystemIcons.ic_fluent_chat_regular),
              activeIcon: Icon(FluentSystemIcons.ic_fluent_chat_filled),
              label: "Consult",
            ),
            BottomNavigationBarItem(
              icon: Icon(FluentSystemIcons.ic_fluent_person_regular),
              activeIcon: Icon(FluentSystemIcons.ic_fluent_person_filled),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }
}