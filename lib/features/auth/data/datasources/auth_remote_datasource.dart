import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:toastification/toastification.dart';
import 'package:mycards/features/auth/data/datasources/user_remote_datasource.dart';
import 'package:mycards/features/auth/data/models/user_model.dart';
import 'package:mycards/core/utils/logger.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> loginWithEmail(String email, String password);
  Future<void> signupWithEmail(String email, String password);
  Future<void> sendEmailVerification();
  Future<void> resetPassword(String email);
  Future<String> loginWithPhone(String phoneNumber);
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

  // Helper method to get user-friendly auth error messages
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'Account has been disabled';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'network-request-failed':
        return 'Network error. Please check your connection';
      case 'operation-not-allowed':
        return 'This operation is not allowed';
      case 'invalid-verification-code':
        return 'Invalid verification code';
      case 'invalid-verification-id':
        return 'Invalid verification ID';
      case 'quota-exceeded':
        return 'SMS quota exceeded. Please try again later';
      default:
        return 'Authentication failed. Please try again';
    }
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
      // Show error toast
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        title: Text('Login failed'),
        description: Text(_getAuthErrorMessage(e.code)),
        autoCloseDuration: const Duration(seconds: 4),
        icon: const Icon(Icons.error_outline),
      );

      throw FirebaseAuthException(
        code: e.code,
        message: e.message ?? 'Login failed',
      );
    } catch (e) {
      // Show error toast
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        title: Text('Login failed'),
        description: Text('An unexpected error occurred'),
        autoCloseDuration: const Duration(seconds: 4),
        icon: const Icon(Icons.error_outline),
      );

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
      // Show error toast
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        title: Text('Signup failed'),
        description: Text(_getAuthErrorMessage(e.code)),
        autoCloseDuration: const Duration(seconds: 4),
        icon: const Icon(Icons.error_outline),
      );

      throw FirebaseAuthException(
        code: e.code,
        message: e.message ?? 'Signup failed',
      );
    } catch (e) {
      // Show error toast
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        title: Text('Signup failed'),
        description: Text('An unexpected error occurred'),
        autoCloseDuration: const Duration(seconds: 4),
        icon: const Icon(Icons.error_outline),
      );

      throw Exception('Signup failed: $e');
    }
  }

  @override
  Future<String> loginWithPhone(String phoneNumber) async {
    AppLogger.log('Starting phone verification for: $phoneNumber',
        tag: 'AuthRemoteDataSource');
    Completer<String> verificationIdCompleter = Completer<String>();

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          AppLogger.logSuccess('Auto-verification completed for: $phoneNumber',
              tag: 'AuthRemoteDataSource');
          await _handlePhoneVerificationCompleted(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          AppLogger.logError(
              'Phone verification failed for $phoneNumber: ${e.message}',
              tag: 'AuthRemoteDataSource');
          if (!verificationIdCompleter.isCompleted) {
            verificationIdCompleter.completeError(FirebaseAuthException(
              code: e.code,
              message: e.message ?? 'Phone verification failed',
            ));
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          AppLogger.logSuccess('OTP code sent successfully for: $phoneNumber',
              tag: 'AuthRemoteDataSource');
          if (!verificationIdCompleter.isCompleted) {
            verificationIdCompleter.complete(verificationId);
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          AppLogger.logWarning('OTP auto-retrieval timeout for: $phoneNumber',
              tag: 'AuthRemoteDataSource');
          if (!verificationIdCompleter.isCompleted) {
            verificationIdCompleter.completeError(Exception('OTP timeout'));
          }
        },
      );

      final verificationId = await verificationIdCompleter.future;
      AppLogger.logSuccess(
          'Phone verification initiated successfully. Verification ID received',
          tag: 'AuthRemoteDataSource');
      return verificationId;
    } catch (e) {
      AppLogger.logError('Phone login failed for $phoneNumber: $e',
          tag: 'AuthRemoteDataSource');

      // Show error toast
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        title: Text('Phone login failed'),
        description: Text('Failed to send verification code'),
        autoCloseDuration: const Duration(seconds: 4),
        icon: const Icon(Icons.error_outline),
      );

      throw Exception('Phone login failed: $e');
    }
  }

  @override
  Future<void> verifyOTP(String verificationId, String otp) async {
    AppLogger.log(
        'Starting OTP verification with ID: ${verificationId.substring(0, 10)}...',
        tag: 'AuthRemoteDataSource');
    try {
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );

      AppLogger.log('PhoneAuthCredential created successfully',
          tag: 'AuthRemoteDataSource');
      await _handlePhoneVerificationCompleted(credential);
      AppLogger.logSuccess('OTP verification completed successfully',
          tag: 'AuthRemoteDataSource');
    } on FirebaseAuthException catch (e) {
      AppLogger.logError(
          'OTP verification failed with Firebase error: ${e.message}',
          tag: 'AuthRemoteDataSource');

      // Show error toast
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        title: Text('OTP verification failed'),
        description: Text(_getAuthErrorMessage(e.code)),
        autoCloseDuration: const Duration(seconds: 4),
        icon: const Icon(Icons.error_outline),
      );

      throw FirebaseAuthException(
        code: e.code,
        message: e.message ?? 'OTP verification failed',
      );
    } catch (e) {
      AppLogger.logError('OTP verification failed with general error: $e',
          tag: 'AuthRemoteDataSource');

      // Show error toast
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        title: Text('OTP verification failed'),
        description: Text('Invalid verification code'),
        autoCloseDuration: const Duration(seconds: 4),
        icon: const Icon(Icons.error_outline),
      );

      throw Exception('OTP verification failed: $e');
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      // Show error toast
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        title: Text('Password reset failed'),
        description: Text(_getAuthErrorMessage(e.code)),
        autoCloseDuration: const Duration(seconds: 4),
        icon: const Icon(Icons.error_outline),
      );

      throw FirebaseAuthException(
        code: e.code,
        message: e.message ?? 'Password reset failed',
      );
    } catch (e) {
      // Show error toast
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        title: Text('Password reset failed'),
        description: Text('An unexpected error occurred'),
        autoCloseDuration: const Duration(seconds: 4),
        icon: const Icon(Icons.error_outline),
      );

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
      // Show error toast
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        title: Text('Email verification failed'),
        description: Text(_getAuthErrorMessage(e.code)),
        autoCloseDuration: const Duration(seconds: 4),
        icon: const Icon(Icons.error_outline),
      );

      throw FirebaseAuthException(
        code: e.code,
        message: e.message ?? 'Email verification failed',
      );
    } catch (e) {
      // Show error toast
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        title: Text('Email verification failed'),
        description: Text('An unexpected error occurred'),
        autoCloseDuration: const Duration(seconds: 4),
        icon: const Icon(Icons.error_outline),
      );

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

      // Ensure user document exists in Firestore
      await _ensureUserDocumentExists(user);

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
      // Show error toast
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        title: Text('Google sign-in failed'),
        description: Text(_getAuthErrorMessage(e.code)),
        autoCloseDuration: const Duration(seconds: 4),
        icon: const Icon(Icons.error_outline),
      );

      throw FirebaseAuthException(
        code: e.code,
        message: e.message ?? 'Google sign-in failed',
      );
    } catch (e) {
      // Show error toast
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        title: Text('Google sign-in failed'),
        description: Text('An unexpected error occurred'),
        autoCloseDuration: const Duration(seconds: 4),
        icon: const Icon(Icons.error_outline),
      );

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

      // Ensure user document exists in Firestore
      await _ensureUserDocumentExists(user);

      // The Cloud Function will automatically create user data when a new user signs up
    } on FirebaseAuthException catch (e) {
      // Show error toast
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        title: Text('Google sign-up failed'),
        description: Text(_getAuthErrorMessage(e.code)),
        autoCloseDuration: const Duration(seconds: 4),
        icon: const Icon(Icons.error_outline),
      );

      throw FirebaseAuthException(
        code: e.code,
        message: e.message ?? 'Google sign-up failed',
      );
    } catch (e) {
      // Show error toast
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        title: Text('Google sign-up failed'),
        description: Text('An unexpected error occurred'),
        autoCloseDuration: const Duration(seconds: 4),
        icon: const Icon(Icons.error_outline),
      );

      throw Exception('Google sign-up failed: $e');
    }
  }

  // Helper method to ensure user document exists
  Future<void> _ensureUserDocumentExists(User user) async {
    try {
      final userDocRef = _firestore.collection('users').doc(user.uid);
      final userDoc = await userDocRef.get();

      if (!userDoc.exists) {
        // Create user document if it doesn't exist
        final userData = {
          'userId': user.uid,
          'email': user.email,
          'phoneNumber': user.phoneNumber,
          'name': user.displayName,
          'creditBalance': 10,
          'likedCards': [],
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        };

        await userDocRef.set(userData);

        // Create credits subcollection
        await userDocRef.collection('credits').doc('balance').set({
          'balance': 10,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Create initial transaction
        await userDocRef.collection('transactions').add({
          'userId': user.uid,
          'amount': 10,
          'createdAt': FieldValue.serverTimestamp(),
          'type': 'purchase',
          'status': 'completed',
          'description': 'Welcome bonus credits',
          'paymentMethod': 'signup_bonus',
        });

        print('User document created for Google sign-in: ${user.uid}');
      }
    } catch (e) {
      print('Error ensuring user document exists: $e');
      // Don't throw here as the user is already authenticated
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
      // Show error toast
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        title: Text('Phone sign-up failed'),
        description: Text(_getAuthErrorMessage(e.code)),
        autoCloseDuration: const Duration(seconds: 4),
        icon: const Icon(Icons.error_outline),
      );

      throw FirebaseAuthException(
        code: e.code,
        message: e.message ?? 'Credential sign-up failed',
      );
    } catch (e) {
      // Show error toast
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        title: Text('Phone sign-up failed'),
        description: Text('An unexpected error occurred'),
        autoCloseDuration: const Duration(seconds: 4),
        icon: const Icon(Icons.error_outline),
      );

      throw Exception('Credential sign-up failed: $e');
    }
  }

  // Helper method to handle phone verification completion
  Future<void> _handlePhoneVerificationCompleted(
      PhoneAuthCredential credential) async {
    AppLogger.log('Handling phone verification completion',
        tag: 'AuthRemoteDataSource');
    try {
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        AppLogger.logSuccess(
            'User signed in successfully with phone: ${user.phoneNumber}',
            tag: 'AuthRemoteDataSource');
        // Note: User document creation is now handled by Cloud Function onUserSignUp
        // The Cloud Function will automatically create user data when a new user signs up
      } else {
        AppLogger.logError('User is null after phone verification',
            tag: 'AuthRemoteDataSource');
      }
    } catch (e) {
      AppLogger.logError('Phone verification completion failed: $e',
          tag: 'AuthRemoteDataSource');
      throw Exception('Phone verification completion failed: $e');
    }
  }
}

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl();
});
