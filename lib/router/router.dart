import 'package:cortada_app/pages/auth/login_page.dart';
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

      if (!isAuth && !isGoingToLogin) return AppRoutes.login;

      if (isAuth && isGoingToLogin) return AppRoutes.onboarding;

      return null;
    },
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginPage(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => ProfilePage(),
      ),
      GoRoute(
        path: '/splash',
        builder: (context, state) => SplashPage(),
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
