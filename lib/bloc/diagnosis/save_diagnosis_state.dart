import 'package:equatable/equatable.dart';

abstract class SaveDiagnosisState extends Equatable {
  const SaveDiagnosisState();

  @override
  List<Object?> get props => [];
}

class SaveDiagnosisInitial extends SaveDiagnosisState {}

class SaveDiagnosisLoading extends SaveDiagnosisState {}

class SaveDiagnosisSuccess extends SaveDiagnosisState {}

class SaveDiagnosisFailure extends SaveDiagnosisState {
  final String error;

  const SaveDiagnosisFailure(this.error);

  @override
  List<Object?> get props => [error];
}