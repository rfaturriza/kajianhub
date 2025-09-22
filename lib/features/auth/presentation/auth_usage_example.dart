// Example usage of the auth feature with GoRouter
//
// Add this to your main.dart or routing system:

/*
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quranku/features/auth/presentation/screens/login_screen.dart';
import 'package:quranku/features/auth/presentation/screens/profile_screen.dart';
import 'package:quranku/features/auth/presentation/widgets/auth_wrapper.dart';
import 'package:quranku/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:quranku/features/auth/presentation/bloc/auth_state.dart';
import 'package:quranku/injection.dart';

// 1. Create a GoRouter configuration with auth guard
final GoRouter router = GoRouter(
  initialLocation: '/home',
  redirect: (BuildContext context, GoRouterState state) {
    // Check if user is authenticated for protected routes
    final authBloc = context.read<AuthBloc>();
    final authState = authBloc.state;
    final isAuthenticated = authState is AuthAuthenticated;
    
    final isLoginRoute = state.subloc == '/login';
    final isProtectedRoute = ['/profile', '/settings'].contains(state.subloc);
    
    // If not authenticated and trying to access protected route, redirect to login
    if (!isAuthenticated && isProtectedRoute) {
      return '/login';
    }
    
    // If authenticated and on login page, redirect to home
    if (isAuthenticated && isLoginRoute) {
      return '/home';
    }
    
    // No redirect needed
    return null;
  },
  routes: [
    // Public routes
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomeScreen(), // Your home screen
    ),
    
    // Protected routes - wrapped with AuthWrapper
    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (context, state) => AuthWrapper(
        authenticatedWidget: const ProfileScreen(),
        unauthenticatedWidget: const LoginScreen(),
      ),
    ),
    
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => AuthWrapper(
        authenticatedWidget: const SettingsScreen(), // Your settings screen
        unauthenticatedWidget: const LoginScreen(),
      ),
    ),
  ],
  
  // Optional: Error page
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Page not found: ${state.location}'),
    ),
  ),
);

// 2. Use GoRouter in your MaterialApp
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AuthBloc>()..add(AuthCheckRequested()),
      child: MaterialApp.router(
        title: 'QuranKu',
        routerConfig: router,
      ),
    );
  }
}

// 3. Alternative: Using redirect with auth state listener
final GoRouter routerWithListener = GoRouter(
  initialLocation: '/home',
  refreshListenable: AuthChangeNotifier(), // Custom listenable for auth changes
  redirect: (context, state) {
    final authNotifier = AuthChangeNotifier.instance;
    final isAuthenticated = authNotifier.isAuthenticated;
    
    final isLoginRoute = state.subloc == '/login';
    final isProtectedRoute = ['/profile', '/settings'].contains(state.subloc);
    
    if (!isAuthenticated && isProtectedRoute) {
      return '/login';
    }
    
    if (isAuthenticated && isLoginRoute) {
      return '/home';
    }
    
    return null;
  },
  routes: [
    // ... same routes as above
  ],
);

// 4. Custom ChangeNotifier for auth state changes
class AuthChangeNotifier extends ChangeNotifier {
  static AuthChangeNotifier? _instance;
  static AuthChangeNotifier get instance => _instance ??= AuthChangeNotifier._();
  
  AuthChangeNotifier._() {
    // Listen to auth bloc changes
    sl<AuthBloc>().stream.listen((state) {
      final newIsAuthenticated = state is AuthAuthenticated;
      if (newIsAuthenticated != _isAuthenticated) {
        _isAuthenticated = newIsAuthenticated;
        notifyListeners();
      }
    });
  }
  
  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;
}

// 5. Navigation usage examples with GoRouter:

// Navigate to login
context.goNamed('login');
// or
context.go('/login');

// Navigate to profile (will be guarded by auth)
context.goNamed('profile');
// or  
context.go('/profile');

// Push a route (adds to stack)
context.pushNamed('profile');

// Replace current route
context.replaceNamed('login');

// Pop current route
context.pop();

// Check if can pop
if (context.canPop()) {
  context.pop();
}

// 6. Example usage in widgets:

// In a drawer or app bar:
ListTile(
  leading: const Icon(Icons.person),
  title: const Text('Profile'),
  onTap: () {
    context.goNamed('profile');
  },
),

ListTile(
  leading: const Icon(Icons.login),
  title: const Text('Login'),
  onTap: () {
    context.goNamed('login');
  },
),

// In a logout button:
ElevatedButton(
  onPressed: () {
    context.read<AuthBloc>().add(AuthLogoutRequested());
    context.goNamed('login');
  },
  child: const Text('Logout'),
),

// 7. Nested routes example (if you need sub-routes):
GoRoute(
  path: '/dashboard',
  name: 'dashboard',
  builder: (context, state) => AuthWrapper(
    authenticatedWidget: const DashboardScreen(),
    unauthenticatedWidget: const LoginScreen(),
  ),
  routes: [
    GoRoute(
      path: '/profile',
      name: 'dashboard-profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/settings',
      name: 'dashboard-settings', 
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
),

// Navigate to nested route:
context.goNamed('dashboard-profile'); // goes to /dashboard/profile

// 8. Passing parameters with GoRouter:
GoRoute(
  path: '/user/:userId',
  name: 'user-detail',
  builder: (context, state) {
    final userId = state.params['userId']!;
    return UserDetailScreen(userId: userId);
  },
),

// Navigate with parameters:
context.goNamed('user-detail', params: {'userId': '123'});

// 9. Query parameters:
GoRoute(
  path: '/search',
  name: 'search',
  builder: (context, state) {
    final query = state.queryParams['q'] ?? '';
    return SearchScreen(initialQuery: query);
  },
),

// Navigate with query parameters:
context.goNamed('search', queryParams: {'q': 'islam'});

// 10. Extra data passing:
context.pushNamed('profile', extra: {'fromNotification': true});

// In the route builder:
GoRoute(
  path: '/profile',
  name: 'profile',
  builder: (context, state) {
    final extra = state.extra as Map<String, dynamic>?;
    final fromNotification = extra?['fromNotification'] as bool? ?? false;
    return ProfileScreen(fromNotification: fromNotification);
  },
),
*/
