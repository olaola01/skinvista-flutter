import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skinvista/bloc/diagnosis/fetch_diagnoses_bloc.dart';
import 'package:skinvista/bloc/diagnosis/fetch_diagnoses_event.dart';
import 'package:skinvista/bloc/diagnosis/fetch_diagnoses_state.dart';
import 'package:skinvista/core/res/styles/app_styles.dart';
import 'package:skinvista/core/widgets/diagnosis_card.dart';
import 'package:skinvista/core/widgets/text_widget.dart';
import 'package:skinvista/helpers/string_helper.dart';
import 'package:skinvista/repositories/diagnosis_repository.dart';
import 'package:intl/intl.dart';
import 'package:fluentui_icons/fluentui_icons.dart'; // For the icon
import '../core/locator.dart';

class DiagnosisHistory extends StatefulWidget {
  const DiagnosisHistory({super.key});

  @override
  _DiagnosisHistoryState createState() => _DiagnosisHistoryState();
}

class _DiagnosisHistoryState extends State<DiagnosisHistory> {
  @override
  Widget build(BuildContext context) {
    // Get the screen height to center the "No diagnoses found" message
    final screenHeight = MediaQuery.of(context).size.height;

    return BlocProvider(
      create: (context) => FetchDiagnosesBloc(repository: getIt<DiagnosisRepository>())
        ..add(FetchDiagnosesRequested()),
      child: Scaffold(
        backgroundColor: AppStyles.bgColor,
        appBar: AppBar(
          title: TextWidget(
            text: "Diagnosis History",
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
          child: RefreshIndicator(
            onRefresh: () async {
              context.read<FetchDiagnosesBloc>().add(FetchDiagnosesRequested());
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  BlocBuilder<FetchDiagnosesBloc, FetchDiagnosesState>(
                    builder: (context, state) {
                      if (state is FetchDiagnosesLoading) {
                        return SizedBox(
                          height: screenHeight - kToolbarHeight - MediaQuery.of(context).padding.top - 40,
                          child: const Center(child: CircularProgressIndicator()),
                        );
                      } else if (state is FetchDiagnosesSuccess) {
                        if (state.diagnoses.isEmpty) {
                          return SizedBox(
                            height: screenHeight - kToolbarHeight - MediaQuery.of(context).padding.top - 40,
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                margin: const EdgeInsets.symmetric(horizontal: 32),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      FluentSystemIcons.ic_fluent_history_regular,
                                      size: 48,
                                      color: AppStyles.blueGrey.withOpacity(0.7),
                                    ),
                                    const SizedBox(height: 16),
                                    TextWidget(
                                      text: "No Diagnoses Found",
                                      color: AppStyles.textColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 20,
                                    ),
                                    const SizedBox(height: 8),
                                    TextWidget(
                                      text: "You haven't performed any scans yet.\nStart a new scan to see your history here!",
                                      color: AppStyles.blueGrey,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pushNamed(context, '/scan');
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppStyles.blue,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                      ),
                                      child: const Text(
                                        "Start a New Scan",
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                        return Column(
                          children: state.diagnoses.map((diagnosis) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10, left: 16, right: 16),
                              child: DiagnosisCard(
                                title: StringHelper.formatCondition(diagnosis.condition),
                                date: DateFormat('d MMM yyyy').format(diagnosis.createdAt),
                                match: '${diagnosis.confidence.toStringAsFixed(0)}% Match',
                                onTap: () async {
                                  print('Navigating to DiagnosisDetails with imagePath: ${diagnosis.imagePath}');
                                  final result = await Navigator.pushNamed(
                                    context,
                                    '/diagnosis_details',
                                    arguments: diagnosis,
                                  );
                                  // Refresh diagnoses if a deletion occurred
                                  if (result == true) {
                                    context.read<FetchDiagnosesBloc>().add(FetchDiagnosesRequested());
                                  }
                                },
                              ),
                            );
                          }).toList(),
                        );
                      } else if (state is FetchDiagnosesFailure) {
                        if (state.error.contains('Session expired')) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/auth',
                                  (route) => false,
                            );
                          });
                        }
                        return SizedBox(
                          height: screenHeight - kToolbarHeight - MediaQuery.of(context).padding.top - 40,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Error: ${state.error}'),
                                const SizedBox(height: 10),
                                ElevatedButton(
                                  onPressed: () {
                                    context.read<FetchDiagnosesBloc>().add(FetchDiagnosesRequested());
                                  },
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}