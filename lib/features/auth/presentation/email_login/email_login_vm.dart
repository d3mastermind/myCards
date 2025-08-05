import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mycards/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:mycards/features/auth/domain/repositories/auth_repository.dart';
import 'package:mycards/core/utils/logger.dart';

class EmailLoginState {
  final bool isLoading;
  final bool isGoogleLoading;
  final bool isSuccess;
  final bool isError;
  final String errorMessage;

  EmailLoginState({
    this.isLoading = false,
    this.isGoogleLoading = false,
    this.isSuccess = false,
    this.isError = false,
    this.errorMessage = '',
  });

  EmailLoginState copyWith({
    bool? isLoading,
    bool? isGoogleLoading,
    bool? isSuccess,
    bool? isError,
    String? errorMessage,
  }) {
    return EmailLoginState(
      isLoading: isLoading ?? this.isLoading,
      isGoogleLoading: isGoogleLoading ?? this.isGoogleLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      isError: isError ?? this.isError,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class EmailLoginVM extends StateNotifier<EmailLoginState> {
  final AuthRepository authRepository;

  EmailLoginVM({required this.authRepository}) : super(EmailLoginState());

  Future<void> login(String email, String password) async {
    AppLogger.log('EmailLoginVM: Starting email login for: $email',
        tag: 'EmailLoginVM');
    state = state.copyWith(isLoading: true, isError: false, errorMessage: '');
    try {
      await authRepository.loginWithEmail(email, password);
      AppLogger.logSuccess('EmailLoginVM: Email login successful',
          tag: 'EmailLoginVM');
      state = state.copyWith(isSuccess: true);
    } catch (e) {
      AppLogger.logError('EmailLoginVM: Email login failed: $e',
          tag: 'EmailLoginVM');
      state = state.copyWith(isError: true, errorMessage: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> signInWithGoogle() async {
    AppLogger.log('EmailLoginVM: Starting Google sign-in', tag: 'EmailLoginVM');
    state =
        state.copyWith(isGoogleLoading: true, isError: false, errorMessage: '');
    try {
      await authRepository.signInWithGoogle();
      AppLogger.logSuccess('EmailLoginVM: Google sign-in successful',
          tag: 'EmailLoginVM');
      state = state.copyWith(isSuccess: true);
    } catch (e) {
      AppLogger.logError('EmailLoginVM: Google sign-in failed: $e',
          tag: 'EmailLoginVM');
      state = state.copyWith(isError: true, errorMessage: e.toString());
    } finally {
      state = state.copyWith(isGoogleLoading: false);
    }
  }

  void clearError() {
    AppLogger.log('EmailLoginVM: Clearing error state', tag: 'EmailLoginVM');
    state = state.copyWith(isError: false, errorMessage: '');
  }

  void clearSuccess() {
    AppLogger.log('EmailLoginVM: Clearing success state', tag: 'EmailLoginVM');
    state = state.copyWith(isSuccess: false);
  }

  void resetState() {
    state = EmailLoginState();
  }
}

final emailLoginVMProvider =
    StateNotifierProvider<EmailLoginVM, EmailLoginState>(
  (ref) => EmailLoginVM(authRepository: ref.read(authRepositoryProvider)),
);
