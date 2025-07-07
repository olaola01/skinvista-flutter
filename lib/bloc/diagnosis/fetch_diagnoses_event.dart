import 'package:equatable/equatable.dart';

abstract class FetchDiagnosesEvent extends Equatable {
  const FetchDiagnosesEvent();

  @override
  List<Object?> get props => [];
}

class FetchDiagnosesRequested extends FetchDiagnosesEvent {}