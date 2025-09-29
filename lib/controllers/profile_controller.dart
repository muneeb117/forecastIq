import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/auth_service.dart';

class ProfileController extends GetxController {
  // Services
  final AuthService _authService = Get.find<AuthService>();

  // Form controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  // Observable state
  final RxBool isLoading = false.obs;
  final RxBool isUpdating = false.obs;
  final Rx<File?> selectedImage = Rx<File?>(null);

  // Image picker
  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    super.onClose();
  }

  // Load user data
  void _loadUserData() {
    emailController.text = _authService.userEmail ?? '';
    nameController.text = _authService.userName ?? '';
  }

  // Image picking
  Future<void> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (image != null) {
        selectedImage.value = File(image.path);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to capture image: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  Future<void> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (image != null) {
        selectedImage.value = File(image.path);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  // Show image picker options
  void showImagePicker() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Profile Picture',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImageOption(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () {
                    Get.back();
                    pickImageFromCamera();
                  },
                ),
                _buildImageOption(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: () {
                    Get.back();
                    pickImageFromGallery();
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildImageOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 30, color: Colors.grey[600]),
          ),
          SizedBox(height: 10),
          Text(label, style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  // Update profile
  Future<void> updateProfile() async {
    try {
      isUpdating.value = true;

      final success = await _authService.updateProfile(
        fullName: nameController.text.trim().isEmpty ? null : nameController.text.trim(),
        profileImage: selectedImage.value,
      );

      if (success) {
        selectedImage.value = null;
        Get.snackbar(
          'Success',
          'Profile updated successfully!',
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update profile: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isUpdating.value = false;
    }
  }

  // Update email
  Future<void> updateEmail() async {
    try {
      isUpdating.value = true;

      final success = await _authService.updateEmail(
        newEmail: emailController.text.trim(),
      );

      if (success) {
        Get.snackbar(
          'Success',
          'Email update initiated! Check your new email for confirmation.',
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update email: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isUpdating.value = false;
    }
  }

  // Update password
  Future<void> updatePassword(String newPassword) async {
    try {
      isUpdating.value = true;

      final success = await _authService.updatePassword(
        newPassword: newPassword,
      );

      if (success) {
        Get.snackbar(
          'Success',
          'Password updated successfully!',
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update password: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isUpdating.value = false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      isLoading.value = true;
      await _authService.signOut();
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to sign out: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Getters for reactive UI
  String? get userName => _authService.userName;
  String? get userEmail => _authService.userEmail;
  String? get userProfileImage => _authService.userProfileImage;
  bool get hasChanges =>
      nameController.text.trim() != (_authService.userName ?? '') ||
      emailController.text.trim() != (_authService.userEmail ?? '') ||
      selectedImage.value != null;
}