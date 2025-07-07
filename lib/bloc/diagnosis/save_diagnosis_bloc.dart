import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skinvista/bloc/diagnosis/save_diagnosis_event.dart';
import 'package:skinvista/bloc/diagnosis/save_diagnosis_state.dart';
import '../../repositories/diagnosis_repository.dart';


class SaveDiagnosisBloc extends Bloc<SaveDiagnosisEvent, SaveDiagnosisState> {
  final DiagnosisRepository repository;

  SaveDiagnosisBloc({required this.repository})
      : super(SaveDiagnosisInitial()) {
    on<SaveDiagnosisSubmitted>(_onSaveDiagnosisSubmitted);
  }

  Future<void> _onSaveDiagnosisSubmitted(
      SaveDiagnosisSubmitted event,
      Emitter<SaveDiagnosisState> emit,
      ) async {
    emit(SaveDiagnosisLoading());

    try {
      await repository.saveDiagnosis(
        condition: event.condition,
        confidence: event.confidence,
        imagePath: event.imagePath,
      );
      emit(SaveDiagnosisSuccess());
    } catch (e) {
      if (e.toString().contains('401')) {
        emit(const SaveDiagnosisFailure('Session expired. Please log in again.'));
        // Optionally, clear shared_preferences and navigate to Auth screen
      } else {
        emit(SaveDiagnosisFailure(e.toString().replaceFirst('Exception: ', '')));
      }
    }
  }
}