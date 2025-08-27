import 'package:flutter/material.dart';

class DismissKeyboardOnTap extends StatelessWidget {
  final Widget child;

  const DismissKeyboardOnTap({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // Dismiss the keyboard
      },
      child: Container(
        color: Colors.transparent, // Ensures taps are captured
        child: child,
      ),
    );
  }
}
