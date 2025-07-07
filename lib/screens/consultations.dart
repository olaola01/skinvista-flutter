import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:skinvista/bloc/consultation/fetch_consultations_bloc.dart';
import 'package:skinvista/core/locator.dart';
import 'package:skinvista/core/widgets/consultation_history_card.dart';
import '../core/res/styles/app_styles.dart';
import '../core/widgets/text_widget.dart';
import '../helpers/string_helper.dart';

class Consultations extends StatelessWidget {
  const Consultations({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<FetchConsultationsBloc>()..add(FetchConsultationsStarted()),
      child: Scaffold(
        backgroundColor: AppStyles.bgColor,
        appBar: AppBar(
          title: TextWidget(
            text: "Consultations",
            color: AppStyles.textColor,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.only(top: 20, left: 11, right: 11),
                sliver: SliverToBoxAdapter(
                  child: BlocBuilder<FetchConsultationsBloc, FetchConsultationsState>(
                    builder: (context, state) {
                      if (state is FetchConsultationsLoading) {
                        return Center(child: CircularProgressIndicator());
                      } else if (state is FetchConsultationsFailure) {
                        return Center(child: Text('Error: ${state.error}'));
                      } else if (state is FetchConsultationsSuccess) {
                        if (state.consultations.isEmpty) {
                          return Center(child: Text('No consultations found'));
                        }
                        return Column(
                          children: List.generate(
                            state.consultations.length,
                                (index) {
                              final consultation = state.consultations[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: ConsultationHistoryCard(
                                  title: consultation.doctorName,
                                  topic: StringHelper.formatCondition(consultation.diagnosisCondition),
                                  timeline: DateFormat('MMM d, yyyy').format(consultation.sentAt),
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/consultation_details',
                                      arguments: consultation,
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        );
                      }
                      return Container();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}