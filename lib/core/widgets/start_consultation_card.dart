import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:skinvista/core/widgets/text_widget.dart';
import 'package:skinvista/models/diagnosis.dart';
import '../../helpers/string_helper.dart';
import '../res/styles/app_styles.dart';
import 'button_with_icon.dart';

class StartConsultationCard extends StatelessWidget {
  final String doctorName;
  final String doctorSpecialty;
  final String doctorId;
  final Diagnosis diagnosis;

  const StartConsultationCard({
    super.key,
    required this.doctorName,
    required this.doctorSpecialty,
    required this.doctorId,
    required this.diagnosis,
  });

  Future<bool?> _showAuthorizationDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Authorize Sharing'),
          content: Text(
            'Do you authorize sharing the picture of your skin condition (${StringHelper.formatCondition(diagnosis.condition)}) and related diagnosis details with the doctor?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Authorize',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextWidget(
            text: doctorName,
            color: AppStyles.textColor,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
          TextWidget(
            text: doctorSpecialty,
            color: AppStyles.blueGrey,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          const SizedBox(height: 10),
          ButtonWithIcon(
            title: "Start Consultation",
            icon: FluentSystemIcons.ic_fluent_chat_regular,
            color: Colors.white,
            buttonColor: AppStyles.blue,
            onTap: () async {
              final bool? authorized = await _showAuthorizationDialog(context);
              if (authorized == true) {
                Navigator.pushNamed(
                  context,
                  '/send_consultation_message',
                  arguments: {
                    'diagnosis': diagnosis,
                    'doctorName': doctorName,
                    'doctorSpecialty': doctorSpecialty,
                    'doctorId': doctorId,
                    'imageAuthorized': true,
                  },
                );
              }
            },
          ),
        ],
      ),
    );
  }
}