import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skinvista/bloc/auth/auth_bloc.dart';
import 'package:skinvista/bloc/auth/auth_event.dart';
import 'package:skinvista/bloc/auth/auth_state.dart';
import '../core/locator.dart';
import '../core/res/media.dart';
import '../core/res/styles/app_styles.dart';
import '../core/widgets/text_widget.dart';
import '../repositories/auth_repository.dart';


class Auth extends StatelessWidget {
  const Auth({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(repository: getIt<AuthRepository>()),
      child: AuthScreen(),
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.bgColor,
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(Media.authImage),
                  fit: BoxFit.cover,
                ),
              ),
              width: double.infinity,
              height: 420,
            ),
            const SizedBox(height: 50),
            TextWidget(
              text: "SkinVista",
              color: AppStyles.textColor,
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
            const SizedBox(height: 10),
            TextWidget(
              text: "Your personal skin health assistant",
              color: AppStyles.blueGrey,
              fontWeight: FontWeight.w400,
              fontSize: 16,
            ),
            const SizedBox(height: 40),
            BlocConsumer<AuthBloc, AuthState>(
              listener: (context, state) async {
                if (state is AuthSuccess) {
                  // Store the token using shared_preferences
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('auth_token', state.tokenResponse.token);
                  await prefs.setString('user_email', _emailController.text);
                  Navigator.pushReplacementNamed(context, '/dashboard');
                } else if (state is AuthFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.error)),
                  );
                }
              },
              builder: (context, state) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white,
                  ),
                  width: 398,
                  child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextWidget(
                            text: "Email Address",
                            color: AppStyles.darkSecondary,
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                          ),
                          const SizedBox(height: 15),
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppStyles.textColor,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppStyles.borderColor,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              hintText: 'Enter your email',
                              hintStyle: GoogleFonts.inter(
                                textStyle: TextStyle(
                                  color: AppStyles.darkSecondary,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                  .hasMatch(value)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          if (state is AuthFailure) ...[
                            const SizedBox(height: 10),
                            Text(
                              state.error,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: state is AuthLoading
                                  ? null
                                  : () {
                                if (_formKey.currentState!.validate()) {
                                  context.read<AuthBloc>().add(
                                    LoginSubmitted(
                                      email: _emailController.text,
                                      scopes: [], // Add scopes if needed
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppStyles.blue,
                                padding:
                                const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: state is AuthLoading
                                  ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                                  : TextWidget(
                                text: "Continue",
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}