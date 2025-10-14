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
  DateTime? _tokenExpiresAt;

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
    int? expiresInSeconds, // Backend provides expiration time
  }) async {
    try {
      // Validate tokens before saving
      if (accessToken.isEmpty || refreshToken.isEmpty) {
        throw Exception('Invalid tokens provided');
      }

      // Calculate expiration time - default to 3600 seconds (1 hour) if not provided
      final expirationSeconds = expiresInSeconds ?? 3600;
      _tokenExpiresAt = DateTime.now().add(Duration(seconds: expirationSeconds));

      // Save to memory for quick access
      _accessToken = accessToken;
      _refreshToken = refreshToken;
      _rememberMe = rememberMe;

      // Always save refresh token securely
      await _secureStorage.write(
        key: ApiConstants.refreshTokenKey,
        value: refreshToken,
      );

      // Save expiration time
      await _localStorage.write(
        'token_expires_at', 
        _tokenExpiresAt!.millisecondsSinceEpoch,
      );

      // Always save access token for session persistence 
      // RememberMe only affects if it survives app uninstall/data clear
      await _localStorage.write(ApiConstants.accessTokenKey, accessToken);
      await _localStorage.write(ApiConstants.rememberMeKey, rememberMe);
    } catch (e) {
      throw Exception('Failed to save tokens: $e');
    }
  }

  // Get access token (memory first, then from storage)
  Future<String?> getAccessToken() async {
    if (_accessToken != null) {
      return _accessToken;
    }

    // Load from storage (always available for session persistence)
    _accessToken = _localStorage.read(ApiConstants.accessTokenKey);
    return _accessToken;
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
  Future<void> updateAccessToken(String newAccessToken, {int? expiresInSeconds}) async {
    if (newAccessToken.isEmpty) {
      throw Exception('Invalid access token provided');
    }

    _accessToken = newAccessToken;

    // Update expiration time - default to 3600 seconds if not provided
    final expirationSeconds = expiresInSeconds ?? 3600;
    _tokenExpiresAt = DateTime.now().add(Duration(seconds: expirationSeconds));

    // Save expiration time
    await _localStorage.write(
      'token_expires_at', 
      _tokenExpiresAt!.millisecondsSinceEpoch,
    );

    // Always update in storage for session persistence
    await _localStorage.write(ApiConstants.accessTokenKey, newAccessToken);
  }

  // Clear all tokens (logout)
  Future<void> clearTokens() async {
    try {
      // Clear from memory
      _accessToken = null;
      _refreshToken = null;
      _rememberMe = false;
      _tokenExpiresAt = null;

      // Clear from all storage
      await _secureStorage.delete(key: ApiConstants.refreshTokenKey);
      await _localStorage.remove(ApiConstants.accessTokenKey);
      await _localStorage.remove(ApiConstants.rememberMeKey);
      await _localStorage.remove('token_expires_at');
    } catch (e) {
      // Log error but don't throw - logout should always succeed
      // Error clearing tokens - this is non-critical
    }
  }

  // Check if user has valid tokens
  Future<bool> hasValidTokens() async {
    final accessToken = await getAccessToken();
    final refreshToken = await getRefreshToken();
    return accessToken != null && refreshToken != null && !isTokenExpired();
  }

  // Check if access token is expired or will expire soon (within 5 minutes)
  bool isTokenExpired({int bufferMinutes = 5}) {
    if (_tokenExpiresAt == null) {
      // If no expiration data and we have tokens, try to use them
      // The API will return 401 if they're actually expired
      return false;
    }
    
    final bufferTime = DateTime.now().add(Duration(minutes: bufferMinutes));
    return _tokenExpiresAt!.isBefore(bufferTime);
  }

  // Check if token needs refresh (expires within 10 minutes)
  bool shouldRefreshToken() {
    return isTokenExpired(bufferMinutes: 10);
  }

  // Get time until token expires (in minutes)
  int? getMinutesUntilExpiration() {
    if (_tokenExpiresAt == null) return null;
    
    final now = DateTime.now();
    if (_tokenExpiresAt!.isBefore(now)) return 0;
    
    return _tokenExpiresAt!.difference(now).inMinutes;
  }

  // Load tokens from storage on app start
  Future<void> _loadTokensFromStorage() async {
    try {
      _refreshToken = await _secureStorage.read(key: ApiConstants.refreshTokenKey);
      _rememberMe = _localStorage.read(ApiConstants.rememberMeKey) ?? false;

      // Load expiration time
      final expirationMs = _localStorage.read('token_expires_at');
      if (expirationMs != null) {
        _tokenExpiresAt = DateTime.fromMillisecondsSinceEpoch(expirationMs);
      }

      // Always load access token for session persistence
      _accessToken = _localStorage.read(ApiConstants.accessTokenKey);
    } catch (e) {
      // If loading fails, clear everything to ensure clean state
      await clearTokens();
    }
  }

  // Get remember me preference
  bool get rememberMe => _rememberMe;
}