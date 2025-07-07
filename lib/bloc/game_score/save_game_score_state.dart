import 'package:equatable/equatable.dart';

abstract class SaveGameScoreState extends Equatable {
  const SaveGameScoreState();

  @override
  List<Object?> get props => [];
}

class SaveGameScoreInitial extends SaveGameScoreState {}

class SaveGameScoreLoading extends SaveGameScoreState {}

class SaveGameScoreSuccess extends SaveGameScoreState {}

class SaveGameScoreFailure extends SaveGameScoreState {
  final String error;

  const SaveGameScoreFailure(this.error);

  @override
  List<Object?> get props => [error];
}