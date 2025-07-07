import 'package:equatable/equatable.dart';

abstract class PredictionEvent extends Equatable {
  const PredictionEvent();

  @override
  List<Object?> get props => [];
}

class FetchPrediction extends PredictionEvent {
  final String imagePath;

  const FetchPrediction(this.imagePath);

  @override
  List<Object?> get props => [imagePath];
}