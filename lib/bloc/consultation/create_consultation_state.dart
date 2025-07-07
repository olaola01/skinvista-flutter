import 'package:equatable/equatable.dart';

abstract class CreateConsultationState extends Equatable {
  @override
  List<Object> get props => [];
}

class CreateConsultationInitial extends CreateConsultationState {}

class CreateConsultationLoading extends CreateConsultationState {}

class CreateConsultationSuccess extends CreateConsultationState {}

class CreateConsultationFailure extends CreateConsultationState {
  final String error;

  CreateConsultationFailure(this.error);

  @override
  List<Object> get props => [error];
}