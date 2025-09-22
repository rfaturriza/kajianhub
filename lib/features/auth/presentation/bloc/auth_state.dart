import 'package:equatable/equatable.dart';
import 'package:quranku/features/auth/domain/entities/auth_user.codegen.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final AuthUser user;
  final String token;

  const AuthAuthenticated({
    required this.user,
    required this.token,
  });

  @override
  List<Object?> get props => [user, token];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}

class LoginLoading extends AuthState {}

class LoginSuccess extends AuthState {
  final LoginResponse response;

  const LoginSuccess({required this.response});

  @override
  List<Object?> get props => [response];
}

class LoginError extends AuthState {
  final String message;

  const LoginError({required this.message});

  @override
  List<Object?> get props => [message];
}

class LogoutLoading extends AuthState {}

class LogoutSuccess extends AuthState {}

class LogoutError extends AuthState {
  final String message;

  const LogoutError({required this.message});

  @override
  List<Object?> get props => [message];
}
