import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:quranku/features/auth/domain/entities/auth_user.codegen.dart';
import 'package:quranku/features/auth/domain/repositories/auth_repository.dart';
import 'package:quranku/features/auth/domain/usecases/login_usecase.dart';
import 'package:quranku/core/error/failures.dart';

// Mock the repository
class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LoginUseCase usecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = LoginUseCase(mockAuthRepository);
  });

  const testEmail = 'test@example.com';
  const testPassword = 'password123';
  const testLoginResponse = LoginResponse(
    success: true,
    message: 'Login successful',
    accessToken: 'test_access_token',
    tokenType: 'Bearer',
  );

  group('LoginUseCase', () {
    test('should get login response from repository when login is successful',
        () async {
      // arrange
      when(() => mockAuthRepository.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => const Right(testLoginResponse));

      // act
      final result = await usecase(LoginParams(
        email: testEmail,
        password: testPassword,
      ));

      // assert
      expect(result, const Right(testLoginResponse));
      verify(() => mockAuthRepository.login(
            email: testEmail,
            password: testPassword,
          ));
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return server failure when login fails', () async {
      // arrange
      const testFailure = ServerFailure(message: 'Invalid credentials');
      when(() => mockAuthRepository.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => const Left(testFailure));

      // act
      final result = await usecase(LoginParams(
        email: testEmail,
        password: testPassword,
      ));

      // assert
      expect(result, const Left(testFailure));
      verify(() => mockAuthRepository.login(
            email: testEmail,
            password: testPassword,
          ));
      verifyNoMoreInteractions(mockAuthRepository);
    });
  });
}
