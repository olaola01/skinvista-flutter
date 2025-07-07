import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skinvista/bloc/leaderboard/leaderboard_event.dart';
import 'package:skinvista/bloc/leaderboard/leaderboard_state.dart';
import 'package:skinvista/repositories/game_score_repository.dart';

class LeaderboardBloc extends Bloc<LeaderboardEvent, LeaderboardState> {
  final GameScoreRepository repository;

  LeaderboardBloc({required this.repository}) : super(LeaderboardInitial()) {
    on<FetchLeaderboard>(_onFetchLeaderboard);
  }

  Future<void> _onFetchLeaderboard(
      FetchLeaderboard event,
      Emitter<LeaderboardState> emit,
      ) async {
    emit(LeaderboardLoading());

    try {
      final scores = await repository.getLeaderboard();
      emit(LeaderboardLoaded(scores));
    } catch (e) {
      if (e.toString().contains('401')) {
        emit(const LeaderboardFailure('Session expired. Please log in again.'));
      } else {
        emit(LeaderboardFailure(e.toString().replaceFirst('Exception: ', '')));
      }
    }
  }
}