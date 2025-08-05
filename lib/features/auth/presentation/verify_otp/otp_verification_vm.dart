import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mycards/features/auth/domain/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mycards/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:mycards/core/utils/logger.dart';

class OtpVerificationState {
  final bool isLoading;
  final bool isSuccess;
  final bool isError;
  final String errorMessage;

  OtpVerificationState({
    this.isLoading = false,
    this.isSuccess = false,
    this.isError = false,
    this.errorMessage = '',
  });

  OtpVerificationState copyWith({
    bool? isLoading,
    bool? isSuccess,
    bool? isError,
    String? errorMessage,
  }) {
    return OtpVerificationState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      isError: isError ?? this.isError,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class OtpVerificationVM extends StateNotifier<OtpVerificationState> {
  final AuthRepository authRepository;
  OtpVerificationVM({required this.authRepository})
      : super(OtpVerificationState());

  Future<void> verifyOtp(String verificationId, String smsCode) async {
    AppLogger.log('OtpVerificationVM: Starting OTP verification',
        tag: 'OtpVerificationVM');
    state = state.copyWith(isLoading: true, isError: false, errorMessage: '');
    try {
      await authRepository.verifyOTP(verificationId, smsCode);
      AppLogger.logSuccess('OtpVerificationVM: OTP verification successful',
          tag: 'OtpVerificationVM');
      state = state.copyWith(isSuccess: true);
    } catch (e) {
      AppLogger.logError('OtpVerificationVM: OTP verification failed: $e',
          tag: 'OtpVerificationVM');
      state = state.copyWith(isError: true, errorMessage: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> resendOtp(String phoneNumber, BuildContext context) async {
    AppLogger.log('OtpVerificationVM: Resending OTP to: $phoneNumber', tag: 'OtpVerificationVM');
    try {
      await authRepository.loginWithPhone(phoneNumber);
      AppLogger.logSuccess('OtpVerificationVM: OTP resent successfully', tag: 'OtpVerificationVM');
    } catch (e) {
      AppLogger.logError('OtpVerificationVM: OTP resend failed: $e', tag: 'OtpVerificationVM');
      // Optionally handle resend error
    }
  }

  void clearError() {
    state = state.copyWith(isError: false, errorMessage: '');
  }

  void resetState() {
    state = OtpVerificationState();
  }

  void clearSuccess() {
    AppLogger.log('OtpVerificationVM: Clearing success state', tag: 'OtpVerificationVM');
    state = state.copyWith(isSuccess: false);
  }
}

final otpVerificationVMProvider =
    StateNotifierProvider<OtpVerificationVM, OtpVerificationState>(
  (ref) => OtpVerificationVM(authRepository: ref.read(authRepositoryProvider)),
);
