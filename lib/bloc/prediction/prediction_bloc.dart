import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/prediction_repository.dart';
import '../../utils/auth_utils.dart';
import 'prediction_event.dart';
import 'prediction_state.dart';

class PredictionBloc extends Bloc<PredictionEvent, PredictionState> {
  final PredictionRepository repository;

  PredictionBloc({required this.repository}) : super(PredictionInitial()) {
    on<FetchPrediction>(_onFetchPrediction);
  }

  Future<void> _onFetchPrediction(
      FetchPrediction event,
      Emitter<PredictionState> emit,
      ) async {
    emit(PredictionLoading());

    try {
      final prediction = await repository.getPrediction(event.imagePath);
      emit(PredictionSuccess(
        prediction: prediction,
        imagePath: event.imagePath,
      ));
    } catch (e) {
      if (e.toString().contains('401')) {
        // Clear token and redirect to login
        await AuthUtils.logout();
        emit(const PredictionFailure('Session expired. Please log in again.'));
      } else {
        emit(PredictionFailure('Error: $e'));
      }
    }
  }
}