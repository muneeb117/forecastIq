import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';

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
          'Account created successfully! Please check your email for verification.',
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

  Future<void> resetPassword({required String email}) async {
    try {
      isLoading.value = true;

      await _supabase.auth.resetPasswordForEmail(email);

      Get.snackbar(
        'Success',
        'Password reset email sent! Please check your inbox.',
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

  Future<void> updatePassword({required String newPassword}) async {
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

  Future<void> updateProfile({
    String? fullName,
    String? email,
  }) async {
    try {
      isLoading.value = true;

      final Map<String, dynamic> data = {};
      if (fullName != null) data['full_name'] = fullName;

      await _supabase.auth.updateUser(
        UserAttributes(
          email: email,
          data: data.isNotEmpty ? data : null,
        ),
      );

      Get.snackbar(
        'Success',
        'Profile updated successfully!',
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

  bool get isSignedIn => currentUser.value != null;

  String? get userEmail => currentUser.value?.email;

  String? get userName => currentUser.value?.userMetadata?['full_name'];
}