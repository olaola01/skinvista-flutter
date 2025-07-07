import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:skinvista/models/consultation.dart';
import 'package:skinvista/repositories/consultation_repository.dart';

// Events
abstract class FetchConsultationsEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class FetchConsultationsStarted extends FetchConsultationsEvent {}

// States
abstract class FetchConsultationsState extends Equatable {
  @override
  List<Object> get props => [];
}

class FetchConsultationsInitial extends FetchConsultationsState {}

class FetchConsultationsLoading extends FetchConsultationsState {}

class FetchConsultationsSuccess extends FetchConsultationsState {
  final List<Consultation> consultations;

  FetchConsultationsSuccess(this.consultations);

  @override
  List<Object> get props => [consultations];
}

class FetchConsultationsFailure extends FetchConsultationsState {
  final String error;

  FetchConsultationsFailure(this.error);

  @override
  List<Object> get props => [error];
}

// BLoC
class FetchConsultationsBloc extends Bloc<FetchConsultationsEvent, FetchConsultationsState> {
  final ConsultationRepository repository;

  FetchConsultationsBloc({required this.repository}) : super(FetchConsultationsInitial()) {
    on<FetchConsultationsStarted>(_onFetchConsultationsStarted);
  }

  Future<void> _onFetchConsultationsStarted(
      FetchConsultationsStarted event,
      Emitter<FetchConsultationsState> emit,
      ) async {
    emit(FetchConsultationsLoading());
    try {
      final consultations = await repository.getConsultations();
      emit(FetchConsultationsSuccess(consultations));
    } catch (e) {
      emit(FetchConsultationsFailure(e.toString()));
    }
  }
}