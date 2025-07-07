import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:skinvista/repositories/consultation_repository.dart';

import 'create_consultation_event.dart';
import 'create_consultation_state.dart';

// BLoC
class CreateConsultationBloc extends Bloc<CreateConsultationEvent, CreateConsultationState> {
  final ConsultationRepository repository;

  CreateConsultationBloc({required this.repository}) : super(CreateConsultationInitial()) {
    on<CreateConsultationSubmitted>(_onCreateConsultationSubmitted);
  }

  Future<void> _onCreateConsultationSubmitted(
      CreateConsultationSubmitted event,
      Emitter<CreateConsultationState> emit,
      ) async {
    emit(CreateConsultationLoading());
    try {
      await repository.createConsultation(
        doctorId: event.doctorId,
        diagnosisId: event.diagnosisId,
        notes: event.notes,
        imageAuthorized: event.imageAuthorized,
        imagePath: event.imagePath,
      );
      emit(CreateConsultationSuccess());
    } catch (e) {
      emit(CreateConsultationFailure(e.toString()));
    }
  }
}