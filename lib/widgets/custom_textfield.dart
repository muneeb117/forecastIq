import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../core/constants/colors.dart';
import '../core/constants/fonts.dart';

class CustomTextFormField extends StatefulWidget {
  final String hintName;
  final String titleofTestFormField;
  final String? Function(String?)? validator;
  final bool isPassword;
  final bool isPhoneNumber;
  final bool isEditable;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final FontWeight? fontWeight;
  final int? maxLines;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  const CustomTextFormField({
    super.key,
    required this.hintName,
    required this.titleofTestFormField,
    required this.controller,
    this.validator,
    this.isPassword = false,
    this.isPhoneNumber = false,
    this.isEditable = true,
    this.fontWeight,
    this.onChanged,
    this.focusNode,
    this.onFieldSubmitted,
    this.maxLines,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  bool _obscureText = true;
  bool _isFocused = false;
  String? _errorText;

  @override
  Widget build(BuildContext context) {
    bool phoneNumberEnabled = widget.isPhoneNumber;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.titleofTestFormField,
          style: AppTextStyles.kblack14500.copyWith(color: AppColors.kwhite),
        ),
        8.verticalSpace,
        Stack(
          alignment: Alignment.centerRight,
          children: [
            Container(
              height: 50.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                color: AppColors.ksecondary,
                border: Border.all(
                  color: _isFocused
                      ? AppColors.kprimary
                      : AppColors.kwhite.withValues(alpha: 0.2),
                  width: 1.w,
                ),
              ),
              child: Focus(
                onFocusChange: (hasFocus) {
                  setState(() {
                    _isFocused = hasFocus;
                  });
                },
                child: TextFormField(
                  maxLines: widget.maxLines,
                  controller: widget.controller,
                  focusNode: widget.focusNode, // Pass the focusNode
                  obscureText: _obscureText && widget.isPassword,
                  validator: (value) {
                    final error = widget.validator?.call(value);
                    setState(() {
                      _errorText = error;
                    });
                    return null; // Always return null to prevent built-in error display
                  },
                  style: AppTextStyles.kblack14500.copyWith(
                    color: AppColors.kwhite,
                  ),
                  keyboardType: phoneNumberEnabled
                      ? TextInputType.phone
                      : TextInputType.emailAddress,
                  onFieldSubmitted:
                      widget.onFieldSubmitted, // Pass onFieldSubmitted
                  onChanged: (value) {
                    widget.onChanged?.call(value);
                    // Trigger validation on text change
                    if (widget.validator != null) {
                      final error = widget.validator!(value);
                      setState(() {
                        _errorText = error;
                      });
                    }
                  },
                  enabled: widget.isEditable, // Control editability
                  decoration: InputDecoration(
                    hintText: widget.hintName,
                    hintStyle: AppTextStyles.kblack14500.copyWith(
                      color: AppColors.kwhite,
                    ),

                    prefixIcon: widget.prefixIcon,
                    suffixIcon: widget.isPassword ? null : widget.suffixIcon,
                    filled: true,
                    fillColor: Colors.transparent,
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide.none,
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide.none,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide.none,
                    ),
                    errorStyle: TextStyle(height: 0, color: Colors.transparent),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 0.h,
                    ),
                  ),
                ),
              ),
            ),
            if (widget.isPassword)
              Positioned(
                right: 12.w,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                  child: Icon(
                    _obscureText
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.kwhite,
                    size: 16.r,
                  ),
                ),
              ),
          ],
        ),
        if (_errorText != null && _errorText!.isNotEmpty) ...[
          SizedBox(height: 4.h),
          Text(
            _errorText!,
            style: AppTextStyles.kblack12400.copyWith(
              color: AppColors.kredred,
              fontSize: 12.sp,
            ),
          ),
        ],
      ],
    );
  }
}
