import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';


class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;

  AuthBloc({required this.repository}) : super(AuthInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
  }

  Future<void> _onLoginSubmitted(
      LoginSubmitted event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());

    try {
      final tokenResponse = await repository.getToken(
        email: event.email,
        scopes: event.scopes,
      );
      emit(AuthSuccess(tokenResponse: tokenResponse));
    } catch (e) {
      emit(AuthFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}