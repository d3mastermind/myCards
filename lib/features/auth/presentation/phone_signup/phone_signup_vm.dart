import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mycards/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:mycards/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:mycards/core/utils/logger.dart';

class PhoneSignUpState {
  final bool isLoading;
  final bool isGoogleLoading;
  final bool isSuccess;
  final bool isError;
  final String errorMessage;
  final String? verificationId;
  final String? phoneNumber;

  PhoneSignUpState({
    this.isLoading = false,
    this.isGoogleLoading = false,
    this.isSuccess = false,
    this.isError = false,
    this.errorMessage = '',
    this.verificationId,
    this.phoneNumber,
  });

  PhoneSignUpState copyWith({
    bool? isLoading,
    bool? isGoogleLoading,
    bool? isSuccess,
    bool? isError,
    String? errorMessage,
    String? verificationId,
    String? phoneNumber,
  }) {
    return PhoneSignUpState(
      isLoading: isLoading ?? this.isLoading,
      isGoogleLoading: isGoogleLoading ?? this.isGoogleLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      isError: isError ?? this.isError,
      errorMessage: errorMessage ?? this.errorMessage,
      verificationId: verificationId ?? this.verificationId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
}

class PhoneSignUpVM extends StateNotifier<PhoneSignUpState> {
  final AuthRepository authRepository;
  PhoneSignUpVM({required this.authRepository}) : super(PhoneSignUpState());

  Future<void> signUpWithPhone(String phoneNumber, BuildContext context) async {
    AppLogger.log('PhoneSignUpVM: Starting phone signup for: $phoneNumber',
        tag: 'PhoneSignUpVM');
    state = state.copyWith(isLoading: true, isError: false, errorMessage: '');
    try {
      final verificationId = await authRepository.loginWithPhone(phoneNumber);
      AppLogger.logSuccess(
          'PhoneSignUpVM: Phone signup successful, verification ID received',
          tag: 'PhoneSignUpVM');
      state = state.copyWith(
        verificationId: verificationId,
        phoneNumber: phoneNumber,
        isSuccess: true,
      );
    } catch (e) {
      AppLogger.logError('PhoneSignUpVM: Phone signup failed: $e',
          tag: 'PhoneSignUpVM');
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

  void clearSuccess() {
    AppLogger.log('PhoneSignUpVM: Clearing success state',
        tag: 'PhoneSignUpVM');
    state = state.copyWith(
        isSuccess: false, verificationId: null, phoneNumber: null);
  }
}

final phoneSignUpVMProvider =
    StateNotifierProvider<PhoneSignUpVM, PhoneSignUpState>(
  (ref) => PhoneSignUpVM(authRepository: ref.read(authRepositoryProvider)),
);
