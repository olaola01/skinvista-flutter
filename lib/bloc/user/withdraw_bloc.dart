import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:skinvista/core/api_client/api_client.dart';

abstract class WithdrawEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class WithdrawStarted extends WithdrawEvent {}

abstract class WithdrawState extends Equatable {
  @override
  List<Object> get props => [];
}

class WithdrawInitial extends WithdrawState {}

class WithdrawLoading extends WithdrawState {}

class WithdrawSuccess extends WithdrawState {
  final String message;

  WithdrawSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class WithdrawFailure extends WithdrawState {
  final String error;

  WithdrawFailure(this.error);

  @override
  List<Object> get props => [error];
}

class WithdrawBloc extends Bloc<WithdrawEvent, WithdrawState> {
  final ApiClient apiClient;

  WithdrawBloc({required this.apiClient}) : super(WithdrawInitial()) {
    on<WithdrawStarted>(_onWithdrawStarted);
  }

  Future<void> _onWithdrawStarted(WithdrawStarted event, Emitter<WithdrawState> emit) async {
    emit(WithdrawLoading());
    try {
      final response = await apiClient.postMultipart(
        endpoint: '/participant/withdraw',
        fields: {},
        files: [],
      );
      emit(WithdrawSuccess(response['message']));
    } catch (e) {
      emit(WithdrawFailure(e.toString()));
    }
  }
}