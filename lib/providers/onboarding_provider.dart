import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, bool>((ref) {
  return OnboardingNotifier();
});

class OnboardingNotifier extends StateNotifier<bool> {
  OnboardingNotifier() : super(true) {
    _loadOnboardingStatus();
  }

  static const _key = 'hasSeenOnboarding';

  bool isTestingOnboarding = false;

  Future<void> _loadOnboardingStatus() async {
    if (isTestingOnboarding) {
      state = true;
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    state = !(prefs.getBool(_key) ?? false);
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
    state = false;
  }
}
