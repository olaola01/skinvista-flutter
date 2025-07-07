import 'package:equatable/equatable.dart';
import '../../responses/prediction_response.dart';



abstract class PredictionState extends Equatable {
  const PredictionState();

  @override
  List<Object?> get props => [];
}

class PredictionInitial extends PredictionState {}

class PredictionLoading extends PredictionState {}

class PredictionSuccess extends PredictionState {
  final PredictionResponse prediction;
  final String imagePath;

  const PredictionSuccess({
    required this.prediction,
    required this.imagePath,
  });

  @override
  List<Object?> get props => [prediction, imagePath];
}

class PredictionFailure extends PredictionState {
  final String error;

  const PredictionFailure(this.error);

  @override
  List<Object?> get props => [error];
}