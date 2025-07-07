import 'package:equatable/equatable.dart';

abstract class SaveGameScoreEvent extends Equatable {
  const SaveGameScoreEvent();

  @override
  List<Object?> get props => [];
}

class SaveGameScoreSubmitted extends SaveGameScoreEvent {
  final int score;

  const SaveGameScoreSubmitted({required this.score});

  @override
  List<Object?> get props => [score];
}