import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mycards/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:mycards/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:mycards/core/utils/logger.dart';

class PhoneLoginState {
  final bool isLoading;
  final bool isGoogleLoading;
  final bool isSuccess;
  final bool isError;
  final String errorMessage;
  final String? verificationId;
  final String? phoneNumber;

  PhoneLoginState({
    this.isLoading = false,
    this.isGoogleLoading = false,
    this.isSuccess = false,
    this.isError = false,
    this.errorMessage = '',
    this.verificationId,
    this.phoneNumber,
  });

  PhoneLoginState copyWith({
    bool? isLoading,
    bool? isGoogleLoading,
    bool? isSuccess,
    bool? isError,
    String? errorMessage,
    String? verificationId,
    String? phoneNumber,
  }) {
    return PhoneLoginState(
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

class PhoneLoginVM extends StateNotifier<PhoneLoginState> {
  final AuthRepository authRepository;
  PhoneLoginVM({required this.authRepository}) : super(PhoneLoginState());

  Future<void> loginWithPhone(String phoneNumber, BuildContext context) async {
    AppLogger.log('PhoneLoginVM: Starting phone login for: $phoneNumber',
        tag: 'PhoneLoginVM');
    state = state.copyWith(isLoading: true, isError: false, errorMessage: '');
    try {
      final verificationId = await authRepository.loginWithPhone(phoneNumber);
      AppLogger.logSuccess(
          'PhoneLoginVM: Phone login successful, verification ID received',
          tag: 'PhoneLoginVM');
      state = state.copyWith(
        verificationId: verificationId,
        phoneNumber: phoneNumber,
        isSuccess: true,
      );
    } catch (e) {
      AppLogger.logError('PhoneLoginVM: Phone login failed: $e',
          tag: 'PhoneLoginVM');
      state = state.copyWith(isError: true, errorMessage: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    state =
        state.copyWith(isGoogleLoading: true, isError: false, errorMessage: '');
    try {
      await authRepository.signInWithGoogle();
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
    state = PhoneLoginState();
  }

  void clearSuccess() {
    AppLogger.log('PhoneLoginVM: Clearing success state', tag: 'PhoneLoginVM');
    state = state.copyWith(
        isSuccess: false, verificationId: null, phoneNumber: null);
  }
}

final phoneLoginVMProvider =
    StateNotifierProvider<PhoneLoginVM, PhoneLoginState>(
  (ref) => PhoneLoginVM(authRepository: ref.read(authRepositoryProvider)),
);
