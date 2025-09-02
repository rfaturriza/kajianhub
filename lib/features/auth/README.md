# Auth Feature

This auth feature provides authentication functionality for the KajianHub mobile app using the KajianHub API.

## Features

- **Login**: Authenticate users with email and password
- **Logout**: Securely logout users and clear stored tokens
- **Profile**: Display user profile information with social media links, roles, and statistics
- **Token Management**: Automatically save and manage access tokens using SharedPreferences
- **State Management**: Uses BLoC pattern for reactive state management

## API Endpoints

Based on the KajianHub Mobile API specification:

- `POST /api/mobile/auth/login` - User login
- `POST /api/mobile/auth/logout` - User logout
- `GET /api/mobile/auth/me` - Get current user profile

## Architecture

The feature follows Clean Architecture principles:

```bash
lib/features/auth/
├── data/
│   ├── datasources/
│   │   ├── auth_local_data_source.dart    # Local storage for tokens
│   │   └── auth_remote_data_source.dart   # API calls
│   ├── models/
│   │   └── auth_dto.dart                  # Data Transfer Objects
│   └── repositories/
│       └── auth_repository_impl.dart      # Repository implementation
├── domain/
│   ├── entities/
│   │   └── auth_user.codegen.dart         # Domain entities
│   ├── repositories/
│   │   └── auth_repository.dart           # Repository interface
│   └── usecases/
│       ├── login_usecase.dart
│       ├── logout_usecase.dart
│       ├── get_me_usecase.dart
│       └── auth_status_usecase.dart
└── presentation/
    ├── bloc/
    │   ├── auth_bloc.dart                 # State management
    │   ├── auth_event.dart
    │   └── auth_state.dart
    ├── screens/
    │   ├── login_screen.dart              # Login UI
    │   └── profile_screen.dart            # Profile UI
    └── widgets/
        └── auth_wrapper.dart              # Authentication wrapper
```

## Usage

### 1. Login Screen

```dart
import 'package:quranku/features/auth/presentation/screens/login_screen.dart';

// With GoRouter
context.goNamed('login');
// or
context.go('/login');

// With traditional Navigator
Navigator.pushNamed(context, '/login');
```

### 2. Profile Screen

```dart
import 'package:quranku/features/auth/presentation/screens/profile_screen.dart';

// With GoRouter (will check authentication via redirect)
context.goNamed('profile');
// or
context.go('/profile');

// With traditional Navigator
Navigator.pushNamed(context, '/profile');
```

### 3. Auth Wrapper

Protect routes that require authentication:

```dart
import 'package:quranku/features/auth/presentation/widgets/auth_wrapper.dart';

// In GoRouter routes
GoRoute(
  path: '/protected',
  builder: (context, state) => AuthWrapper(
    authenticatedWidget: const YourProtectedScreen(),
    unauthenticatedWidget: const LoginScreen(),
  ),
),

// Or as a standalone widget
AuthWrapper(
  authenticatedWidget: const YourProtectedScreen(),
  unauthenticatedWidget: const LoginScreen(),
)
```

### 4. Manual Authentication Check

```dart
// In any widget, check authentication status
BlocProvider(
  create: (context) => sl<AuthBloc>()..add(AuthCheckRequested()),
  child: BlocBuilder<AuthBloc, AuthState>(
    builder: (context, state) {
      if (state is AuthAuthenticated) {
        // User is logged in
        return AuthenticatedContent(user: state.user);
      } else {
        // User is not logged in
        return const LoginPrompt();
      }
    },
  ),
)
```

### 5. Logout

```dart
// Trigger logout and navigate to login
context.read<AuthBloc>().add(AuthLogoutRequested());

// With GoRouter - navigate after logout
context.goNamed('login');

// With traditional Navigator
Navigator.pushReplacementNamed(context, '/login');
```

## States

- `AuthInitial` - Initial state
- `AuthLoading` - Loading authentication status
- `AuthAuthenticated` - User is logged in (contains user data and token)
- `AuthUnauthenticated` - User is not logged in
- `AuthError` - Authentication error occurred
- `LoginLoading` - Login request in progress
- `LoginSuccess` - Login successful
- `LoginError` - Login failed
- `LogoutLoading` - Logout request in progress
- `LogoutSuccess` - Logout successful
- `LogoutError` - Logout failed

## Data Models

### AuthUser

Contains complete user information including:

- Basic info (id, name, email)
- User roles and permissions
- Personal details (birth info, contact)
- Location (province, city)
- Social media links
- Statistics (subscribers, kajian count)

### LoginResponse

- success: boolean
- message: string
- accessToken: string
- tokenType: string

## Dependencies

Make sure these packages are added to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_bloc: ^8.1.3
  dartz: ^0.10.1
  dio: ^5.3.2
  injectable: ^2.3.2
  get_it: ^7.6.4
  shared_preferences: ^2.2.2
  json_annotation: ^4.8.1
  freezed_annotation: ^2.4.1
  equatable: ^2.0.5
  go_router: ^12.1.3 # For GoRouter navigation (recommended)

dev_dependencies:
  build_runner: ^2.4.7
  freezed: ^2.4.6
  json_serializable: ^6.7.1
  injectable_generator: ^2.4.1
```

## Setup

1. Add the auth repository to your dependency injection:

   ```dart
   // This is automatically handled by injectable if you run:
   // dart run build_runner build
   ```

2. Add routes to your app with GoRouter (recommended):

   ```dart
   import 'package:go_router/go_router.dart';

   final GoRouter router = GoRouter(
   initialLocation: '/home',
   redirect: (context, state) {
       final authBloc = sl<AuthBloc>();
       final isAuthenticated = authBloc.state is AuthAuthenticated;
       final isProtectedRoute = ['/profile', '/settings'].contains(state.subloc);

       if (!isAuthenticated && isProtectedRoute) {
       return '/login';
       }
       return null;
   },
   routes: [
       GoRoute(
       path: '/login',
       name: 'login',
       builder: (context, state) => const LoginScreen(),
       ),
       GoRoute(
       path: '/profile',
       name: 'profile',
       builder: (context, state) => AuthWrapper(
           authenticatedWidget: const ProfileScreen(),
           unauthenticatedWidget: const LoginScreen(),
       ),
       ),
   ],
   );

   // In your MaterialApp:
   MaterialApp.router(
   routerConfig: router,
   )
   ```

   Alternative with traditional Navigator:

   ```dart
   MaterialApp(
   routes: {
       '/login': (context) => const LoginScreen(),
       '/profile': (context) => const ProfileScreen(),
   },
   )
   ```

3. Initialize authentication check in your app startup:

   ```dart
   // In your main widget or splash screen
   BlocProvider(
   create: (context) => sl<AuthBloc>()..add(AuthCheckRequested()),
   child: YourApp(),
   )
   ```

## Error Handling

The feature includes comprehensive error handling:

- Network errors (timeout, connection issues)
- Server errors (invalid credentials, server down)
- Token expiration
- Local storage errors

All errors are mapped to user-friendly messages and displayed via SnackBar or error states.

## Security

- Tokens are stored securely using SharedPreferences
- Automatic token cleanup on logout
- Token validation on app startup
- Secure API communication using Dio with proper headers
