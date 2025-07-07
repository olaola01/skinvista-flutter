import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skinvista/bloc/diagnosis/delete_diagnosis_event.dart';
import 'package:skinvista/bloc/diagnosis/delete_diagnosis_state.dart';

import '../../repositories/diagnosis_repository.dart';

class DeleteDiagnosisBloc extends Bloc<DeleteDiagnosisEvent, DeleteDiagnosisState> {
  final DiagnosisRepository repository;

  DeleteDiagnosisBloc({required this.repository}) : super(DeleteDiagnosisInitial()) {
    on<DeleteDiagnosisSubmitted>(_onDeleteDiagnosisSubmitted);
  }

  Future<void> _onDeleteDiagnosisSubmitted(
      DeleteDiagnosisSubmitted event,
      Emitter<DeleteDiagnosisState> emit,
      ) async {
    emit(DeleteDiagnosisLoading());

    try {
      // Call the repository to delete the diagnosis from the backend
      await repository.deleteDiagnosis(event.diagnosisId);

      // Delete the local image file if it exists
      if (event.imagePath != null && event.imagePath!.isNotEmpty) {
        final File imageFile = File(event.imagePath!);
        if (imageFile.existsSync()) {
          await imageFile.delete();
          print('Deleted local image file: ${event.imagePath}');
        }
      }

      emit(DeleteDiagnosisSuccess());
    } catch (e) {
      if (e.toString().contains('401')) {
        emit(const DeleteDiagnosisFailure('Session expired. Please log in again.'));
      } else {
        emit(DeleteDiagnosisFailure(e.toString().replaceFirst('Exception: ', '')));
      }
    }
  }
}