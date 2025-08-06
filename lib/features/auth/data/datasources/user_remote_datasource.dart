import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import '../models/user_model.dart';

abstract class UserRemoteDataSource {
  Future<UserModel?> getUser(String userId);
  Future<void> updateUser(UserModel user);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final FirebaseFirestore firestore;
  final String _collection = 'users';

  UserRemoteDataSourceImpl({required this.firestore});

  // Helper method to get user-friendly Firebase error messages
  String _getFirebaseErrorMessage(String code) {
    switch (code) {
      case 'permission-denied':
        return 'Access denied. Please check your permissions.';
      case 'unavailable':
        return 'Network error. Please check your connection.';
      case 'deadline-exceeded':
        return 'Request timeout. Please try again.';
      case 'not-found':
        return 'User not found.';
      default:
        return 'Database error. Please try again.';
    }
  }

  @override
  Future<UserModel?> getUser(String userId) async {
    try {
      final DocumentSnapshot doc =
          await firestore.collection(_collection).doc(userId).get();

      if (doc.exists) {
        return UserModel.fromFirebase(
            doc.id, doc.data() as Map<String, dynamic>);
      }
      return null;
    } on FirebaseException catch (e) {
      // Show error toast
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        title: Text('Failed to get user'),
        description: Text(_getFirebaseErrorMessage(e.code)),
        autoCloseDuration: const Duration(seconds: 4),
        icon: const Icon(Icons.error_outline),
      );

      throw Exception('Failed to get user: $e');
    } catch (e) {
      // Show error toast
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        title: Text('Failed to get user'),
        description: Text('An unexpected error occurred'),
        autoCloseDuration: const Duration(seconds: 4),
        icon: const Icon(Icons.error_outline),
      );

      throw Exception('Failed to get user: $e');
    }
  }

  @override
  Future<void> updateUser(UserModel user) async {
    try {
      final updatedUser = user.copyWith(updatedAt: DateTime.now());
      await firestore
          .collection(_collection)
          .doc(user.userId)
          .update(updatedUser.toMap());
    } on FirebaseException catch (e) {
      // Show error toast
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        title: Text('Failed to update user'),
        description: Text(_getFirebaseErrorMessage(e.code)),
        autoCloseDuration: const Duration(seconds: 4),
        icon: const Icon(Icons.error_outline),
      );

      throw Exception('Failed to update user: $e');
    } catch (e) {
      // Show error toast
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        title: Text('Failed to update user'),
        description: Text('An unexpected error occurred'),
        autoCloseDuration: const Duration(seconds: 4),
        icon: const Icon(Icons.error_outline),
      );

      throw Exception('Failed to update user: $e');
    }
  }
}
