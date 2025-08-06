import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:mycards/features/account/user_state_notifier.dart';
import 'dart:io';
import 'package:mycards/widgets/loading_indicators/circular_loading_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileSettings extends ConsumerStatefulWidget {
  const ProfileSettings({super.key});

  @override
  ConsumerState<ProfileSettings> createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends ConsumerState<ProfileSettings> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final userState = ref.read(userStateNotifierProvider);
    if (userState.user != null) {
      _firstNameController.text = userState.firstName;
      _lastNameController.text = userState.lastName;
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();

    try {
      // Pick an image from the gallery
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        final userViewModel = ref.read(userStateNotifierProvider.notifier);
        userViewModel.setProfileImage(File(image.path));
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  Future<void> _saveProfile() async {
    final userViewModel = ref.read(userStateNotifierProvider.notifier);

    // Update the view model with current text field values
    userViewModel.updateFirstName(_firstNameController.text);
    userViewModel.updateLastName(_lastNameController.text);

    // Save profile
    final success = await userViewModel.saveProfile();

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        final userState = ref.read(userStateNotifierProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(userState.error ?? 'Failed to update profile')),
        );
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userStateNotifierProvider);

    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            // Custom App Bar
            Container(
              child: SafeArea(
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        child: IconButton(
                          icon:
                              const Icon(Icons.arrow_back, color: Colors.black),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Edit Profile',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(width: 48.w), // To balance the back button
                    ],
                  ),
                ),
              ),
            ),

            // Content
            Expanded(
              child: userState.isLoading
                  ? Center(
                      child: CircularLoadingWidget(
                        colors: [
                          const Color(0xFFFF5722),
                          const Color(0xFFFF7043),
                          Colors.deepOrange,
                          Colors.deepOrangeAccent
                        ],
                        size: 60,
                      ),
                    )
                  : userState.user == null
                      ? Container(
                          margin: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(16.r),
                            border:
                                Border.all(color: Colors.red.withOpacity(0.2)),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(16.w),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(50.r),
                                  ),
                                  child: Icon(
                                    Icons.error_outline,
                                    size: 48.sp,
                                    color: Colors.red,
                                  ),
                                ),
                                SizedBox(height: 16.h),
                                Text(
                                  userState.error ?? 'No user available',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: Colors.red.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 16.h),
                                Container(
                                  height: 40.h,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Colors.red, Color(0xFFE57373)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(20.r),
                                  ),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      ref
                                          .read(userStateNotifierProvider
                                              .notifier)
                                          .refreshUserData();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.r),
                                      ),
                                    ),
                                    child: Text(
                                      'Retry',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(height: 24.h),

                                // Profile Image with Edit Icon
                                GestureDetector(
                                  onTap: () {
                                    _pickImage();
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(80.r),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.orange.withOpacity(0.3),
                                          blurRadius: 15,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: Stack(
                                      alignment: Alignment.bottomRight,
                                      children: [
                                        CircleAvatar(
                                          radius: 70.r,
                                          backgroundColor: Colors.grey.shade200,
                                          child: userState.profileImage != null
                                              ? ClipOval(
                                                  child: Image.file(
                                                    userState.profileImage!,
                                                    width: 140.r,
                                                    height: 140.r,
                                                    fit: BoxFit.cover,
                                                  ),
                                                )
                                              : userState.user!
                                                          .profileImageUrl !=
                                                      null
                                                  ? ClipOval(
                                                      child: CachedNetworkImage(
                                                        imageUrl: userState
                                                            .user!
                                                            .profileImageUrl!,
                                                        width: 140.r,
                                                        height: 140.r,
                                                        fit: BoxFit.cover,
                                                        placeholder:
                                                            (context, url) =>
                                                                Container(
                                                          width: 140.r,
                                                          height: 140.r,
                                                          color:
                                                              Colors.grey[300],
                                                          child: Center(
                                                            child:
                                                                CircularLoadingWidget(
                                                              colors: [
                                                                const Color(
                                                                    0xFFFF5722),
                                                                const Color(
                                                                    0xFFFF7043),
                                                                Colors
                                                                    .deepOrange,
                                                                Colors
                                                                    .deepOrangeAccent
                                                              ],
                                                              size: 30,
                                                            ),
                                                          ),
                                                        ),
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            Container(
                                                          width: 140.r,
                                                          height: 140.r,
                                                          color:
                                                              Colors.grey[300],
                                                          child: Icon(
                                                            Icons.person,
                                                            size: 70.sp,
                                                            color: Colors
                                                                .grey[600],
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  : Icon(
                                                      Icons.person,
                                                      size: 70.sp,
                                                      color: Colors.grey[600],
                                                    ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.all(8.w),
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFFFF5722),
                                                Color(0xFFFF7043)
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(50.r),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.orange
                                                    .withOpacity(0.4),
                                                blurRadius: 8,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Icon(
                                            Icons.camera_alt,
                                            color: Colors.white,
                                            size: 20.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                SizedBox(height: 20.h),

                                // User Name
                                Text(
                                  userState.user!.name ??
                                      userState.user!.email ??
                                      "User",
                                  style: TextStyle(
                                    fontSize: 22.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),

                                SizedBox(height: 32.h),

                                // Form Fields
                                Container(
                                  padding: EdgeInsets.all(20.w),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(16.r),
                                    border: Border.all(
                                        color: Colors.grey.withOpacity(0.2)),
                                  ),
                                  child: Column(
                                    children: [
                                      // First Name Input
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12.r),
                                          border: Border.all(
                                              color: Colors.grey[300]!),
                                        ),
                                        child: TextField(
                                          controller: _firstNameController,
                                          decoration: InputDecoration(
                                            labelText: "First Name",
                                            prefixIcon: Icon(
                                              Icons.person_outline,
                                              color: const Color(0xFFE65100),
                                              size: 20.sp,
                                            ),
                                            border: InputBorder.none,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 16.w,
                                                    vertical: 16.h),
                                            labelStyle: TextStyle(
                                                color: Colors.grey[600]),
                                          ),
                                        ),
                                      ),

                                      SizedBox(height: 16.h),

                                      // Last Name Input
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12.r),
                                          border: Border.all(
                                              color: Colors.grey[300]!),
                                        ),
                                        child: TextField(
                                          controller: _lastNameController,
                                          decoration: InputDecoration(
                                            labelText: "Last Name",
                                            prefixIcon: Icon(
                                              Icons.person_outline,
                                              color: const Color(0xFFE65100),
                                              size: 20.sp,
                                            ),
                                            border: InputBorder.none,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 16.w,
                                                    vertical: 16.h),
                                            labelStyle: TextStyle(
                                                color: Colors.grey[600]),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(height: 40.h),

                                // Save Button
                                Container(
                                  width: double.infinity,
                                  height: 56.h,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFFF5722),
                                        Color(0xFFFF7043)
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.orange.withOpacity(0.4),
                                        blurRadius: 12,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: userState.isSaving
                                        ? null
                                        : _saveProfile,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16.r),
                                      ),
                                    ),
                                    child: userState.isSaving
                                        ? CircularLoadingWidget(
                                            colors: [
                                              Colors.white,
                                              Colors.white70
                                            ],
                                            size: 24,
                                          )
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.save,
                                                color: Colors.white,
                                                size: 20.sp,
                                              ),
                                              SizedBox(width: 8.w),
                                              Text(
                                                "Save Profile",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),

                                SizedBox(height: 20.h),
                              ],
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
