import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mycards/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:mycards/features/auth/data/repositories/auth_repository_impl.dart';

class PhoneSignUpState {
  final bool isLoading;
  final bool isGoogleLoading;
  final bool isSuccess;
  final bool isError;
  final String errorMessage;

  PhoneSignUpState({
    this.isLoading = false,
    this.isGoogleLoading = false,
    this.isSuccess = false,
    this.isError = false,
    this.errorMessage = '',
  });

  PhoneSignUpState copyWith({
    bool? isLoading,
    bool? isGoogleLoading,
    bool? isSuccess,
    bool? isError,
    String? errorMessage,
  }) {
    return PhoneSignUpState(
      isLoading: isLoading ?? this.isLoading,
      isGoogleLoading: isGoogleLoading ?? this.isGoogleLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      isError: isError ?? this.isError,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class PhoneSignUpVM extends StateNotifier<PhoneSignUpState> {
  final AuthRepository authRepository;
  PhoneSignUpVM({required this.authRepository}) : super(PhoneSignUpState());

  Future<void> signUpWithPhone(String phoneNumber, BuildContext context) async {
    state = state.copyWith(isLoading: true, isError: false, errorMessage: '');
    try {
      await authRepository.loginWithPhone(phoneNumber);
      state = state.copyWith(isSuccess: true);
    } catch (e) {
      state = state.copyWith(isError: true, errorMessage: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> signUpWithGoogle(BuildContext context) async {
    state =
        state.copyWith(isGoogleLoading: true, isError: false, errorMessage: '');
    try {
      await authRepository.signUpWithGoogle();
      state = state.copyWith(isSuccess: true);
    } catch (e) {
      state = state.copyWith(isError: true, errorMessage: e.toString());
    } finally {
      state = state.copyWith(isGoogleLoading: false);
    }
  }

  void clearError() {
    state = state.copyWith(isError: false, errorMessage: '');
  }

  void resetState() {
    state = PhoneSignUpState();
  }
}

final phoneSignUpVMProvider =
    StateNotifierProvider<PhoneSignUpVM, PhoneSignUpState>(
  (ref) => PhoneSignUpVM(authRepository: ref.read(authRepositoryProvider)),
);
