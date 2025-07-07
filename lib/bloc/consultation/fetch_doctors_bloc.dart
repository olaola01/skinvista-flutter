import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:skinvista/repositories/consultation_repository.dart';

// Events
abstract class FetchDoctorsEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class FetchDoctorsStarted extends FetchDoctorsEvent {}

// States
abstract class FetchDoctorsState extends Equatable {
  @override
  List<Object> get props => [];
}

class FetchDoctorsInitial extends FetchDoctorsState {}

class FetchDoctorsLoading extends FetchDoctorsState {}

class FetchDoctorsSuccess extends FetchDoctorsState {
  final List<Map<String, dynamic>> doctors;

  FetchDoctorsSuccess(this.doctors);

  @override
  List<Object> get props => [doctors];
}

class FetchDoctorsFailure extends FetchDoctorsState {
  final String error;

  FetchDoctorsFailure(this.error);

  @override
  List<Object> get props => [error];
}

// BLoC
class FetchDoctorsBloc extends Bloc<FetchDoctorsEvent, FetchDoctorsState> {
  final ConsultationRepository repository;

  FetchDoctorsBloc({required this.repository}) : super(FetchDoctorsInitial()) {
    on<FetchDoctorsStarted>(_onFetchDoctorsStarted);
  }

  Future<void> _onFetchDoctorsStarted(
      FetchDoctorsStarted event,
      Emitter<FetchDoctorsState> emit,
      ) async {
    emit(FetchDoctorsLoading());
    try {
      final doctors = await repository.getDoctors();
      emit(FetchDoctorsSuccess(doctors));
    } catch (e) {
      emit(FetchDoctorsFailure(e.toString()));
    }
  }
}