import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mycards/features/auth/domain/repositories/auth_repository.dart';
import 'package:mycards/features/auth/data/repositories/auth_repository_impl.dart';

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
    state = state.copyWith(isLoading: true, isError: false, errorMessage: '');
    try {
      await authRepository.signupWithEmail(email, password);
      await authRepository.sendEmailVerification();
      state = state.copyWith(isSuccess: true);
    } catch (e) {
      state = state.copyWith(isError: true, errorMessage: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> signUpWithGoogle() async {
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
    state = EmailSignUpState();
  }
}

final emailSignUpVMProvider =
    StateNotifierProvider<EmailSignUpVM, EmailSignUpState>(
  (ref) => EmailSignUpVM(authRepository: ref.read(authRepositoryProvider)),
);
