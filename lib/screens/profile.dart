import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../bloc/user/withdraw_bloc.dart';
import '../core/locator.dart';
import '../core/res/styles/app_styles.dart';
import '../core/widgets/button_with_icon.dart';
import '../core/widgets/text_widget.dart';
import '../utils/auth_utils.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
  }

  Future<void> _loadUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userEmail = prefs.getString('user_email') ?? 'No email found';
    });
  }

  Future<void> _logout(BuildContext context) async {
    await AuthUtils.logout();
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/auth',
          (Route<dynamic> route) => false,
    );
  }

  Future<void> _withdraw(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Withdrawal'),
        content: Text(
          'Are you sure you want to withdraw from the study? This action is irreversible, and all your related data will be deleted. You will not be able to continue participating in the study.',
          style: TextStyle(color: AppStyles.textColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: AppStyles.blue)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Withdraw', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      context.read<WithdrawBloc>().add(WithdrawStarted());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<WithdrawBloc>(),
      child: Builder(
        builder: (context) => BlocListener<WithdrawBloc, WithdrawState>(
          listener: (context, state) {
            if (state is WithdrawLoading) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Processing withdrawal...')),
              );
            } else if (state is WithdrawSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
              _logout(context);
            } else if (state is WithdrawFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to withdraw: ${state.error}')),
              );
            }
          },
          child: Scaffold(
            backgroundColor: AppStyles.bgColor,
            appBar: AppBar(
              title: TextWidget(
                text: "Profile",
                color: AppStyles.textColor,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
              centerTitle: true,
            ),
            body: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(23),
                    ),
                    width: double.infinity,
                    height: 228,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: AppStyles.lightBlue,
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                            Icon(
                              FluentSystemIcons.ic_fluent_person_regular,
                              size: 56,
                              color: AppStyles.blue,
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        TextWidget(
                          text: _userEmail ?? 'Loading...',
                          color: AppStyles.textColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  ButtonWithIcon(
                    title: "Withdraw from study",
                    icon: Icons.cancel,
                    color: Colors.white,
                    buttonColor: Colors.red,
                    onTap: () => _withdraw(context),
                  ),
                  const SizedBox(height: 15),
                  ButtonWithIcon(
                    title: "Log out",
                    icon: FluentSystemIcons.ic_fluent_power_regular,
                    color: Colors.red,
                    buttonColor: Colors.white,
                    onTap: () => _logout(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}