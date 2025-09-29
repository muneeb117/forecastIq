import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../core/constants/colors.dart';
import '../core/constants/fonts.dart';

class OTPBox extends StatefulWidget {
  final int index;
  final List<TextEditingController> otpControllers;
  final List<FocusNode> focusNodes;

  const OTPBox({
    super.key,
    required this.index,
    required this.otpControllers,
    required this.focusNodes,
  });


  @override
  State<OTPBox> createState() => _OTPBoxState();
}

class _OTPBoxState extends State<OTPBox> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50.w,
      height: 50.h,
      decoration: BoxDecoration(
        color: AppColors.ksecondary,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: widget.otpControllers[widget.index].text.isNotEmpty
              ? AppColors.kprimary
              : AppColors.kwhite.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Center(
        child: TextFormField(
          controller: widget.otpControllers[widget.index],
          focusNode: widget.focusNodes[widget.index],
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          style: AppTextStyles.kwhite24500.copyWith(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            counterText: '',
          ),
          onChanged: (value) {
            setState(() {}); // Rebuild to update border color
            
            if (value.isNotEmpty && widget.index < widget.otpControllers.length - 1) {
              widget.focusNodes[widget.index + 1].requestFocus();
            } else if (value.isEmpty && widget.index > 0) {
              widget.focusNodes[widget.index - 1].requestFocus();
            }
          },
        ),
      ),
    );
  }
}

// Keep the old function for backward compatibility
Widget buildOTPBox({
  required BuildContext context,
  required int index,
  required List<TextEditingController> otpControllers,
  required List<FocusNode> focusNodes,
}) {
  return OTPBox(
    index: index,
    otpControllers: otpControllers,
    focusNodes: focusNodes,
  );
}
