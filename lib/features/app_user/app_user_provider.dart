import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mycards/core/utils/logger.dart';
import 'package:mycards/core/utils/storage_bucket.dart';
import 'package:mycards/features/auth/data/models/user_model.dart';
import 'package:mycards/features/auth/domain/entities/user_entity.dart';
import 'dart:async'; // Added for Completer

class AppUserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StorageBucket _storageBucket;

  static const String _userKey = 'currentUser';

  // Singleton instance
  static AppUserService? _instance;
  static AppUserService get instance {
    _instance ??= AppUserService._internal();
    return _instance!;
  }

  AppUserService._internal() : _storageBucket = StorageBucket() {
    _initialize();
  }

  // Current user state
  UserEntity? _currentUser;
  UserEntity? get currentUser => _currentUser;

  // Add a completer to track initialization
  Completer<void>? _initializationCompleter;
  bool _isInitialized = false;

  // Method to force refresh user data from Firestore
  Future<void> forceRefreshUserData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        AppLogger.log('No authenticated user for force refresh',
            tag: 'AppUserService');
        return;
      }

      AppLogger.log('Force refreshing user data for: ${user.uid}',
          tag: 'AppUserService');
      await _loadUserData(user);
    } catch (e) {
      AppLogger.logError('Error force refreshing user data: $e',
          tag: 'AppUserService');
    }
  }

  // Method to wait for initialization
  Future<void> waitForInitialization() async {
    if (_isInitialized) return;

    _initializationCompleter ??= Completer<void>();
    await _initializationCompleter!.future;
  }

  Future<void> loadUser() async {
    await _loadUserData(_auth.currentUser!);
  }

  void _initialize() {
    AppLogger.log('AppUserService: Starting initialization',
        tag: 'AppUserService');

    // First, try to load from storage immediately
    _loadFromStorage();

    // Then listen to auth state changes
    _auth.authStateChanges().listen((User? user) {
      AppLogger.log('AppUserService: Auth state changed - User: ${user?.uid}',
          tag: 'AppUserService');

      if (user != null) {
        // Only load from Firestore if we don't already have user data
        if (_currentUser == null) {
          AppLogger.log(
              'AppUserService: No user in state, loading from Firestore',
              tag: 'AppUserService');
          _loadUserData(user);
        } else {
          // We already have user data from storage, just verify it's the same user
          AppLogger.log(
              'AppUserService: User in state: ${_currentUser!.userId}, Auth user: ${user.uid}',
              tag: 'AppUserService');
          if (_currentUser!.userId != user.uid) {
            // Different user, reload data
            AppLogger.log(
                'AppUserService: Different user, reloading from Firestore',
                tag: 'AppUserService');
            _loadUserData(user);
          } else {
            AppLogger.log('AppUserService: Same user, keeping existing data',
                tag: 'AppUserService');
            _completeInitialization();
          }
        }
      } else {
        // User signed out
        AppLogger.log('AppUserService: User signed out, clearing state',
            tag: 'AppUserService');
        _currentUser = null;
        _clearUser();
        _completeInitialization();
      }
    });
  }

  void _completeInitialization() {
    if (!_isInitialized) {
      _isInitialized = true;
      _initializationCompleter?.complete();
      AppLogger.log('AppUserService: Initialization completed',
          tag: 'AppUserService');
    }
  }

  Future<void> _loadUserData(User user) async {
    try {
      AppLogger.log('Loading user data for: ${user.uid}',
          tag: 'AppUserService');

      // Add retry logic for Google sign-in
      int retryCount = 0;
      const maxRetries = 3;

      while (retryCount < maxRetries) {
        try {
          final userDoc =
              await _firestore.collection('users').doc(user.uid).get();
          final userData = userDoc.data();

          if (userData == null) {
            AppLogger.log(
                'No user data found in Firestore, retrying... (${retryCount + 1}/$maxRetries)',
                tag: 'AppUserService');
            retryCount++;
            if (retryCount < maxRetries) {
              await Future.delayed(
                  Duration(seconds: retryCount)); // Exponential backoff
              continue;
            } else {
              AppLogger.logError(
                  'No user data found in Firestore after $maxRetries retries',
                  tag: 'AppUserService');
              _completeInitialization();
              return;
            }
          }

          AppLogger.logSuccess('User data fetched successfully',
              tag: 'AppUserService');

          try {
            final userEntity = UserModel.fromMap(userData);
            _currentUser = userEntity;
            await _saveUserToStorage(userEntity);
            _completeInitialization();
            return;
          } catch (e) {
            AppLogger.logError('Error parsing user data from Firestore: $e',
                tag: 'AppUserService');
            AppLogger.logError('User data that caused error: $userData',
                tag: 'AppUserService');
            retryCount++;
            if (retryCount < maxRetries) {
              await Future.delayed(Duration(seconds: retryCount));
              continue;
            } else {
              AppLogger.logError(
                  'Failed to parse user data after $maxRetries attempts: $e',
                  tag: 'AppUserService');
              _completeInitialization();
              return;
            }
          }
        } catch (e) {
          AppLogger.logError(
              'Error loading user data (attempt ${retryCount + 1}): $e',
              tag: 'AppUserService');
          retryCount++;
          if (retryCount < maxRetries) {
            await Future.delayed(Duration(seconds: retryCount));
          } else {
            AppLogger.logError(
                'Failed to load user data after $maxRetries attempts: $e',
                tag: 'AppUserService');
            _completeInitialization();
            return;
          }
        }
      }
    } catch (e) {
      AppLogger.logError('Error loading user data: $e', tag: 'AppUserService');
      _completeInitialization();
    }
  }

  Future<void> _loadFromStorage() async {
    try {
      AppLogger.log('AppUserService: Attempting to load user from storage',
          tag: 'AppUserService');

      final user = _storageBucket.getCachedObject<UserModel>(
        _userKey,
        (json) => UserModel.fromStorageMap(json),
      );

      if (user != null) {
        AppLogger.log(
            'AppUserService: User loaded from storage: ${user.userId}',
            tag: 'AppUserService');
        AppLogger.log('AppUserService: User data: ${user.toStorageMap()}',
            tag: 'AppUserService');
        _currentUser = user;
      } else {
        AppLogger.log('AppUserService: No user found in storage',
            tag: 'AppUserService');
      }
    } catch (e) {
      AppLogger.logError('AppUserService: Error loading user from storage: $e',
          tag: 'AppUserService');
    }
  }

  Future<void> _saveUserToStorage(UserEntity user) async {
    try {
      AppLogger.log('AppUserService: Saving user to storage - ${user.userId}',
          tag: 'AppUserService');

      final userMap = (user as UserModel).toStorageMap();
      AppLogger.log('AppUserService: User map for storage: $userMap',
          tag: 'AppUserService');

      await _storageBucket.storeObject<UserModel>(
        _userKey,
        user,
        (user) => (user as UserModel).toStorageMap(),
      );
      AppLogger.logSuccess('AppUserService: User saved to storage successfully',
          tag: 'AppUserService');
    } catch (e) {
      AppLogger.logError('AppUserService: Error saving user to storage: $e',
          tag: 'AppUserService');
    }
  }

  Future<void> _clearUser() async {
    try {
      AppLogger.log('Clearing user data...', tag: 'AppUserService');
      await _storageBucket.deleteStoredBuiltInType(_userKey);
      AppLogger.logSuccess('User data cleared successfully',
          tag: 'AppUserService');
    } catch (e) {
      AppLogger.logError('Error clearing user data: $e', tag: 'AppUserService');
    }
  }

  // Update user name
  Future<bool> updateUserName(String newName) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        AppLogger.logError('User not authenticated', tag: 'AppUserService');
        return false;
      }

      if (newName.trim().isEmpty) {
        AppLogger.logError('Name cannot be empty', tag: 'AppUserService');
        return false;
      }

      // Update Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'name': newName.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update local state
      if (_currentUser != null) {
        final updatedUser = UserModel(
          userId: _currentUser!.userId,
          email: _currentUser!.email,
          phoneNumber: _currentUser!.phoneNumber,
          name: newName.trim(),
          creditBalance: _currentUser!.creditBalance,
          profileImageUrl: _currentUser!.profileImageUrl,
          createdAt: _currentUser!.createdAt,
          updatedAt: _currentUser!.updatedAt,
        );

        _currentUser = updatedUser;
        await _saveUserToStorage(updatedUser);
      }

      AppLogger.logSuccess('User name updated successfully',
          tag: 'AppUserService');
      return true;
    } catch (e) {
      AppLogger.logError('Error updating user name: $e', tag: 'AppUserService');
      return false;
    }
  }

  // Update user profile image
  Future<bool> updateProfileImage(String imageUrl) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        AppLogger.logError('User not authenticated', tag: 'AppUserService');
        return false;
      }

      if (imageUrl.trim().isEmpty) {
        AppLogger.logError('Image URL cannot be empty', tag: 'AppUserService');
        return false;
      }

      // Update Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'profileImageUrl': imageUrl.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update local state
      if (_currentUser != null) {
        final updatedUser = UserModel(
          userId: _currentUser!.userId,
          email: _currentUser!.email,
          phoneNumber: _currentUser!.phoneNumber,
          name: _currentUser!.name,
          profileImageUrl: imageUrl.trim(),
          creditBalance: _currentUser!.creditBalance,
          createdAt: _currentUser!.createdAt,
          updatedAt: _currentUser!.updatedAt,
        );

        _currentUser = updatedUser;
        await _saveUserToStorage(updatedUser);
      }

      AppLogger.logSuccess('Profile image updated successfully',
          tag: 'AppUserService');
      return true;
    } catch (e) {
      AppLogger.logError('Error updating profile image: $e',
          tag: 'AppUserService');
      return false;
    }
  }

  // Method for complete cleanup during logout
  Future<void> completeCleanup() async {
    try {
      AppLogger.log('Starting complete cleanup...', tag: 'AppUserService');

      // Clear user data from StorageBucket
      await _storageBucket.deleteStoredBuiltInType(_userKey);
      _currentUser = null;

      AppLogger.logSuccess('Complete cleanup finished', tag: 'AppUserService');
    } catch (e) {
      AppLogger.logError('Error during complete cleanup: $e',
          tag: 'AppUserService');
      rethrow;
    }
  }

  void logout() {
    _auth.signOut();
    _currentUser = null;
    _clearUser();
  }
}

final appUserServiceProvider = Provider<AppUserService>((ref) {
  return AppUserService.instance;
});
