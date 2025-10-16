import 'package:flutter/material.dart';
import 'app_theme.dart';

class FormTheme {
  static InputDecoration buildDropdownDecoration({
    required String hintText,
    IconData? prefixIcon,
    String? helperText,
    String? errorText,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: AppTheme.neutral500, fontSize: 14),
      prefixIcon:
          prefixIcon != null
              ? Container(
                margin: const EdgeInsets.only(left: 12, right: 8),
                child: Icon(prefixIcon, color: AppTheme.primary, size: 20),
              )
              : null,
      helperText: helperText,
      errorText: errorText,
      filled: true,
      fillColor: AppTheme.primarySurface.withOpacity(0.04),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppTheme.primary.withOpacity(0.2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppTheme.primary.withOpacity(0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppTheme.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppTheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppTheme.error, width: 1.5),
      ),
    );
  }

  static DropdownButtonFormField<T> buildStyledDropdown<T>({
    required String hintText,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    IconData? prefixIcon,
    String? helperText,
    String? errorText,
    String? Function(T?)? validator,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      validator: validator,
      decoration: buildDropdownDecoration(
        hintText: hintText,
        prefixIcon: prefixIcon,
        helperText: helperText,
        errorText: errorText,
      ),
      icon: Container(
        margin: const EdgeInsets.only(right: 12),
        child: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: AppTheme.primary,
          size: 24,
        ),
      ),
      iconSize: 24,
      dropdownColor: AppTheme.surface,
      style: TextStyle(
        color: AppTheme.neutral800,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        fontFamily: AppTypography.fontFamily,
      ),
      menuMaxHeight: 300,
      isDense: true,
      isExpanded: true,
      borderRadius: BorderRadius.circular(8),
      elevation: 4,
    );
  }
}
