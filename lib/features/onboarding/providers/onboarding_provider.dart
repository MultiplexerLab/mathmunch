import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingState {
  final int step; // 0 = account, 1 = child profile
  final String email;
  final String password;
  final String pin;
  final bool isLoading;
  final String? error;

  const OnboardingState({
    this.step = 0,
    this.email = '',
    this.password = '',
    this.pin = '',
    this.isLoading = false,
    this.error,
  });

  OnboardingState copyWith({
    int? step,
    String? email,
    String? password,
    String? pin,
    bool? isLoading,
    String? error,
  }) {
    return OnboardingState(
      step: step ?? this.step,
      email: email ?? this.email,
      password: password ?? this.password,
      pin: pin ?? this.pin,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class OnboardingNotifier extends Notifier<OnboardingState> {
  @override
  OnboardingState build() => const OnboardingState();

  void setEmail(String v) => state = state.copyWith(email: v);
  void setPassword(String v) => state = state.copyWith(password: v);
  void setPin(String v) => state = state.copyWith(pin: v);
  void nextStep() => state = state.copyWith(step: state.step + 1);
  void setError(String? e) => state = state.copyWith(error: e);
  void setLoading(bool v) => state = state.copyWith(isLoading: v);
}

final onboardingProvider =
    NotifierProvider<OnboardingNotifier, OnboardingState>(
  OnboardingNotifier.new,
);
