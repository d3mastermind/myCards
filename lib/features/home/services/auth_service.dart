import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mycards/features/auth/presentation/verify_otp/otp_verification_view.dart';
import 'package:mycards/main.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser {
    final user = _auth.currentUser;
    return user;
  }

  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }

  // Stream to listen for user changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Email and password sign up
  Future<UserCredential> signUpWithEmail(String email, String password) async {
    final UserCredential userCredential = await _auth
        .createUserWithEmailAndPassword(email: email, password: password);

    // Note: User document creation is now handled by Cloud Function onUserSignUp
    // The Cloud Function will automatically create user data when a new user signs up

    return userCredential;
  }

  // Email and password sign in
  Future<UserCredential> signInWithEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  // Password reset
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> resendOtp(String phoneNumber) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {},
      codeSent: (String verificationId, int? resendToken) {},
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  Future<void> signUpWithPhone(String phoneNumber, BuildContext context) async {
    // Confirm the phone number
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Sign in the user
        final UserCredential userCredential =
            await _auth.signInWithCredential(credential);

        // Note: User document creation is now handled by Cloud Function onUserSignUp
        // The Cloud Function will automatically create user data when a new user signs up

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MyApp()),
          (route) => false,
        );
      },
      verificationFailed: (FirebaseAuthException e) {
        // Handle verification failure
      },
      codeSent: (String verificationId, int? resendToken) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpVerificationScreen(
              firebaseOtp: verificationId,
              phoneNumber: phoneNumber,
            ),
          ),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // Handle auto-retrieval timeout
      },
    );
  }

  Future<UserCredential> signUpWithCredential(
      PhoneAuthCredential credential) async {
    final UserCredential userCredential =
        await _auth.signInWithCredential(credential);

    // Note: User document creation is now handled by Cloud Function onUserSignUp
    // The Cloud Function will automatically create user data when a new user signs up

    return userCredential;
  }

  Future<UserCredential> signUpWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;
    final UserCredential userCredential =
        await _auth.signInWithCredential(GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    ));

    // Note: User document creation is now handled by Cloud Function onUserSignUp
    // The Cloud Function will automatically create user data when a new user signs up

    return userCredential;
  }

  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;
    return await _auth.signInWithCredential(GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    ));
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await GoogleSignIn().signOut();
  }
}
