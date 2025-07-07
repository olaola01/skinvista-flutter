import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skinvista/core/locator.dart';
import 'package:skinvista/core/widgets/start_consultation_card.dart';
import 'package:skinvista/core/widgets/text_widget.dart';
import 'package:skinvista/models/diagnosis.dart';
import 'package:skinvista/repositories/consultation_repository.dart';
import '../core/res/styles/app_styles.dart';
import '../helpers/string_helper.dart';

class SelectDoctor extends StatefulWidget {
  const SelectDoctor({super.key});

  @override
  State<SelectDoctor> createState() => _SelectDoctorState();
}

class _SelectDoctorState extends State<SelectDoctor> {
  late Future<List<Map<String, dynamic>>> _doctorsFuture;

  @override
  void initState() {
    super.initState();
    _doctorsFuture = getIt<ConsultationRepository>().getDoctors();
  }

  @override
  Widget build(BuildContext context) {
    final Diagnosis diagnosis = ModalRoute.of(context)!.settings.arguments as Diagnosis;

    return Scaffold(
      backgroundColor: AppStyles.bgColor,
      appBar: AppBar(
        title: TextWidget(
          text: "Select Doctor",
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
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.only(left: 16, bottom: 18),
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  color: AppStyles.lightBlue,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.only(top: 13),
                      child: Icon(
                        FluentSystemIcons.ic_fluent_pin_regular,
                        color: AppStyles.blue,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 7),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.only(top: 13),
                        child: Row(
                          children: [
                            Text(
                              "Consulting about: ",
                              style: GoogleFonts.inter(
                                textStyle: TextStyle(
                                  color: AppStyles.blue,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Text(
                              StringHelper.formatCondition(diagnosis.condition),
                              style: GoogleFonts.inter(
                                textStyle: TextStyle(
                                  color: AppStyles.blue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
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
              SizedBox(height: 20),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _doctorsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No doctors available'));
                  }

                  final doctors = snapshot.data!;
                  return Column(
                    children: doctors.map((doctor) => Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: StartConsultationCard(
                        doctorName: doctor['name'],
                        doctorSpecialty: doctor['specialty'],
                        doctorId: doctor['id'].toString(),
                        diagnosis: diagnosis,
                      ),
                    )).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}