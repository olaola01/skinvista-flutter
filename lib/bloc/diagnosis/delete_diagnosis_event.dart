abstract class DeleteDiagnosisEvent {
  const DeleteDiagnosisEvent();
}

class DeleteDiagnosisSubmitted extends DeleteDiagnosisEvent {
  final int diagnosisId;
  final String? imagePath;

  const DeleteDiagnosisSubmitted({
    required this.diagnosisId,
    this.imagePath,
  });

  @override
  List<Object?> get props => [diagnosisId, imagePath];
}