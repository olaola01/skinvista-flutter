import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TextWidget extends StatelessWidget {

  final String text;
  final Color color;
  final FontWeight fontWeight;
  final double fontSize;
  final TextAlign? textAlign;

  const TextWidget({super.key, required this.text, required this.color, required this.fontWeight, required this.fontSize, this.textAlign});

  @override
  Widget build(BuildContext context) {
    return Text(text,
        softWrap: true,
        textAlign: textAlign,
        style: GoogleFonts.inter(
            textStyle: TextStyle(
                color: color,
                fontWeight: fontWeight,
                fontSize: fontSize,
            ),
        )
    );
  }
}