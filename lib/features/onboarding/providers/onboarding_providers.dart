import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tracks the current onboarding step.
class OnboardingNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void next() => state++;
  void reset() => state = 0;
}

final onboardingStepProvider = NotifierProvider<OnboardingNotifier, int>(
  OnboardingNotifier.new,
);
