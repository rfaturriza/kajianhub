import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quranku/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:quranku/features/auth/presentation/bloc/auth_event.dart';
import 'package:quranku/features/auth/presentation/bloc/auth_state.dart';
import 'package:quranku/features/auth/presentation/screens/login_screen.dart';

class AuthWrapper extends StatelessWidget {
  final Widget authenticatedWidget;
  final Widget? unauthenticatedWidget;

  const AuthWrapper({
    super.key,
    required this.authenticatedWidget,
    this.unauthenticatedWidget,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<AuthBloc>()..add(AuthCheckRequested()),
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthLoading || state is AuthInitial) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (state is AuthAuthenticated) {
            return authenticatedWidget;
          }

          // For all other states (unauthenticated, error), show login
          return unauthenticatedWidget ?? const LoginScreen();
        },
      ),
    );
  }
}
