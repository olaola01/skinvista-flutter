import 'package:equatable/equatable.dart';

abstract class CreateConsultationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CreateConsultationSubmitted extends CreateConsultationEvent {
  final String doctorId;
  final int diagnosisId;
  final String notes;
  final bool imageAuthorized;
  final String? imagePath;

  CreateConsultationSubmitted({
    required this.doctorId,
    required this.diagnosisId,
    required this.notes,
    required this.imageAuthorized,
    this.imagePath,
  });

  @override
  List<Object?> get props => [doctorId, diagnosisId, notes, imageAuthorized, imagePath];
}