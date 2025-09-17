import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';
import '../view/Auth/login_screen.dart';

class AuthWrapper extends StatelessWidget {
  final Widget child;

  const AuthWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GetX<AuthService>(
      builder: (authService) {
        if (authService.isSignedIn) {
          return child;
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}