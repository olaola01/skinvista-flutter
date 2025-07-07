import 'package:equatable/equatable.dart';
import 'package:skinvista/models/game_score.dart';

abstract class LeaderboardState extends Equatable {
  const LeaderboardState();

  @override
  List<Object?> get props => [];
}

class LeaderboardInitial extends LeaderboardState {}

class LeaderboardLoading extends LeaderboardState {}

class LeaderboardLoaded extends LeaderboardState {
  final List<GameScore> scores;

  const LeaderboardLoaded(this.scores);

  @override
  List<Object?> get props => [scores];
}

class LeaderboardFailure extends LeaderboardState {
  final String error;

  const LeaderboardFailure(this.error);

  @override
  List<Object?> get props => [error];
}