import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/diagnosis_repository.dart';
import 'fetch_diagnoses_event.dart';
import 'fetch_diagnoses_state.dart';

class FetchDiagnosesBloc extends Bloc<FetchDiagnosesEvent, FetchDiagnosesState> {
  final DiagnosisRepository repository;

  FetchDiagnosesBloc({required this.repository})
      : super(FetchDiagnosesInitial()) {
    on<FetchDiagnosesRequested>(_onFetchDiagnosesRequested);
  }

  Future<void> _onFetchDiagnosesRequested(
      FetchDiagnosesRequested event,
      Emitter<FetchDiagnosesState> emit,
      ) async {
    emit(FetchDiagnosesLoading());

    try {
      final diagnoses = await repository.getDiagnoses();
      emit(FetchDiagnosesSuccess(diagnoses: diagnoses));
    } catch (e) {
      if (e.toString().contains('401')) {
        emit(const FetchDiagnosesFailure('Session expired. Please log in again.'));
        // Optionally, clear shared_preferences and navigate to Auth screen
      } else {
        emit(FetchDiagnosesFailure(e.toString().replaceFirst('Exception: ', '')));
      }
    }
  }
}