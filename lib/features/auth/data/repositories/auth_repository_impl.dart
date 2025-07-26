import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mycards/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:mycards/features/auth/data/models/user_model.dart';
import 'package:mycards/features/auth/domain/entities/user_entity.dart';
import 'package:mycards/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource authRemoteDataSource;

  AuthRepositoryImpl({required this.authRemoteDataSource});

  @override
  Future<UserEntity> loginWithEmail(String email, String password) async {
    final UserModel userModel =
        await authRemoteDataSource.loginWithEmail(email, password);
    return userModel;
  }

  @override
  Future<void> signupWithEmail(String email, String password) async {
    await authRemoteDataSource.signupWithEmail(email, password);
  }

  @override
  Future<void> sendEmailVerification() async {
    await authRemoteDataSource.sendEmailVerification();
  }

  @override
  Future<void> resetPassword(String email) async {
    await authRemoteDataSource.resetPassword(email);
  }

  @override
  Future<void> loginWithPhone(String phoneNumber) async {
    await authRemoteDataSource.loginWithPhone(phoneNumber);
  }

  @override
  Future<void> verifyOTP(String verificationId, String otp) async {
    await authRemoteDataSource.verifyOTP(verificationId, otp);
  }

  @override
  Future<UserEntity> signInWithGoogle() async {
    final UserModel userModel = await authRemoteDataSource.signInWithGoogle();
    return _convertToEntity(userModel);
  }

  @override
  Future<void> signUpWithGoogle() async {
    await authRemoteDataSource.signUpWithGoogle();
  }

  @override
  Future<void> signUpWithCredential(PhoneAuthCredential credential) async {
    await authRemoteDataSource.signUpWithCredential(credential);
  }

  // Helper method to convert UserModel to UserEntity
  UserEntity _convertToEntity(UserModel model) {
    return UserEntity(
      userId: model.userId,
      email: model.email,
      phoneNumber: model.phoneNumber,
      name: model.name,
      creditBalance: model.creditBalance,
      purchasedCards: model.purchasedCards,
      likedCards: model.likedCards,
      receivedCards: model.receivedCards,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
      authRemoteDataSource: ref.read(authRemoteDataSourceProvider));
});
