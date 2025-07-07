import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skinvista/bloc/diagnosis/save_diagnosis_bloc.dart';
import 'package:skinvista/bloc/diagnosis/save_diagnosis_event.dart';
import 'package:skinvista/bloc/diagnosis/save_diagnosis_state.dart';
import 'package:skinvista/core/res/styles/app_styles.dart';
import 'package:skinvista/core/widgets/button_with_icon.dart';
import 'package:skinvista/core/widgets/result_card.dart';
import 'package:skinvista/core/widgets/result_match_widget.dart';
import 'package:skinvista/core/widgets/text_widget.dart';
import 'dart:io';

import '../core/locator.dart';
import '../helpers/condition_helper.dart';
import '../helpers/string_helper.dart';
import '../repositories/diagnosis_repository.dart';

class ScanResult extends StatelessWidget {
  final String condition;
  final double confidence;
  final String imagePath;

  const ScanResult({
    super.key,
    required this.condition,
    required this.confidence,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    String displayCondition = StringHelper.formatCondition(condition);

    List<String> symptoms = ConditionHelper.getSymptoms(condition);
    List<String> recommendations = ConditionHelper.getRecommendations(condition);

    return BlocProvider(
      create: (context) => SaveDiagnosisBloc(repository: getIt<DiagnosisRepository>()),
      child: Scaffold(
        backgroundColor: AppStyles.bgColor,
        appBar: AppBar(
          title: TextWidget(
            text: "Scan Result",
            color: AppStyles.textColor,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          centerTitle: true,
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(Icons.arrow_back_ios, size: 18),
                onPressed: () {
                  Navigator.pushNamed(context, '/dashboard');
                },
                tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
              );
            },
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 16, bottom: 18),
                  width: double.infinity,
                  height: 68,
                  decoration: BoxDecoration(
                    color: AppStyles.lightWarning,
                  ),
                  child: SizedBox(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          FluentSystemIcons.ic_fluent_error_circle_regular,
                          color: AppStyles.deepWarning,
                          size: 24,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.only(top: 12.5),
                            child: Text(
                              "This is a preliminary AI-generated assessment. Consult a healthcare provider for a full diagnosis",
                              softWrap: true,
                              style: GoogleFonts.inter(
                                textStyle: TextStyle(
                                  color: AppStyles.deepWarning,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 19),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  width: 398,
                  height: 356,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(23),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(23),
                            topRight: Radius.circular(23),
                          ),
                          image: DecorationImage(
                            image: FileImage(File(imagePath)),
                            fit: BoxFit.cover,
                          ),
                        ),
                        width: double.infinity,
                        height: 250,
                      ),
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  TextWidget(
                                    text: displayCondition,
                                    color: AppStyles.textColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 20,
                                  ),
                                  ResultMatchWidget(
                                    match: "${(confidence * 100).toStringAsFixed(0)}% Match",
                                    fontSize: 16,
                                    containerWidth: 118,
                                    containerHeight: 32,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextWidget(
                              text: "Analysis Complete",
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
                const SizedBox(height: 15),
                ResultCard(
                  title: "Observed Symptoms",
                  bulletColor: AppStyles.blue,
                  items: symptoms,
                ),
                const SizedBox(height: 15),
                ResultCard(
                  title: "Recommended Steps",
                  bulletColor: AppStyles.success,
                  items: recommendations,
                ),
                const SizedBox(height: 20),
                BlocConsumer<SaveDiagnosisBloc, SaveDiagnosisState>(
                  listener: (context, state) {
                    if (state is SaveDiagnosisSuccess) {
                      Navigator.pushNamed(context, '/diagnosis_success');
                    } else if (state is SaveDiagnosisFailure) {
                      // Show error message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.error)),
                      );
                    }
                  },
                  builder: (context, state) {
                    return ButtonWithIcon(
                      title: "Save Diagnosis",
                      icon: FluentSystemIcons.ic_fluent_save_regular,
                      color: AppStyles.blue,
                      buttonColor: Colors.white,
                      useBorder: true,
                      onTap: state is SaveDiagnosisLoading
                          ? null
                          : () {
                        context.read<SaveDiagnosisBloc>().add(
                          SaveDiagnosisSubmitted(
                            condition: condition,
                            confidence: confidence * 100,
                            imagePath: imagePath,
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 20),
                // ButtonWithIcon(
                //   title: "Consult with Doctor",
                //   icon: FluentSystemIcons.ic_fluent_chat_regular,
                //   color: Colors.white,
                //   buttonColor: AppStyles.blue,
                //   onTap: () {
                //     Navigator.pushNamed(context, '/select_doctor');
                //   },
                // ),
                // const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}