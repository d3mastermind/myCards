import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:mycards/features/account/user_state_notifier.dart';
import 'dart:io';
import 'package:mycards/widgets/loading_indicators/circular_loading_widget.dart';

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
      appBar: AppBar(
        title: Text(
          "Edit Profile",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: userState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : userState.user == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        userState.error ?? 'No user available',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          ref
                              .read(userStateNotifierProvider.notifier)
                              .refreshUserData();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Profile Image with Edit Icon
                      GestureDetector(
                        onTap: () {
                          _pickImage();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              CircleAvatar(
                                radius: 70,
                                backgroundImage: userState.profileImage != null
                                    ? FileImage(userState.profileImage!)
                                    : (userState.user!.profileImageUrl != null
                                        ? NetworkImage(
                                            userState.user!.profileImageUrl!)
                                        : null) as ImageProvider?,
                                backgroundColor: Colors.grey.shade300,
                                child: userState.profileImage == null &&
                                        userState.user!.profileImageUrl == null
                                    ? const Icon(Icons.person,
                                        size: 70, color: Colors.grey)
                                    : null,
                              ),
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.white,
                                child: Icon(Icons.edit,
                                    color: Colors.blue, size: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // User Name
                      Text(
                        userState.user!.name ?? userState.user!.email ?? "User",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 32),
                      // First Name Input
                      TextField(
                        controller: _firstNameController,
                        decoration: InputDecoration(
                          labelText: "Name",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Last Name Input
                      TextField(
                        controller: _lastNameController,
                        decoration: InputDecoration(
                          labelText: "Last Name",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: userState.isSaving ? null : _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrangeAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: userState.isSaving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularLoadingWidget(),
                                )
                              : Text(
                                  "Save",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge!
                                      .copyWith(
                                        color: Colors.white,
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
