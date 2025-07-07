import 'package:equatable/equatable.dart';

import '../../models/diagnosis.dart';

abstract class FetchDiagnosesState extends Equatable {
  const FetchDiagnosesState();

  @override
  List<Object?> get props => [];
}

class FetchDiagnosesInitial extends FetchDiagnosesState {}

class FetchDiagnosesLoading extends FetchDiagnosesState {}

class FetchDiagnosesSuccess extends FetchDiagnosesState {
  final List<Diagnosis> diagnoses;

  const FetchDiagnosesSuccess({required this.diagnoses});

  @override
  List<Object?> get props => [diagnoses];
}

class FetchDiagnosesFailure extends FetchDiagnosesState {
  final String error;

  const FetchDiagnosesFailure(this.error);

  @override
  List<Object?> get props => [error];
}