import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:skinvista/core/res/media.dart';
import 'package:skinvista/core/res/styles/app_styles.dart';
import 'package:skinvista/core/widgets/consultation_details_message_bold_text.dart';
import 'package:skinvista/core/widgets/consultation_details_message_text.dart';
import 'package:skinvista/core/widgets/text_widget.dart';
import 'package:skinvista/helpers/condition_helper.dart';
import 'package:skinvista/helpers/string_helper.dart';
import 'package:skinvista/models/consultation.dart';

class ConsultationDetails extends StatelessWidget {
  const ConsultationDetails({super.key});

  @override
  Widget build(BuildContext context) {
    final Consultation consultation = ModalRoute.of(context)!.settings.arguments as Consultation;

    String condition = StringHelper.formatCondition(consultation.diagnosisCondition);
    String confidence = "${consultation.diagnosisConfidence.toStringAsFixed(0)}%";
    String date = DateFormat('MMM d, yyyy').format(consultation.sentAt);
    List<String> symptoms = ConditionHelper.getSymptoms(consultation.diagnosisCondition);

    ImageProvider imageProvider = const AssetImage(Media.skinDiagnoseImage);
    bool imageExists = false;

    if (consultation.imageAuthorized && consultation.imagePath != null && consultation.imagePath!.isNotEmpty) {
      // Check if imagePath is a URL (starts with http or https)
      if (consultation.imagePath!.startsWith('http')) {
        imageProvider = NetworkImage(consultation.imagePath!);
        imageExists = true;
      } else {
        // Assume local file path
        File imageFile = File(consultation.imagePath!);
        imageExists = imageFile.existsSync();
        if (imageExists) {
          imageProvider = FileImage(imageFile);
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Local image file not found on device.')),
            );
          });
        }
      }
    }

    return Scaffold(
      backgroundColor: AppStyles.bgColor,
      appBar: AppBar(
        title: TextWidget(
          text: "Consultation Details",
          color: AppStyles.textColor,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => Navigator.pop(context),
          tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(height: 19),
                Container(
                  width: 398,
                  height: 290,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                        width: double.infinity,
                        height: 200,
                      ),
                      SizedBox(height: 5),
                      Container(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  TextWidget(
                                    text: "Attached Image",
                                    color: AppStyles.textColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 5),
                            TextWidget(
                              text: "Diagnosis scan from $date",
                              color: AppStyles.blueGrey,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 13),
                Container(
                  width: 398,
                  height: 510,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextWidget(
                          text: "Message Content",
                          color: AppStyles.textColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                        SizedBox(height: 20),
                        Container(
                          width: 358,
                          height: 420,
                          decoration: BoxDecoration(
                            color: AppStyles.blueGrey50,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 10),
                                ConsultationDetailsMessageText(text: "Hi ${consultation.doctorName}"),
                                SizedBox(height: 15),
                                ConsultationDetailsMessageText(
                                  text: "I would like to consult about my recent skin diagnosis:",
                                ),
                                SizedBox(height: 20),
                                ConsultationDetailsMessageBoldText(text: "Diagnosis: $condition"),
                                ConsultationDetailsMessageText(text: "Confidence: $confidence"),
                                ConsultationDetailsMessageText(text: "Date: $date"),
                                SizedBox(height: 20),
                                ConsultationDetailsMessageBoldText(text: "Observed Symptoms:"),
                                ...symptoms.map((symptom) => ConsultationDetailsMessageText(text: "- $symptom")),
                                SizedBox(height: 20),
                                ConsultationDetailsMessageBoldText(text: "Additional concerns:"),
                                ConsultationDetailsMessageText(
                                  text: consultation.notes ?? "No additional concerns provided.",
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}