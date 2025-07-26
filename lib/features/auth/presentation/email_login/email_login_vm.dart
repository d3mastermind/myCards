import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mycards/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:mycards/features/auth/domain/repositories/auth_repository.dart';

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
    state = state.copyWith(isLoading: true, isError: false, errorMessage: '');
    try {
      await authRepository.loginWithEmail(email, password);
      state = state.copyWith(isSuccess: true);
    } catch (e) {
      state = state.copyWith(isError: true, errorMessage: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> signInWithGoogle() async {
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
    state = EmailLoginState();
  }
}

final emailLoginVMProvider =
    StateNotifierProvider<EmailLoginVM, EmailLoginState>(
  (ref) => EmailLoginVM(authRepository: ref.read(authRepositoryProvider)),
);
