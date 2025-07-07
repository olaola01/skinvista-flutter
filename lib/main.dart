import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skinvista/core/api_client/api_client.dart';
import 'package:skinvista/screens/auth.dart';
import 'package:skinvista/screens/consultation_details.dart';
import 'package:skinvista/screens/consultations.dart';
import 'package:skinvista/screens/diagnosis_details.dart';
import 'package:skinvista/screens/diagnosis_history.dart';
import 'package:skinvista/screens/email_success.dart';
import 'package:skinvista/screens/onboarding/onboarding_page.dart';
import 'package:skinvista/screens/scan.dart';
import 'package:skinvista/screens/scan_result.dart';
import 'package:skinvista/screens/diagnosis_success.dart';
import 'package:skinvista/screens/select_doctor.dart';
import 'package:skinvista/screens/send_consultation_message.dart';
import 'package:skinvista/core/bottom_nav_bar.dart';
import 'package:skinvista/core/locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await setupLocator();
  final String initialRoute = await _determineInitialRoute();
  runApp(MyApp(initialRoute: initialRoute));
}

Future<String> _determineInitialRoute() async {
  final prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('auth_token');

  // If no token exists, go to onboarding
  if (token == null || token.isEmpty) {
    return '/onboarding_page';
  }

  // Optionally, validate the token by making an API call
  try {
    final apiClient = getIt<ApiClient>();
    await apiClient.getJson(endpoint: '/diagnoses'); // Example endpoint
    return '/dashboard';
  } catch (e) {
    await prefs.remove('auth_token');
    return '/onboarding_page';
  }
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SkinVista',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: initialRoute,
      routes: {
        '/onboarding_page': (context) => const OnboardingPage(),
        '/auth': (context) => const Auth(),
        '/dashboard': (context) => BottomNavBar(),
        '/diagnosis_history': (context) => DiagnosisHistory(),
        '/scan': (context) => Scan(),
        '/diagnosis_success': (context) => DiagnosisSuccess(),
        '/select_doctor': (context) => SelectDoctor(),
        '/send_consultation_message': (context) => SendConsultationMessage(),
        '/email_success': (context) => EmailSuccess(),
        '/consultations': (context) => Consultations(),
        '/consultation_details': (context) => ConsultationDetails(),
        '/diagnosis_details': (context) => DiagnosisDetails(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}