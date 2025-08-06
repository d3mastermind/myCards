import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:toastification/toastification.dart';
import 'package:mycards/core/utils/logger.dart';
import 'package:mycards/features/app_user/app_user_provider.dart';
import 'package:mycards/features/auth/domain/entities/user_entity.dart';

// State class for user management
class UserState {
  final UserEntity? user;
  final File? profileImage;
  final String firstName;
  final String lastName;
  final bool isLoading;
  final String? error;
  final bool isSaving;

  const UserState({
    this.user,
    this.profileImage,
    this.firstName = '',
    this.lastName = '',
    this.isLoading = false,
    this.error,
    this.isSaving = false,
  });

  UserState copyWith({
    UserEntity? user,
    File? profileImage,
    String? firstName,
    String? lastName,
    bool? isLoading,
    String? error,
    bool? isSaving,
  }) {
    return UserState(
      user: user ?? this.user,
      profileImage: profileImage ?? this.profileImage,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

// Unified StateNotifier for user management
class UserStateNotifier extends StateNotifier<UserState> {
  final AppUserService _appUserService;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  UserStateNotifier({required AppUserService appUserService})
      : _appUserService = appUserService,
        super(const UserState()) {
    _initialize();
  }

  void _initialize() {
    AppLogger.log('UserStateNotifier: Initializing', tag: 'UserStateNotifier');
    // Start with loading state
    state = state.copyWith(isLoading: true);
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      AppLogger.log('UserStateNotifier: Loading user data',
          tag: 'UserStateNotifier');

      // Wait for AppUserService to be properly initialized
      await _appUserService.waitForInitialization();

      final user = _appUserService.currentUser;

      if (user != null) {
        AppLogger.log('UserStateNotifier: User loaded: ${user.userId}',
            tag: 'UserStateNotifier');
        _updateStateFromUser(user);
      } else {
        AppLogger.log(
            'UserStateNotifier: No user available, trying force refresh...',
            tag: 'UserStateNotifier');

        // Try to force refresh user data
        await _appUserService.forceRefreshUserData();
        final refreshedUser = _appUserService.currentUser;

        if (refreshedUser != null) {
          AppLogger.log(
              'UserStateNotifier: User data refreshed: ${refreshedUser.userId}',
              tag: 'UserStateNotifier');
          _updateStateFromUser(refreshedUser);
        } else {
          AppLogger.log(
              'UserStateNotifier: Still no user available after refresh',
              tag: 'UserStateNotifier');
          state = state.copyWith(
            user: null,
            isLoading: false,
            error: 'No user available',
          );
        }
      }
    } catch (e) {
      AppLogger.logError('UserStateNotifier: Error loading user data: $e',
          tag: 'UserStateNotifier');

      // Show error toast
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        title: Text('Failed to load user data'),
        description: Text('Please try again later'),
        autoCloseDuration: const Duration(seconds: 4),
        icon: const Icon(Icons.error_outline),
      );

      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  void _updateStateFromUser(UserEntity user) {
    // Split name into first and last name
    final nameParts = user.name?.split(' ') ?? [];
    final firstName = nameParts.isNotEmpty ? nameParts.first : '';
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    state = state.copyWith(
      user: user,
      firstName: firstName,
      lastName: lastName,
      isLoading: false,
      error: null,
    );
  }

  // Profile management methods
  void updateFirstName(String firstName) {
    AppLogger.log('UserStateNotifier: Updating first name: $firstName',
        tag: 'UserStateNotifier');
    state = state.copyWith(firstName: firstName);
  }

  void updateLastName(String lastName) {
    AppLogger.log('UserStateNotifier: Updating last name: $lastName',
        tag: 'UserStateNotifier');
    state = state.copyWith(lastName: lastName);
  }

  void setProfileImage(File image) {
    AppLogger.log('UserStateNotifier: Setting profile image',
        tag: 'UserStateNotifier');
    state = state.copyWith(profileImage: image);
  }

  Future<String?> uploadProfileImage(File imageFile) async {
    try {
      AppLogger.log('UserStateNotifier: Starting profile image upload',
          tag: 'UserStateNotifier');

      final user = state.user;
      if (user == null) {
        AppLogger.logError(
            'UserStateNotifier: No user available for image upload',
            tag: 'UserStateNotifier');
        return null;
      }

      // Create a unique filename for the profile image
      final fileName =
          'profile_images/${user.userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Create a reference to the file location
      final storageRef = _firebaseStorage.ref().child(fileName);

      // Upload the file
      final uploadTask = storageRef.putFile(imageFile);

      // Wait for the upload to complete
      final snapshot = await uploadTask;

      // Get the download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();

      AppLogger.logSuccess(
          'UserStateNotifier: Profile image uploaded successfully: $downloadUrl',
          tag: 'UserStateNotifier');

      return downloadUrl;
    } catch (e) {
      AppLogger.logError('UserStateNotifier: Error uploading profile image: $e',
          tag: 'UserStateNotifier');

      // Show error toast
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        title: Text('Failed to upload profile image'),
        description: Text('Please try again later'),
        autoCloseDuration: const Duration(seconds: 4),
        icon: const Icon(Icons.error_outline),
      );

      return null;
    }
  }

  Future<bool> saveProfile() async {
    try {
      AppLogger.log('UserStateNotifier: Saving profile',
          tag: 'UserStateNotifier');

      // Validate first name
      if (state.firstName.trim().isEmpty) {
        AppLogger.logError('UserStateNotifier: First name cannot be empty',
            tag: 'UserStateNotifier');
        state = state.copyWith(
          error: 'First name cannot be empty',
          isSaving: false,
        );
        return false;
      }

      state = state.copyWith(isSaving: true, error: null);

      // Create full name
      final fullName =
          '${state.firstName.trim()} ${state.lastName.trim()}'.trim();

      // Update user name using AppUserService
      final nameUpdated = await _appUserService.updateUserName(fullName);

      if (!nameUpdated) {
        AppLogger.logError('UserStateNotifier: Failed to update user name',
            tag: 'UserStateNotifier');
        state = state.copyWith(
          error: 'Failed to update profile',
          isSaving: false,
        );
        return false;
      }

      // Handle profile image upload
      if (state.profileImage != null) {
        AppLogger.log('UserStateNotifier: Uploading profile image',
            tag: 'UserStateNotifier');

        final imageUrl = await uploadProfileImage(state.profileImage!);

        if (imageUrl != null) {
          final imageUpdated =
              await _appUserService.updateProfileImage(imageUrl);
          if (!imageUpdated) {
            AppLogger.logError(
                'UserStateNotifier: Failed to update profile image',
                tag: 'UserStateNotifier');
            state = state.copyWith(
              error: 'Failed to update profile image',
              isSaving: false,
            );
            return false;
          }
          AppLogger.logSuccess(
              'UserStateNotifier: Profile image updated successfully',
              tag: 'UserStateNotifier');
        } else {
          AppLogger.logError(
              'UserStateNotifier: Failed to upload profile image',
              tag: 'UserStateNotifier');
          state = state.copyWith(
            error: 'Failed to upload profile image',
            isSaving: false,
          );
          return false;
        }
      }

      AppLogger.logSuccess('UserStateNotifier: Profile saved successfully',
          tag: 'UserStateNotifier');
      state = state.copyWith(isSaving: false);

      // Reload user data to get updated information from AppUserService
      _loadUserData();

      return true;
    } catch (e) {
      AppLogger.logError('UserStateNotifier: Error saving profile: $e',
          tag: 'UserStateNotifier');

      // Show error toast
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        title: Text('Failed to save profile'),
        description: Text('Please try again later'),
        autoCloseDuration: const Duration(seconds: 4),
        icon: const Icon(Icons.error_outline),
      );

      state = state.copyWith(
        error: e.toString(),
        isSaving: false,
      );
      return false;
    }
  }

  // Account management methods
  Future<void> refreshUserData() async {
    AppLogger.log('UserStateNotifier: Refreshing user data',
        tag: 'UserStateNotifier');
    state = state.copyWith(isLoading: true, error: null);
    await _loadUserData();
  }

  Future<void> logout() async {
    AppLogger.log('UserStateNotifier: Logging out', tag: 'UserStateNotifier');
    state = state.copyWith(isLoading: true);

    try {
      await _appUserService.completeCleanup();
      state = const UserState();
      AppLogger.log('UserStateNotifier: Logout completed',
          tag: 'UserStateNotifier');
    } catch (e) {
      AppLogger.logError('UserStateNotifier: Error during logout: $e',
          tag: 'UserStateNotifier');

      // Show error toast
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        title: Text('Logout failed'),
        description: Text('Please try again later'),
        autoCloseDuration: const Duration(seconds: 4),
        icon: const Icon(Icons.error_outline),
      );

      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> completeCleanup() async {
    try {
      AppLogger.log('UserStateNotifier: Starting complete cleanup',
          tag: 'UserStateNotifier');
      state = state.copyWith(isLoading: true);

      await _appUserService.completeCleanup();

      AppLogger.logSuccess('UserStateNotifier: Complete cleanup finished',
          tag: 'UserStateNotifier');
      state = state.copyWith(
        user: null,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      AppLogger.logError('UserStateNotifier: Error during complete cleanup: $e',
          tag: 'UserStateNotifier');

      // Show error toast
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        title: Text('Cleanup failed'),
        description: Text('Please try again later'),
        autoCloseDuration: const Duration(seconds: 4),
        icon: const Icon(Icons.error_outline),
      );

      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  // Getter methods for user data
  UserEntity? get currentUser => _appUserService.currentUser;
  bool get isUserAvailable => _appUserService.currentUser != null;
  int get userCreditBalance => _appUserService.currentUser?.creditBalance ?? 0;
  String get userName =>
      _appUserService.currentUser?.name ??
      _appUserService.currentUser?.email ??
      'User';
  String? get userProfileImageUrl =>
      _appUserService.currentUser?.profileImageUrl;
}

// Provider for UserStateNotifier
final userStateNotifierProvider =
    StateNotifierProvider<UserStateNotifier, UserState>((ref) {
  final appUserService = ref.watch(appUserServiceProvider);
  return UserStateNotifier(appUserService: appUserService);
});
