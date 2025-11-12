import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:quranku/core/usecases/usecase.dart';
import 'package:quranku/features/auth/domain/usecases/auth_status_usecase.dart';
import 'package:quranku/features/auth/domain/usecases/get_me_usecase.dart';
import 'package:quranku/features/auth/domain/usecases/login_usecase.dart';
import 'package:quranku/features/auth/domain/usecases/logout_usecase.dart';
import 'package:quranku/features/auth/presentation/bloc/auth_event.dart';
import 'package:quranku/features/auth/presentation/bloc/auth_state.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;
  final GetMeUseCase getMeUseCase;
  final IsLoggedInUseCase isLoggedInUseCase;
  final GetStoredTokenUseCase getStoredTokenUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.logoutUseCase,
    required this.getMeUseCase,
    required this.isLoggedInUseCase,
    required this.getStoredTokenUseCase,
  }) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthGetMeRequested>(_onAuthGetMeRequested);
    on<AuthTokenChanged>(_onAuthTokenChanged);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final isLoggedIn = await isLoggedInUseCase();

      if (isLoggedIn) {
        final token = await getStoredTokenUseCase();
        if (token != null) {
          final result = await getMeUseCase(NoParams());

          result.fold(
            (failure) => emit(AuthUnauthenticated()),
            (userResponse) => emit(AuthAuthenticated(
              user: userResponse.data,
              token: token,
            )),
          );
        } else {
          emit(AuthUnauthenticated());
        }
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(LoginLoading());

    final result = await loginUseCase(LoginParams(
      email: event.email,
      password: event.password,
    ));

    result.fold(
      (failure) => emit(LoginError(message: failure.errorMessage)),
      (loginResponse) {
        emit(LoginSuccess(response: loginResponse));

        // After successful login, get user data
        add(AuthGetMeRequested());
      },
    );
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(LogoutLoading());

    final result = await logoutUseCase(NoParams());

    result.fold(
      (failure) {
        emit(LogoutError(message: failure.errorMessage));
        // Even if logout fails on server, mark as unauthenticated
        emit(AuthUnauthenticated());
      },
      (logoutResponse) {
        emit(LogoutSuccess());
        emit(AuthUnauthenticated());
      },
    );
  }

  Future<void> _onAuthGetMeRequested(
    AuthGetMeRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final token = await getStoredTokenUseCase();
      if (token == null) {
        emit(AuthUnauthenticated());
        return;
      }

      final result = await getMeUseCase(NoParams());

      result.fold(
        (failure) => emit(AuthError(message: failure.errorMessage)),
        (userResponse) => emit(AuthAuthenticated(
          user: userResponse.data,
          token: token,
        )),
      );
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onAuthTokenChanged(
    AuthTokenChanged event,
    Emitter<AuthState> emit,
  ) async {
    if (event.token == null) {
      emit(AuthUnauthenticated());
    } else {
      add(AuthGetMeRequested());
    }
  }
}
