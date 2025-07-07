import 'package:equatable/equatable.dart';
import '../../responses/token_response.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final TokenResponse tokenResponse;

  const AuthSuccess({required this.tokenResponse});

  @override
  List<Object?> get props => [tokenResponse];
}

class AuthFailure extends AuthState {
  final String error;

  const AuthFailure(this.error);

  @override
  List<Object?> get props => [error];
}