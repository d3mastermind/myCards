import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mycards/features/auth/domain/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mycards/features/auth/data/repositories/auth_repository_impl.dart';

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
    state = state.copyWith(isLoading: true, isError: false, errorMessage: '');
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      await authRepository.signUpWithCredential(credential);
      state = state.copyWith(isSuccess: true);
    } catch (e) {
      state = state.copyWith(isError: true, errorMessage: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> resendOtp(String phoneNumber, BuildContext context) async {
    try {
      await authRepository.loginWithPhone(phoneNumber);
    } catch (e) {
      // Optionally handle resend error
    }
  }

  void clearError() {
    state = state.copyWith(isError: false, errorMessage: '');
  }

  void resetState() {
    state = OtpVerificationState();
  }
}

final otpVerificationVMProvider =
    StateNotifierProvider<OtpVerificationVM, OtpVerificationState>(
  (ref) => OtpVerificationVM(authRepository: ref.read(authRepositoryProvider)),
);
