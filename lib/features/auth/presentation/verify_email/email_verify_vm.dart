import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mycards/features/auth/domain/repositories/auth_repository.dart';
import 'package:mycards/features/auth/data/repositories/auth_repository_impl.dart';

class EmailVerifyState {
  final bool isLoading;
  final bool isSuccess;
  final bool isError;
  final String errorMessage;

  EmailVerifyState({
    this.isLoading = false,
    this.isSuccess = false,
    this.isError = false,
    this.errorMessage = '',
  });

  EmailVerifyState copyWith({
    bool? isLoading,
    bool? isSuccess,
    bool? isError,
    String? errorMessage,
  }) {
    return EmailVerifyState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      isError: isError ?? this.isError,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class EmailVerifyVM extends StateNotifier<EmailVerifyState> {
  final AuthRepository authRepository;
  EmailVerifyVM({required this.authRepository}) : super(EmailVerifyState());

  Future<void> reloadAndVerify() async {
    state = state.copyWith(isLoading: true, isError: false, errorMessage: '');
    try {
      // TODO: Implement email verification check via repository
      // await authRepository.reloadUser();
      state = state.copyWith(isSuccess: true);
    } catch (e) {
      state = state.copyWith(isError: true, errorMessage: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> resendVerification() async {
    try {
      await authRepository.sendEmailVerification();
    } catch (e) {
      // Optionally handle resend error
    }
  }

  void clearError() {
    state = state.copyWith(isError: false, errorMessage: '');
  }

  void resetState() {
    state = EmailVerifyState();
  }
}

final emailVerifyVMProvider =
    StateNotifierProvider<EmailVerifyVM, EmailVerifyState>(
  (ref) => EmailVerifyVM(authRepository: ref.read(authRepositoryProvider)),
);
