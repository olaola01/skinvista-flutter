import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skinvista/bloc/game_score/save_game_score_event.dart';
import 'package:skinvista/bloc/game_score/save_game_score_state.dart';
import 'package:skinvista/repositories/game_score_repository.dart';

class SaveGameScoreBloc extends Bloc<SaveGameScoreEvent, SaveGameScoreState> {
  final GameScoreRepository repository;

  SaveGameScoreBloc({required this.repository})
      : super(SaveGameScoreInitial()) {
    on<SaveGameScoreSubmitted>(_onSaveGameScoreSubmitted);
  }

  Future<void> _onSaveGameScoreSubmitted(
      SaveGameScoreSubmitted event,
      Emitter<SaveGameScoreState> emit,
      ) async {
    emit(SaveGameScoreLoading());

    try {
      await repository.saveGameScore(score: event.score);
      emit(SaveGameScoreSuccess());
    } catch (e) {
      if (e.toString().contains('401')) {
        emit(const SaveGameScoreFailure('Session expired. Please log in again.'));
      } else {
        emit(SaveGameScoreFailure(e.toString().replaceFirst('Exception: ', '')));
      }
    }
  }
}