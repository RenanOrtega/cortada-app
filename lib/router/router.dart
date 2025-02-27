import 'package:cortada_app/pages/auth/login_page.dart';
import 'package:cortada_app/pages/home/home_page.dart';
import 'package:cortada_app/pages/match/create_match_page.dart';
import 'package:cortada_app/pages/onboarding/onboarding_page.dart';
import 'package:cortada_app/pages/profile/profile_page.dart';
import 'package:cortada_app/pages/splash/splash_page.dart';
import 'package:cortada_app/providers/auth_provider.dart';
import 'package:cortada_app/router/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = RouterNotifier(ref);

  return GoRouter(
    refreshListenable: notifier,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);

      if (authState.isLoading) return AppRoutes.splash;

      final isAuth = authState.valueOrNull != null;
      final isGoingToLogin = state.uri.toString() == AppRoutes.login;

      final isProtectedRoute = state.uri.toString() == AppRoutes.profile ||
          state.uri.toString() == AppRoutes.createMatch ||
          false;

      if (!isAuth && !isGoingToLogin) return AppRoutes.login;
      if (isAuth && isGoingToLogin) return AppRoutes.onboarding;

      if (isAuth && !isGoingToLogin && !isProtectedRoute) return null;

      return null;
    },
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutes.createMatch,
        builder: (context, state) => const CreateMatchPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Error: ${state.error}'),
      ),
    ),
  );
});

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen(authStateProvider, (previous, next) {
      notifyListeners();
    });
  }
}
