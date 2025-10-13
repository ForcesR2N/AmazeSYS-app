import 'dart:async';
import 'dart:math';

/// Helper class to simulate different network conditions for testing
class NetworkHelper {
  static final Random _random = Random();
  
  /// Simulate network delay
  static Future<void> simulateNetworkDelay({
    int minMs = 500,
    int maxMs = 2000,
  }) async {
    final delay = minMs + _random.nextInt(maxMs - minMs);
    await Future.delayed(Duration(milliseconds: delay));
  }
  
  /// Simulate network failure (returns true if should fail)
  static bool shouldSimulateFailure({double failureRate = 0.1}) {
    return _random.nextDouble() < failureRate;
  }
  
  /// Simulate slow network
  static Future<void> simulateSlowNetwork() async {
    await Future.delayed(Duration(milliseconds: 3000 + _random.nextInt(2000)));
  }
  
  /// Simulate timeout scenario
  static Future<void> simulateTimeout() async {
    await Future.delayed(const Duration(seconds: 35)); // Longer than service timeout
  }
  
  /// Get a realistic error message
  static String getRealisticErrorMessage() {
    final errors = [
      'Network connection timeout',
      'Server temporarily unavailable',
      'Unable to connect to server',
      'Connection lost',
      'Server returned an error',
      'Data format error',
      'Authentication failed',
      'Rate limit exceeded',
    ];
    
    return errors[_random.nextInt(errors.length)];
  }
  
  /// Check if error is network related
  static bool isNetworkError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('timeout') ||
           errorString.contains('connection') ||
           errorString.contains('network') ||
           errorString.contains('socket') ||
           errorString.contains('http');
  }
  
  /// Get user-friendly error message
  static String getUserFriendlyErrorMessage(dynamic error) {
    if (isNetworkError(error)) {
      return 'Please check your internet connection and try again.';
    }
    
    final errorString = error.toString();
    if (errorString.contains('HTTP 404')) {
      return 'The requested data was not found.';
    } else if (errorString.contains('HTTP 500')) {
      return 'Server error occurred. Please try again later.';
    } else if (errorString.contains('HTTP 401')) {
      return 'Authentication failed. Please log in again.';
    } else if (errorString.contains('HTTP 403')) {
      return 'Access denied. You don\'t have permission to view this data.';
    }
    
    return 'An unexpected error occurred. Please try again.';
  }
}