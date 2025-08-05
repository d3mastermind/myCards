import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
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

      // TODO: Handle profile image upload when image upload functionality is available
      // if (state.profileImage != null) {
      //   final imageUrl = await uploadImage(state.profileImage!);
      //   final imageUpdated = await _appUserService.updateProfileImage(imageUrl);
      //   if (!imageUpdated) {
      //     AppLogger.logError('UserStateNotifier: Failed to update profile image', tag: 'UserStateNotifier');
      //     state = state.copyWith(
      //       error: 'Failed to update profile image',
      //       isSaving: false,
      //     );
      //     return false;
      //   }
      // }

      AppLogger.logSuccess('UserStateNotifier: Profile saved successfully',
          tag: 'UserStateNotifier');
      state = state.copyWith(isSaving: false);

      // Reload user data to get updated information from AppUserService
      _loadUserData();

      return true;
    } catch (e) {
      AppLogger.logError('UserStateNotifier: Error saving profile: $e',
          tag: 'UserStateNotifier');
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
