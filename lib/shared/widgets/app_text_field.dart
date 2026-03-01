// ── app_text_field.dart  –  Reusable styled text field ──────────

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dream_ludo/core/theme/app_theme.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final int? maxLength;
  final int maxLines;
  final bool enabled;
  final List<TextInputFormatter>? inputFormatters;
  final void Function(String)? onChanged;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final void Function()? onEditingComplete;

  const AppTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.maxLength,
    this.maxLines = 1,
    this.enabled = true,
    this.inputFormatters,
    this.onChanged,
    this.textInputAction,
    this.focusNode,
    this.onEditingComplete,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLength: maxLength,
      maxLines: maxLines,
      enabled: enabled,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      textInputAction: textInputAction,
      focusNode: focusNode,
      onEditingComplete: onEditingComplete,
      style: AppTextStyles.bodyMedium,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        counterText: '',
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: AppColors.textHint, size: 22)
            : null,
        suffixIcon: suffixIcon,
      ),
    );
  }
}
