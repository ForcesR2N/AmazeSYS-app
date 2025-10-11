import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_storage/get_storage.dart';
import '../api/api_constants.dart';

class TokenStorage {
  static TokenStorage? _instance;
  static TokenStorage get instance => _instance ??= TokenStorage._();
  TokenStorage._();

  // Secure storage for sensitive data (refresh token)
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Regular storage for less sensitive data (access token when remember me is enabled)
  final GetStorage _localStorage = GetStorage();

  // In-memory storage for quick access
  String? _accessToken;
  String? _refreshToken;
  bool _rememberMe = false;

  // Initialize storage
  Future<void> initialize() async {
    await GetStorage.init();
    await _loadTokensFromStorage();
  }

  // Save tokens after successful login
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    bool rememberMe = false,
  }) async {
    try {
      // Validate tokens before saving
      if (accessToken.isEmpty || refreshToken.isEmpty) {
        throw Exception('Invalid tokens provided');
      }

      // Save to memory for quick access
      _accessToken = accessToken;
      _refreshToken = refreshToken;
      _rememberMe = rememberMe;

      // Always save refresh token securely
      await _secureStorage.write(
        key: ApiConstants.refreshTokenKey,
        value: refreshToken,
      );

      // Save access token based on remember me preference
      if (rememberMe) {
        await _localStorage.write(ApiConstants.accessTokenKey, accessToken);
        await _localStorage.write(ApiConstants.rememberMeKey, true);
      } else {
        // Clear from persistent storage if not remembering
        await _localStorage.remove(ApiConstants.accessTokenKey);
        await _localStorage.write(ApiConstants.rememberMeKey, false);
      }
    } catch (e) {
      throw Exception('Failed to save tokens: $e');
    }
  }

  // Get access token (memory first, then storage if remember me)
  Future<String?> getAccessToken() async {
    if (_accessToken != null) {
      return _accessToken;
    }

    // Check if remember me was enabled
    final rememberMe = _localStorage.read(ApiConstants.rememberMeKey) ?? false;
    if (rememberMe) {
      _accessToken = _localStorage.read(ApiConstants.accessTokenKey);
      return _accessToken;
    }

    return null;
  }

  // Get refresh token (always from secure storage)
  Future<String?> getRefreshToken() async {
    if (_refreshToken != null) {
      return _refreshToken;
    }

    _refreshToken = await _secureStorage.read(key: ApiConstants.refreshTokenKey);
    return _refreshToken;
  }

  // Update access token after refresh
  Future<void> updateAccessToken(String newAccessToken) async {
    if (newAccessToken.isEmpty) {
      throw Exception('Invalid access token provided');
    }

    _accessToken = newAccessToken;

    // Update in persistent storage if remember me is enabled
    if (_rememberMe) {
      await _localStorage.write(ApiConstants.accessTokenKey, newAccessToken);
    }
  }

  // Clear all tokens (logout)
  Future<void> clearTokens() async {
    try {
      // Clear from memory
      _accessToken = null;
      _refreshToken = null;
      _rememberMe = false;

      // Clear from all storage
      await _secureStorage.delete(key: ApiConstants.refreshTokenKey);
      await _localStorage.remove(ApiConstants.accessTokenKey);
      await _localStorage.remove(ApiConstants.rememberMeKey);
    } catch (e) {
      // Log error but don't throw - logout should always succeed
      print('Warning: Error clearing tokens: $e');
    }
  }

  // Check if user has valid tokens
  Future<bool> hasValidTokens() async {
    final accessToken = await getAccessToken();
    final refreshToken = await getRefreshToken();
    return accessToken != null && refreshToken != null;
  }

  // Load tokens from storage on app start
  Future<void> _loadTokensFromStorage() async {
    try {
      _refreshToken = await _secureStorage.read(key: ApiConstants.refreshTokenKey);
      _rememberMe = _localStorage.read(ApiConstants.rememberMeKey) ?? false;

      if (_rememberMe) {
        _accessToken = _localStorage.read(ApiConstants.accessTokenKey);
      }
    } catch (e) {
      // If loading fails, clear everything to ensure clean state
      await clearTokens();
    }
  }

  // Get remember me preference
  bool get rememberMe => _rememberMe;
}