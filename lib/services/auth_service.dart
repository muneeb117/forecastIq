import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:crypto/crypto.dart';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/services.dart';

class AuthService extends GetxController {
  static AuthService get instance => Get.find();
  final SupabaseClient _supabase = Supabase.instance.client;

  Rx<User?> currentUser = Rx<User?>(null);
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    currentUser.value = _supabase.auth.currentUser;
    _supabase.auth.onAuthStateChange.listen((data) {
      currentUser.value = data.session?.user;
    });
  }

  Future<AuthResponse?> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      isLoading.value = true;

      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: fullName != null ? {'full_name': fullName} : null,
      );

      if (response.user != null) {
        Get.snackbar(
          'Success',
          'Account created successfully! Please check your email for OTP verification.',
          snackPosition: SnackPosition.TOP,
        );
      }

      return response;
    } on AuthException catch (e) {
      Get.snackbar(
        'Error',
        e.message,
        snackPosition: SnackPosition.TOP,
      );
      return null;
    } catch (e) {
      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        snackPosition: SnackPosition.TOP,
      );
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<AuthResponse?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        Get.snackbar(
          'Success',
          'Signed in successfully!',
          snackPosition: SnackPosition.TOP,
        );
      }

      return response;
    } on AuthException catch (e) {
      Get.snackbar(
        'Error',
        e.message,
        snackPosition: SnackPosition.TOP,
      );
      return null;
    } catch (e) {
      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        snackPosition: SnackPosition.TOP,
      );
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<AuthResponse?> signInWithGoogle() async {
    try {
      isLoading.value = true;
      print('🔵 Starting Google Sign-In process...');

      // Try different client ID configurations
      final List<String> clientIds = [
        '768547120295-cacuhetuo1bjqi2h1hk9q1geh9ng11qi.apps.googleusercontent.com', // Android
        '768547120295-s5tjag3ccpqjpugf3rdng8sfh6j3pr6q.apps.googleusercontent.com', // Web
      ];

      GoogleSignInAccount? googleUser;
      GoogleSignIn? workingGoogleSignIn;

      // Try each client ID until one works
      for (String clientId in clientIds) {
        try {
          print('🔵 Trying client ID: ${clientId.substring(0, 20)}...');

          final GoogleSignIn googleSignIn = GoogleSignIn(
            serverClientId: clientId,
          );

          // Sign out first to clear any cached credentials
          await googleSignIn.signOut();

          googleUser = await googleSignIn.signIn();
          if (googleUser != null) {
            print('✅ Google Sign-In successful with client ID: ${clientId.substring(0, 20)}...');
            workingGoogleSignIn = googleSignIn;
            break;
          }
        } catch (e) {
          print('❌ Failed with client ID ${clientId.substring(0, 20)}...: $e');
          continue;
        }
      }

      if (googleUser == null) {
        print('❌ No Google user found after trying all client IDs');
        Get.snackbar(
          'Error',
          'Google Sign-in was cancelled or failed',
          snackPosition: SnackPosition.TOP,
        );
        isLoading.value = false;
        return null;
      }

      print('🔵 Getting Google authentication tokens...');
      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      print('🔵 Access Token: ${accessToken != null ? "✅ Found" : "❌ Missing"}');
      print('🔵 ID Token: ${idToken != null ? "✅ Found" : "❌ Missing"}');

      if (accessToken == null) {
        throw 'No Access Token found.';
      }
      if (idToken == null) {
        throw 'No ID Token found.';
      }

      print('🔵 Attempting Supabase authentication...');
      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (response.user != null) {
        print('✅ Supabase authentication successful!');
        Get.snackbar(
          'Success',
          'Signed in with Google successfully!',
          snackPosition: SnackPosition.TOP,
        );
      } else {
        print('❌ Supabase authentication failed - no user returned');
      }

      return response;
    } on AuthException catch (e) {
      print('❌ AuthException: ${e.message}');
      Get.snackbar(
        'Authentication Error',
        e.message,
        snackPosition: SnackPosition.TOP,
      );
      return null;
    } on PlatformException catch (e) {
      print('❌ PlatformException: Code: ${e.code}, Message: ${e.message}, Details: ${e.details}');
      String errorMessage = 'Google Sign-in failed';

      switch (e.code) {
        case 'sign_in_failed':
          errorMessage = 'Google Sign-in failed. Please try again.';
          break;
        case 'network_error':
          errorMessage = 'Network error. Please check your connection.';
          break;
        case 'sign_in_canceled':
          errorMessage = 'Google Sign-in was cancelled.';
          break;
        case 'sign_in_required':
          errorMessage = 'Please sign in to continue.';
          break;
        default:
          errorMessage = 'Google Sign-in error: ${e.message ?? e.code}';
      }

      Get.snackbar(
        'Error',
        errorMessage,
        snackPosition: SnackPosition.TOP,
      );
      return null;
    } catch (e) {
      print('❌ Unexpected error: $e');
      Get.snackbar(
        'Error',
        'Google Sign-in failed: $e',
        snackPosition: SnackPosition.TOP,
      );
      return null;
    } finally {
      isLoading.value = false;
      print('🔵 Google Sign-In process completed');
    }
  }

  Future<AuthResponse?> signInWithApple() async {
    try {
      if (!Platform.isIOS) {
        Get.snackbar(
          'Error',
          'Apple Sign-in is only available on iOS devices',
          snackPosition: SnackPosition.TOP,
        );
        return null;
      }

      isLoading.value = true;

      final rawNonce = _generateNonce();
      final nonce = sha256.convert(utf8.encode(rawNonce)).toString();

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      final idToken = credential.identityToken;
      if (idToken == null) {
        throw 'No ID Token received from Apple';
      }

      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
        nonce: rawNonce,
      );

      if (response.user != null) {
        Get.snackbar(
          'Success',
          'Signed in with Apple successfully!',
          snackPosition: SnackPosition.TOP,
        );
      }

      return response;
    } on AuthException catch (e) {
      Get.snackbar(
        'Error',
        e.message,
        snackPosition: SnackPosition.TOP,
      );
      return null;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Apple Sign-in failed: $e',
        snackPosition: SnackPosition.TOP,
      );
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  String _generateNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  Future<void> signOut() async {
    try {
      isLoading.value = true;
      await _supabase.auth.signOut();
      Get.snackbar(
        'Success',
        'Signed out successfully!',
        snackPosition: SnackPosition.TOP,
      );
    } on AuthException catch (e) {
      Get.snackbar(
        'Error',
        e.message,
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteAccount() async {
    try {
      isLoading.value = true;
      final userId = currentUser.value?.id;
      if (userId == null) {
        throw 'No user is currently signed in.';
      }
      await _supabase.from('users').delete().eq('id', userId);
      Get.snackbar(
        'Success',
        'Account deleted successfully!',
        snackPosition: SnackPosition.TOP,
      );
      await signOut();
    } catch (e) {
      Get.snackbar(
        'Error',
        'An unexpected error occurred while deleting the account.',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // OTP-based password reset (send OTP to email)
  Future<bool> sendPasswordResetOTP({required String email}) async {
    try {
      isLoading.value = true;

      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: null, // No redirect needed for OTP
      );

      Get.snackbar(
        'Success',
        'Password reset OTP sent! Please check your inbox.',
        snackPosition: SnackPosition.TOP,
      );
      return true;
    } on AuthException catch (e) {
      Get.snackbar(
        'Error',
        e.message,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    } catch (e) {
      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        snackPosition: SnackPosition.TOP,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Verify OTP for password reset
  Future<bool> verifyPasswordResetOTP({
    required String email,
    required String otp,
  }) async {
    try {
      isLoading.value = true;

      final response = await _supabase.auth.verifyOTP(
        email: email,
        token: otp,
        type: OtpType.recovery,
      );

      if (response.user != null) {
        Get.snackbar(
          'Success',
          'OTP verified! You can now reset your password.',
          snackPosition: SnackPosition.TOP,
        );
        return true;
      }
      return false;
    } on AuthException catch (e) {
      Get.snackbar(
        'Error',
        e.message,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Invalid OTP or an error occurred',
        snackPosition: SnackPosition.TOP,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Verify OTP for signup email confirmation
  Future<bool> verifySignupOTP({
    required String email,
    required String otp,
  }) async {
    try {
      isLoading.value = true;

      final response = await _supabase.auth.verifyOTP(
        email: email,
        token: otp,
        type: OtpType.signup,
      );

      if (response.user != null) {
        Get.snackbar(
          'Success',
          'Email verified successfully! You can now sign in.',
          snackPosition: SnackPosition.TOP,
        );
        return true;
      }
      return false;
    } on AuthException catch (e) {
      Get.snackbar(
        'Error',
        e.message,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Invalid OTP or an error occurred',
        snackPosition: SnackPosition.TOP,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Verify OTP for email update
  Future<bool> verifyEmailUpdateOTP({
    required String email,
    required String otp,
  }) async {
    try {
      isLoading.value = true;

      final response = await _supabase.auth.verifyOTP(
        email: email,
        token: otp,
        type: OtpType.emailChange,
      );

      if (response.user != null) {
        // Update the current user reference
        currentUser.value = response.user;
        currentUser.refresh();

        Get.snackbar(
          'Success',
          'Email updated successfully!',
          snackPosition: SnackPosition.TOP,
        );
        return true;
      }
      return false;
    } on AuthException catch (e) {
      Get.snackbar(
        'Error',
        e.message,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Invalid OTP or an error occurred',
        snackPosition: SnackPosition.TOP,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Resend OTP for any type
  Future<bool> resendOTP({
    required String email,
    required String type, // 'signup', 'recovery', 'email_change'
  }) async {
    try {
      isLoading.value = true;

      switch (type) {
        case 'signup':
          // For signup, we need to resend the confirmation
          await _supabase.auth.resend(
            type: OtpType.signup,
            email: email,
          );
          break;
        case 'recovery':
          await sendPasswordResetOTP(email: email);
          return true; // sendPasswordResetOTP already shows success message
        case 'email_change':
          await _supabase.auth.resend(
            type: OtpType.emailChange,
            email: email,
          );
          break;
        default:
          throw Exception('Invalid OTP type');
      }

      Get.snackbar(
        'Success',
        'OTP resent successfully! Please check your inbox.',
        snackPosition: SnackPosition.TOP,
      );
      return true;
    } on AuthException catch (e) {
      Get.snackbar(
        'Error',
        e.message,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to resend OTP: $e',
        snackPosition: SnackPosition.TOP,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Legacy method - keeping for backward compatibility
  Future<void> resetPassword({required String email}) async {
    await sendPasswordResetOTP(email: email);
  }

  Future<bool> updatePassword({required String newPassword}) async {
    try {
      isLoading.value = true;

      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      Get.snackbar(
        'Success',
        'Password updated successfully!',
        snackPosition: SnackPosition.TOP,
      );
      return true;
    } on AuthException catch (e) {
      Get.snackbar(
        'Error',
        e.message,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    } catch (e) {
      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        snackPosition: SnackPosition.TOP,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateEmail({required String newEmail}) async {
    try {
      isLoading.value = true;

      await _supabase.auth.updateUser(
        UserAttributes(email: newEmail),
      );

      Get.snackbar(
        'Success',
        'Email update initiated! Check your new email for confirmation.',
        snackPosition: SnackPosition.TOP,
      );
      return true;
    } on AuthException catch (e) {
      Get.snackbar(
        'Error',
        e.message,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    } catch (e) {
      Get.snackbar(
        'Error',
        'An unexpected error occurred: $e',
        snackPosition: SnackPosition.TOP,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateProfile({
    String? fullName,
    File? profileImage,
  }) async {
    try {
      isLoading.value = true;

      final Map<String, dynamic> data = {};
      if (fullName != null) data['full_name'] = fullName;

      // Try to upload the profile image
      String? profileImageUrl;
      if (profileImage != null) {
        profileImageUrl = await _uploadProfileImage(profileImage);
        if (profileImageUrl != null) {
          data['profile_image_url'] = profileImageUrl;
        }
      }

      final response = await _supabase.auth.updateUser(
        UserAttributes(
          data: data.isNotEmpty ? data : null,
        ),
      );

      // Update the current user reference to trigger reactive updates
      if (response.user != null) {
        currentUser.value = response.user;
        currentUser.refresh();
      }

      Get.snackbar(
        'Success',
        profileImage != null && profileImageUrl != null
          ? 'Profile and image updated successfully!'
          : profileImage != null
            ? 'Profile updated! Image upload failed - check storage configuration.'
            : 'Profile updated successfully!',
        snackPosition: SnackPosition.TOP,
      );

      return profileImageUrl != null || profileImage == null;
    } on AuthException catch (e) {
      Get.snackbar(
        'Error',
        e.message,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    } catch (e) {
      Get.snackbar(
        'Error',
        'An unexpected error occurred: $e',
        snackPosition: SnackPosition.TOP,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> _uploadProfileImage(File imageFile) async {
    try {
      final userId = currentUser.value?.id;
      if (userId == null) {
        print('Upload failed: User ID is null');
        return null;
      }

      print('Starting image upload for user: $userId');
      final fileName = 'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      print('Generated filename: $fileName');

      // Try common public bucket names first
      final buckets = ['avatars', 'public', 'images', 'uploads', 'profiles'];
      String? response;
      String? usedBucket;

      for (String bucketName in buckets) {
        try {
          print('Attempting to upload to $bucketName bucket...');
          response = await _supabase.storage
              .from(bucketName)
              .upload(fileName, imageFile);
          usedBucket = bucketName;
          print('Successfully uploaded to $bucketName bucket');
          break;
        } catch (bucketError) {
          print('Failed to upload to $bucketName: $bucketError');
          continue;
        }
      }

      print('Upload response: $response');

      if (response != null && response.isNotEmpty && usedBucket != null) {
        final publicUrl = _supabase.storage.from(usedBucket).getPublicUrl(fileName);
        print('Public URL generated: $publicUrl');
        return publicUrl;
      }

      print('Upload response was empty');
      return null;
    } catch (e, stackTrace) {
      print('Exception during image upload: $e');
      print('Stack trace: $stackTrace');
      Get.snackbar(
        'Error',
        'Failed to upload profile image: $e',
        snackPosition: SnackPosition.TOP,
      );
      return null;
    }
  }

  bool get isSignedIn => currentUser.value != null;

  String? get userEmail => currentUser.value?.email;

  String? get userName => currentUser.value?.userMetadata?['full_name'];

  String? get userProfileImage => currentUser.value?.userMetadata?['profile_image_url'];
}
