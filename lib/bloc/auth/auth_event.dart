import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginSubmitted extends AuthEvent {
  final String email;
  final List<String>? scopes;

  const LoginSubmitted({
    required this.email,
    this.scopes,
  });

  @override
  List<Object?> get props => [email, scopes];
}