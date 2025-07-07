import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:skinvista/bloc/consultation/create_consultation_bloc.dart';
import 'package:skinvista/core/locator.dart';
import 'package:skinvista/core/widgets/button_with_icon.dart';
import 'package:skinvista/core/widgets/text_widget.dart';
import 'package:skinvista/models/diagnosis.dart';
import '../bloc/consultation/create_consultation_event.dart';
import '../bloc/consultation/create_consultation_state.dart';
import '../core/res/media.dart';
import '../core/res/styles/app_styles.dart';
import '../core/widgets/diagnosis_detail.dart';
import '../core/widgets/result_card.dart';
import '../helpers/condition_helper.dart';
import '../helpers/string_helper.dart';

class SendConsultationMessage extends StatelessWidget {
  const SendConsultationMessage({super.key});

  @override
  Widget build(BuildContext context) {
    // Retrieve the arguments (diagnosis and doctor details)
    final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    final Diagnosis diagnosis = arguments['diagnosis'] as Diagnosis;
    final String doctorName = arguments['doctorName'] as String;
    final String doctorSpecialty = arguments['doctorSpecialty'] as String;
    final String doctorId = arguments['doctorId'] as String;
    final bool imageAuthorized = arguments['imageAuthorized'] as bool;

    // Format diagnosis details
    String condition = StringHelper.formatCondition(diagnosis.condition);
    String confidence = "${diagnosis.confidence.toStringAsFixed(0)}%";
    String date = DateFormat('d MMM yyyy').format(diagnosis.createdAt); // Use DateTime
    // Fetch symptoms locally since they are not stored on the backend
    List<String> symptoms = ConditionHelper.getSymptoms(diagnosis.condition);

    // Check if the image file exists
    bool imageExists = false;
    ImageProvider imageProvider = const AssetImage(Media.skinDiagnoseImage);
    if (diagnosis.imagePath != null && diagnosis.imagePath!.isNotEmpty) {
      File imageFile = File(diagnosis.imagePath!);
      imageExists = imageFile.existsSync();
      if (imageExists) {
        imageProvider = FileImage(imageFile);
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image file not found on device.')),
          );
        });
      }
    }

    final TextEditingController notesController = TextEditingController();

    return BlocProvider(
      create: (context) => getIt<CreateConsultationBloc>(),
      child: Scaffold(
        backgroundColor: AppStyles.bgColor,
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextWidget(
                text: doctorName,
                color: AppStyles.textColor,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
              TextWidget(
                text: doctorSpecialty,
                color: AppStyles.blueGrey,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ],
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 18),
            onPressed: () => Navigator.pop(context),
            tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 20),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  width: double.infinity,
                  height: 440,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 15),
                        TextWidget(
                          text: "Diagnosis Details",
                          color: AppStyles.textColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                        SizedBox(height: 15),
                        DiagnosisDetail(title: "Condition", value: condition),
                        SizedBox(height: 15),
                        DiagnosisDetail(title: "Confidence", value: confidence),
                        SizedBox(height: 15),
                        DiagnosisDetail(title: "Date", value: date),
                        SizedBox(height: 25),
                        TextWidget(
                          text: "Attached Image:",
                          color: AppStyles.blueGrey,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                        SizedBox(height: 15),
                        Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 15),
                ResultCard(
                  title: "Observed Symptoms",
                  bulletColor: AppStyles.blue,
                  items: symptoms,
                ),
                SizedBox(height: 15),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  width: 398,
                  height: 184,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 5),
                        TextWidget(
                          text: "Additional Notes",
                          color: AppStyles.textColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                        SizedBox(height: 10),
                        TextField(
                          controller: notesController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: "Add any specific concerns or questions you have...",
                            hintStyle: GoogleFonts.inter(
                              textStyle: TextStyle(
                                color: AppStyles.darkSecondary,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppStyles.borderColor,
                                width: 0.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppStyles.blueGrey,
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 15),
                BlocConsumer<CreateConsultationBloc, CreateConsultationState>(
                  listener: (context, state) {
                    if (state is CreateConsultationSuccess) {
                      Navigator.pushNamed(context, '/email_success');
                    } else if (state is CreateConsultationFailure) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: ${state.error}')),
                      );
                    }
                  },
                  builder: (context, state) {
                    return ButtonWithIcon(
                      title: "Send Email",
                      icon: Icons.send,
                      color: Colors.white,
                      buttonColor: AppStyles.blue,
                      onTap: state is CreateConsultationLoading
                          ? null
                          : () {
                        context.read<CreateConsultationBloc>().add(
                          CreateConsultationSubmitted(
                            doctorId: doctorId,
                            diagnosisId: diagnosis.id,
                            notes: notesController.text,
                            imageAuthorized: imageAuthorized,
                            imagePath: diagnosis.imagePath,
                          ),
                        );
                      },
                    );
                  },
                ),
                SizedBox(height: 15),
              ],
            ),
          ),
        ),
      ),
    );
  }
}