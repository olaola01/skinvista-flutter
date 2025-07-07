import 'package:equatable/equatable.dart';

abstract class SaveDiagnosisEvent extends Equatable {
  const SaveDiagnosisEvent();

  @override
  List<Object?> get props => [];
}

class SaveDiagnosisSubmitted extends SaveDiagnosisEvent {
  final String condition;
  final double confidence;
  final String? imagePath;

  const SaveDiagnosisSubmitted({
    required this.condition,
    required this.confidence,
    this.imagePath,
  });

  @override
  List<Object?> get props => [condition, confidence, imagePath];
}