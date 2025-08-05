import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mycards/features/auth/domain/repositories/auth_repository.dart';
import 'package:mycards/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:mycards/core/utils/logger.dart';

class EmailSignUpState {
  final bool isLoading;
  final bool isGoogleLoading;
  final bool isSuccess;
  final bool isError;
  final String errorMessage;

  EmailSignUpState({
    this.isLoading = false,
    this.isGoogleLoading = false,
    this.isSuccess = false,
    this.isError = false,
    this.errorMessage = '',
  });

  EmailSignUpState copyWith({
    bool? isLoading,
    bool? isGoogleLoading,
    bool? isSuccess,
    bool? isError,
    String? errorMessage,
  }) {
    return EmailSignUpState(
      isLoading: isLoading ?? this.isLoading,
      isGoogleLoading: isGoogleLoading ?? this.isGoogleLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      isError: isError ?? this.isError,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class EmailSignUpVM extends StateNotifier<EmailSignUpState> {
  final AuthRepository authRepository;
  EmailSignUpVM({required this.authRepository}) : super(EmailSignUpState());

  Future<void> signUp(String email, String password) async {
    AppLogger.log('EmailSignUpVM: Starting email signup for: $email',
        tag: 'EmailSignUpVM');
    state = state.copyWith(isLoading: true, isError: false, errorMessage: '');
    try {
      await authRepository.signupWithEmail(email, password);
      AppLogger.logSuccess('EmailSignUpVM: Email signup successful',
          tag: 'EmailSignUpVM');
      await authRepository.sendEmailVerification();
      AppLogger.logSuccess('EmailSignUpVM: Email verification sent',
          tag: 'EmailSignUpVM');
      state = state.copyWith(isSuccess: true);
    } catch (e) {
      AppLogger.logError('EmailSignUpVM: Email signup failed: $e',
          tag: 'EmailSignUpVM');
      state = state.copyWith(isError: true, errorMessage: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> signUpWithGoogle() async {
    AppLogger.log('EmailSignUpVM: Starting Google signup',
        tag: 'EmailSignUpVM');
    state =
        state.copyWith(isGoogleLoading: true, isError: false, errorMessage: '');
    try {
      await authRepository.signUpWithGoogle();
      AppLogger.logSuccess('EmailSignUpVM: Google signup successful',
          tag: 'EmailSignUpVM');
      state = state.copyWith(isSuccess: true);
    } catch (e) {
      AppLogger.logError('EmailSignUpVM: Google signup failed: $e',
          tag: 'EmailSignUpVM');
      state = state.copyWith(isError: true, errorMessage: e.toString());
    } finally {
      state = state.copyWith(isGoogleLoading: false);
    }
  }

  void clearError() {
    AppLogger.log('EmailSignUpVM: Clearing error state', tag: 'EmailSignUpVM');
    state = state.copyWith(isError: false, errorMessage: '');
  }

  void clearSuccess() {
    AppLogger.log('EmailSignUpVM: Clearing success state', tag: 'EmailSignUpVM');
    state = state.copyWith(isSuccess: false);
  }

  void resetState() {
    state = EmailSignUpState();
  }
}

final emailSignUpVMProvider =
    StateNotifierProvider<EmailSignUpVM, EmailSignUpState>(
  (ref) => EmailSignUpVM(authRepository: ref.read(authRepositoryProvider)),
);
