import 'package:firebase_auth/firebase_auth.dart';
import 'package:mycards/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> loginWithEmail(String email, String password);
  Future<void> signupWithEmail(String email, String password);
  Future<void> sendEmailVerification();
  Future<void> resetPassword(String email);
  Future<void> loginWithPhone(String phoneNumber);
  Future<void> verifyOTP(String verificationId, String otp);
  Future<UserEntity> signInWithGoogle();
  Future<void> signUpWithGoogle();
  Future<void> signUpWithCredential(PhoneAuthCredential credential);
}
