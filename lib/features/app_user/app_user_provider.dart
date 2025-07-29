import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mycards/core/utils/logger.dart';
import 'package:mycards/core/utils/storage_bucket.dart';
import 'package:mycards/di/service_locator.dart';
import 'package:mycards/features/auth/data/models/user_model.dart';
import 'package:mycards/features/auth/domain/entities/user_entity.dart';

class AppUserService extends StateNotifier<UserEntity?> {
  final Ref ref;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StorageBucket _storageBucket;
  AppUserService(this.ref, this._storageBucket) : super(null) {
    loadFromStorage();
  }

  Future<void> init() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return;
      }
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userData = userDoc.data();
      if (userData == null) {
        return;
      }
      AppLogger.logSuccess('User data fetched successfully');
      state = UserModel.fromMap(userData);
      saveUserToStorage(state!);
    } catch (e) {
      AppLogger.logError(e.toString());
    }
  }

  Future<void> loadFromStorage() async {
    final user = _storageBucket.getCachedObject(
      'user',
      (json) => UserModel.fromMap(json),
    );
    if (user == null) {
      await init();
      return;
    }
    state = user;
  }

  Future<void> saveUserToStorage(UserEntity user) async {
    _storageBucket.storeObject(
      'user',
      user,
      (user) => (user as UserModel).toMap(),
    );
  }

  // Update user name
  Future<bool> updateUserName(String newName) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        AppLogger.logError('User not authenticated');
        return false;
      }

      if (newName.trim().isEmpty) {
        AppLogger.logError('Name cannot be empty');
        return false;
      }

      // Update Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'name': newName.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update local state
      if (state != null) {
        final updatedUser = UserModel(
          userId: state!.userId,
          email: state!.email,
          phoneNumber: state!.phoneNumber,
          name: newName.trim(),
          creditBalance: state!.creditBalance,
          profileImageUrl: state!.profileImageUrl,
          createdAt: state!.createdAt,
          updatedAt: state!.updatedAt,
        );

        state = updatedUser;
        saveUserToStorage(updatedUser);
      }

      AppLogger.logSuccess('User name updated successfully');
      return true;
    } catch (e) {
      AppLogger.logError('Error updating user name: $e');
      return false;
    }
  }

  // Update user profile image
  Future<bool> updateProfileImage(String imageUrl) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        AppLogger.logError('User not authenticated');
        return false;
      }

      if (imageUrl.trim().isEmpty) {
        AppLogger.logError('Image URL cannot be empty');
        return false;
      }

      // Update Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'profileImageUrl': imageUrl.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update local state
      if (state != null) {
        final updatedUser = UserModel(
          userId: state!.userId,
          email: state!.email,
          phoneNumber: state!.phoneNumber,
          name: state!.name,
          profileImageUrl: imageUrl.trim(),
          creditBalance: state!.creditBalance,
          createdAt: state!.createdAt,
          updatedAt: state!.updatedAt,
        );

        state = updatedUser;
        saveUserToStorage(updatedUser);
      }

      AppLogger.logSuccess('Profile image updated successfully');
      return true;
    } catch (e) {
      AppLogger.logError('Error updating profile image: $e');
      return false;
    }
  }

  void logout() {
    _auth.signOut();
    state = null;
    _storageBucket.deleteStoredBuiltInType('user');
  }
}

final appUserProvider = StateNotifierProvider<AppUserService, UserEntity?>(
  (ref) => AppUserService(
    ref,
    ref.read(storageBucketProvider),
  ),
);
