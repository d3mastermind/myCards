import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mycards/features/auth/data/datasources/user_remote_datasource.dart';
import 'package:mycards/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> loginWithEmail(String email, String password);
  Future<void> signupWithEmail(String email, String password);
  Future<void> sendEmailVerification();
  Future<void> resetPassword(String email);
  Future<void> loginWithPhone(String phoneNumber);
  Future<void> verifyOTP(String verificationId, String otp);
  Future<UserModel> signInWithGoogle();
  Future<void> signUpWithGoogle();
  Future<void> signUpWithCredential(PhoneAuthCredential credential);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final UserRemoteDataSource _userDataSource;

  AuthRemoteDataSourceImpl() {
    _userDataSource = UserRemoteDataSourceImpl(firestore: _firestore);
  }

  @override
  Future<UserModel> loginWithEmail(String email, String password) async {
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = userCredential.user;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'User not found after login',
        );
      }

      // Get user data from Firestore
      final userModel = await _userDataSource.getUser(user.uid);
      if (userModel != null) {
        return userModel;
      } else {
        // Create default user model if Firestore data doesn't exist
        return UserModel(
          userId: user.uid,
          email: user.email ?? email,
          phoneNumber: user.phoneNumber,
          name: user.displayName,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(
        code: e.code,
        message: e.message ?? 'Login failed',
      );
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  @override
  Future<void> signupWithEmail(String email, String password) async {
    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Send email verification
      await userCredential.user?.sendEmailVerification();

      // Note: User document creation is now handled by Cloud Function onUserSignUp
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(
        code: e.code,
        message: e.message ?? 'Signup failed',
      );
    } catch (e) {
      throw Exception('Signup failed: $e');
    }
  }

  @override
  Future<void> loginWithPhone(String phoneNumber) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification completed
          await _handlePhoneVerificationCompleted(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          throw FirebaseAuthException(
            code: e.code,
            message: e.message ?? 'Phone verification failed',
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          // Code sent successfully - this is handled by the presentation layer
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Auto-retrieval timeout - this is handled by the presentation layer
        },
      );
    } catch (e) {
      throw Exception('Phone login failed: $e');
    }
  }

  @override
  Future<void> verifyOTP(String verificationId, String otp) async {
    try {
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );

      await _handlePhoneVerificationCompleted(credential);
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(
        code: e.code,
        message: e.message ?? 'OTP verification failed',
      );
    } catch (e) {
      throw Exception('OTP verification failed: $e');
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(
        code: e.code,
        message: e.message ?? 'Password reset failed',
      );
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        await user.sendEmailVerification();
      } else {
        throw Exception('No user is currently signed in');
      }
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(
        code: e.code,
        message: e.message ?? 'Email verification failed',
      );
    } catch (e) {
      throw Exception('Email verification failed: $e');
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        throw Exception('Google sign-in was cancelled');
      }

      final GoogleSignInAuthentication? googleAuth =
          await googleUser.authentication;
      if (googleAuth == null) {
        throw Exception('Failed to get Google authentication');
      }

      final UserCredential userCredential = await _auth.signInWithCredential(
        GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        ),
      );

      final User? user = userCredential.user;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'User not found after Google sign-in',
        );
      }

      // Get user data from Firestore
      final userModel = await _userDataSource.getUser(user.uid);
      if (userModel != null) {
        return userModel;
      } else {
        // Create default user model if Firestore data doesn't exist
        return UserModel(
          userId: user.uid,
          email: user.email ?? '',
          phoneNumber: user.phoneNumber,
          name: user.displayName,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(
        code: e.code,
        message: e.message ?? 'Google sign-in failed',
      );
    } catch (e) {
      throw Exception('Google sign-in failed: $e');
    }
  }

  @override
  Future<void> signUpWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        throw Exception('Google sign-up was cancelled');
      }

      final GoogleSignInAuthentication? googleAuth =
          await googleUser.authentication;
      if (googleAuth == null) {
        throw Exception('Failed to get Google authentication');
      }

      final UserCredential userCredential = await _auth.signInWithCredential(
        GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        ),
      );

      final User? user = userCredential.user;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'User not found after Google sign-up',
        );
      }
      // The Cloud Function will automatically create user data when a new user signs up
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(
        code: e.code,
        message: e.message ?? 'Google sign-up failed',
      );
    } catch (e) {
      throw Exception('Google sign-up failed: $e');
    }
  }

  @override
  Future<void> signUpWithCredential(PhoneAuthCredential credential) async {
    try {
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'User not found after credential sign-up',
        );
      }

      // Note: User document creation is now handled by Cloud Function onUserSignU
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(
        code: e.code,
        message: e.message ?? 'Credential sign-up failed',
      );
    } catch (e) {
      throw Exception('Credential sign-up failed: $e');
    }
  }

  // Helper method to handle phone verification completion
  Future<void> _handlePhoneVerificationCompleted(
      PhoneAuthCredential credential) async {
    try {
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // Note: User document creation is now handled by Cloud Function onUserSignUp
        // The Cloud Function will automatically create user data when a new user signs up
      }
    } catch (e) {
      throw Exception('Phone verification completion failed: $e');
    }
  }
}

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl();
});
