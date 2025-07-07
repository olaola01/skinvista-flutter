import 'dart:io';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skinvista/bloc/diagnosis/delete_diagnosis_bloc.dart'; // Import the new bloc
import 'package:skinvista/bloc/diagnosis/delete_diagnosis_event.dart';
import 'package:skinvista/bloc/diagnosis/delete_diagnosis_state.dart';
import 'package:skinvista/core/res/media.dart';
import 'package:skinvista/core/res/styles/app_styles.dart';
import 'package:skinvista/core/widgets/button_with_icon.dart';
import 'package:skinvista/core/widgets/result_card.dart';
import 'package:skinvista/core/widgets/result_match_widget.dart';
import 'package:skinvista/core/widgets/text_widget.dart';
import 'package:skinvista/helpers/condition_helper.dart';
import 'package:skinvista/helpers/string_helper.dart';
import 'package:skinvista/models/diagnosis.dart';
import 'package:skinvista/repositories/diagnosis_repository.dart';
import 'package:intl/intl.dart';
import '../core/locator.dart';

class DiagnosisDetails extends StatefulWidget {
  const DiagnosisDetails({super.key});

  @override
  State<DiagnosisDetails> createState() => _DiagnosisDetailsState();
}

class _DiagnosisDetailsState extends State<DiagnosisDetails> {

  Future<bool?> _showDeleteConfirmationDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Diagnosis'),
          content: const Text(
            'This diagnosis will be permanently wiped from our system. Are you sure you want to proceed?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Cancel
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Proceed
              },
              child: const Text(
                'Proceed',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Retrieve the Diagnosis object passed as an argument
    final Diagnosis diagnosis = ModalRoute.of(context)!.settings.arguments as Diagnosis;

    // Format the condition name using StringHelper
    String displayCondition = StringHelper.formatCondition(diagnosis.condition);

    // Fetch symptoms and recommendations using ConditionHelper
    List<String> symptoms = ConditionHelper.getSymptoms(diagnosis.condition);
    List<String> recommendations = ConditionHelper.getRecommendations(diagnosis.condition);

    // Check if the image file exists
    bool imageExists = false;
    if (diagnosis.imagePath != null && diagnosis.imagePath!.isNotEmpty) {
      print('Checking image path: ${diagnosis.imagePath}');
      File imageFile = File(diagnosis.imagePath!);
      imageExists = imageFile.existsSync();
      if (!imageExists) {
        print('Image does not exist at path: ${diagnosis.imagePath}');
        Directory parentDir = imageFile.parent;
        print('Parent directory exists: ${parentDir.existsSync()}');
      }
    }

    // Show a message if the image is missing
    if (!imageExists && diagnosis.imagePath != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image file not found on device.')),
        );
      });
    }

    return BlocProvider(
      create: (context) => DeleteDiagnosisBloc(repository: getIt<DiagnosisRepository>()),
      child: Scaffold(
        backgroundColor: AppStyles.bgColor,
        appBar: AppBar(
          title: TextWidget(
            text: "Diagnosis Details",
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
                  Navigator.pop(context);
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
                            image: imageExists
                                ? FileImage(File(diagnosis.imagePath!))
                                : const AssetImage(Media.skinDiagnoseImage) as ImageProvider,
                            fit: BoxFit.cover,
                            onError: (exception, stackTrace) {
                              print('Failed to load image: $exception');
                            },
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
                                    match: "${diagnosis.confidence.toStringAsFixed(0)}% Match",
                                    fontSize: 16,
                                    containerWidth: 118,
                                    containerHeight: 32,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextWidget(
                              text: "Date: ${DateFormat('d MMM yyyy').format(diagnosis.createdAt)}",
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
                BlocConsumer<DeleteDiagnosisBloc, DeleteDiagnosisState>(
                  listener: (context, state) {
                    if (state is DeleteDiagnosisSuccess) {
                      // Navigate back to the previous screen (e.g., Home) after deletion
                      Navigator.pop(context);
                      // Optionally, show a success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Diagnosis deleted successfully')),
                      );
                    } else if (state is DeleteDiagnosisFailure) {
                      // Show error message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: ${state.error}')),
                      );
                    }
                  },
                  builder: (context, state) {
                    return ButtonWithIcon(
                      title: "Delete Diagnosis",
                      icon: FluentSystemIcons.ic_fluent_delete_regular,
                      color: Colors.white,
                      buttonColor: Colors.red,
                      onTap: state is DeleteDiagnosisLoading
                          ? null
                          : () async {
                        // Show confirmation dialog
                        final bool? confirmed = await _showDeleteConfirmationDialog(context);
                        if (confirmed == true) {
                          // Trigger the delete event
                          context.read<DeleteDiagnosisBloc>().add(
                            DeleteDiagnosisSubmitted(diagnosisId: diagnosis.id, imagePath: diagnosis.imagePath),
                          );
                        }
                      },
                    );
                  },
                ),
                const SizedBox(height: 20),
                ButtonWithIcon(
                  title: "Consult with Doctor",
                  icon: FluentSystemIcons.ic_fluent_chat_regular,
                  color: Colors.white,
                  buttonColor: AppStyles.blue,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/select_doctor',
                      arguments: diagnosis,
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}