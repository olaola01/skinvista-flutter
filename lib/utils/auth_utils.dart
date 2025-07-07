import 'package:shared_preferences/shared_preferences.dart';

class AuthUtils {
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_email');
  }
}