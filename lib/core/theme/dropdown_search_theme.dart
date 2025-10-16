import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'app_theme.dart';

class DropdownSearchTheme {
  static InputDecoration getDropdownDecoration({
    required String hintText,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: AppTheme.neutral500,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: Container(
        margin: const EdgeInsets.only(left: 12, right: 8),
        child: Icon(prefixIcon, color: AppTheme.primary, size: 20),
      ),
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

  static DropDownDecoratorProps getDecoratorProps({
    required String hintText,
    required IconData prefixIcon,
  }) {
    return DropDownDecoratorProps(
      baseStyle: TextStyle(
        color: AppTheme.neutral800,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      decoration: getDropdownDecoration(
        hintText: hintText,
        prefixIcon: prefixIcon,
      ),
    );
  }

  static PopupProps<T> getPopupProps<T>({
    required String searchHintText,
    String? emptyText,
  }) {
    return PopupProps<T>.menu(
      showSearchBox: true,
      fit: FlexFit.loose,
      menuProps: MenuProps(
        backgroundColor: AppTheme.surface,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: AppTheme.primary.withOpacity(0.1)),
        ),
      ),
      searchFieldProps: TextFieldProps(
        decoration: getDropdownDecoration(
          hintText: searchHintText,
          prefixIcon: Icons.search,
        ),
      ),
      emptyBuilder:
          (context, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                emptyText ?? 'No items found',
                style: TextStyle(
                  color: AppTheme.neutral600,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
      loadingBuilder:
          (context, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
              ),
            ),
          ),
    );
  }
}
