import 'package:flutter/material.dart';

Color primary = const Color(0xFF687daf);

class AppStyles {
  static Color primaryColor = primary;
  static Color bgColor = const Color(0xFFF2F7FF);
  static Color textColor = const Color(0xFF1D283A);
  static Color blueGrey = const Color(0xFF65758B);
  static Color blueGrey50 = const Color(0xFFF8FAFC);
  static Color blueGreyDark = const Color(0xFF48566A);
  static Color darkSecondary = const Color(0xFF1A1A1A);
  static Color borderColor = const Color(0xFFE1E1E2);
  static Color blue = const Color(0xFF1559EA);
  static Color purple = const Color(0xFFA046F6);
  static Color lightPurple = const Color(0xFFFAF5FF);
  static Color deepPurple = const Color(0xFF8318E7);
  static Color lightWarning = const Color(0xFFFEF6E7);
  static Color deepWarning = const Color(0xFFF3A218);
  static Color success = const Color(0xFF0F973D);
  static Color lightSuccess = const Color(0xFFE7F6EC);
  static Color lightBlue = const Color(0xFFDCEBFE);
  static Color lighterBlue1 = const Color(0xFF91C3FD);
  static Color lighterBlue2 = const Color(0xFFDCEBFE);

  static TextStyle textStyle =
  TextStyle(fontSize: 16, color: textColor, fontWeight: FontWeight.bold);

  static TextStyle textStyleBlueGrey =
  TextStyle(fontSize: 16, color: blueGrey, fontWeight: FontWeight.w500);

  static TextStyle textStyleBlueGreyDark =
  TextStyle(fontSize: 16, color: blueGreyDark, fontWeight: FontWeight.w500);

  static TextStyle bulletPoint =
  TextStyle(fontSize: 30, color: blue, fontWeight: FontWeight.bold);

  static TextStyle headLineStyle3 =
  const TextStyle(fontSize: 17, fontWeight: FontWeight.w500);

  static TextStyle headLineStyle4 =
  const TextStyle(fontSize: 14, fontWeight: FontWeight.w500);
}
