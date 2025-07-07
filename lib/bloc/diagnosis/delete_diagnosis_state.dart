abstract class DeleteDiagnosisState {
  const DeleteDiagnosisState();
}

class DeleteDiagnosisInitial extends DeleteDiagnosisState {}

class DeleteDiagnosisLoading extends DeleteDiagnosisState {}

class DeleteDiagnosisSuccess extends DeleteDiagnosisState {}

class DeleteDiagnosisFailure extends DeleteDiagnosisState {
  final String error;

  const DeleteDiagnosisFailure(this.error);

  @override
  List<Object> get props => [error];
}