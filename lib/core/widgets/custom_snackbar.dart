import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum SnackbarType { success, error, warning, info, loading }

class CustomSnackbar {
  // Static debounce timers for different message types
  static final Map<String, Timer> _debounceTimers = {};
  static final Map<String, String> _lastMessages = {};

  static void show({
    required String message,
    required SnackbarType type,
    Duration? duration,
    bool autoClear = true,
    bool enableDebounce = true,
    Duration debounceDuration = const Duration(milliseconds: 300),
  }) {
    // Auto-clear existing snackbars if enabled
    if (autoClear) {
      Get.closeAllSnackbars();
    }

    // Handle debouncing if enabled
    if (enableDebounce) {
      final debounceKey = '${type.toString()}_$message';

      // Cancel previous timer for this message type
      _debounceTimers[debounceKey]?.cancel();

      // Check if same message was recently shown
      if (_lastMessages[debounceKey] == message) {
        return; // Skip duplicate messages
      }

      // Set up new debounce timer
      _debounceTimers[debounceKey] = Timer(debounceDuration, () {
        _lastMessages[debounceKey] = message;
        _showSnackBar(message, type, duration);

        // Clear the message after some time to allow future duplicates
        Timer(const Duration(seconds: 2), () {
          _lastMessages.remove(debounceKey);
        });
      });

      return;
    }

    // Show immediately if no debouncing
    _showSnackBar(message, type, duration);
  }

  static void _showSnackBar(
    String message,
    SnackbarType type,
    Duration? duration,
  ) {
    final color = _getColor(type);
    final icon = _getIcon(type);
    final effectiveDuration = duration ?? _getDuration(type);

    Get.rawSnackbar(
      messageText: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: color,
      duration: effectiveDuration,
      snackPosition: SnackPosition.TOP,
      borderRadius: 0,
      margin: const EdgeInsets.all(0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      animationDuration: const Duration(milliseconds: 250),
      forwardAnimationCurve: Curves.easeOut,
      reverseAnimationCurve: Curves.easeIn,
    );
  }

  // Clear all debounce timers (useful for cleanup)
  static void clearDebounceTimers() {
    for (final timer in _debounceTimers.values) {
      timer.cancel();
    }
    _debounceTimers.clear();
    _lastMessages.clear();
  }

  static IconData _getIcon(SnackbarType type) {
    switch (type) {
      case SnackbarType.success:
        return Icons.check_circle;
      case SnackbarType.error:
        return Icons.error;
      case SnackbarType.warning:
        return Icons.warning;
      case SnackbarType.info:
        return Icons.info;
      case SnackbarType.loading:
        return Icons.hourglass_top;
    }
  }

  static Color _getColor(SnackbarType type) {
    switch (type) {
      case SnackbarType.success:
        return Colors.green;
      case SnackbarType.error:
        return Colors.red;
      case SnackbarType.warning:
        return Colors.amber;
      case SnackbarType.info:
        return Colors.blue;
      case SnackbarType.loading:
        return Colors.grey;
    }
  }

  static Duration _getDuration(SnackbarType type) {
    switch (type) {
      case SnackbarType.error:
        return const Duration(seconds: 4);
      case SnackbarType.warning:
        return const Duration(seconds: 3);
      case SnackbarType.success:
        return const Duration(seconds: 3);
      case SnackbarType.info:
        return const Duration(seconds: 3);
      case SnackbarType.loading:
        return const Duration(seconds: 2);
    }
  }

  // Convenience methods for specific types
  static void success({
    required String message,
    Duration? duration,
    bool autoClear = true,
    bool enableDebounce = true,
  }) {
    show(
      message: message,
      type: SnackbarType.success,
      duration: duration,
      autoClear: autoClear,
      enableDebounce: enableDebounce,
    );
  }

  static void error({
    required String message,
    Duration? duration,
    bool autoClear = true,
    bool enableDebounce = true,
  }) {
    show(
      message: message,
      type: SnackbarType.error,
      duration: duration,
      autoClear: autoClear,
      enableDebounce: enableDebounce,
    );
  }

  static void warning({
    required String message,
    Duration? duration,
    bool autoClear = true,
    bool enableDebounce = true,
  }) {
    show(
      message: message,
      type: SnackbarType.warning,
      duration: duration,
      autoClear: autoClear,
      enableDebounce: enableDebounce,
    );
  }

  static void info({
    required String message,
    Duration? duration,
    bool autoClear = true,
    bool enableDebounce = true,
  }) {
    show(
      message: message,
      type: SnackbarType.info,
      duration: duration,
      autoClear: autoClear,
      enableDebounce: enableDebounce,
    );
  }

  static void loading({
    required String message,
    Duration? duration,
    bool autoClear = true,
    bool enableDebounce = true,
  }) {
    show(
      message: message,
      type: SnackbarType.loading,
      duration: duration,
      autoClear: autoClear,
      enableDebounce: enableDebounce,
    );
  }
}
