import '../models/user_model.dart';
import '../core/api/api_client.dart';
import '../core/api/api_constants.dart';
import '../core/storage/token_storage.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient.instance;
  final TokenStorage _tokenStorage = TokenStorage.instance;

  // Login with real API call
  Future<User?> login(String username, String password) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.authLogin,
        data: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == ApiConstants.statusOk && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        
        // Extract tokens
        final accessToken = data['access_token'] as String?;
        final refreshToken = data['refresh_token'] as String?;
        
        if (accessToken != null && refreshToken != null) {
          // Save tokens (assuming remember me is false by default)
          await _tokenStorage.saveTokens(
            accessToken: accessToken,
            refreshToken: refreshToken,
            rememberMe: false,
          );

          // Fetch user info
          final user = await _fetchUserInfo();
          return user;
        } else {
          throw Exception('Invalid response: missing tokens');
        }
      } else {
        return null; // Invalid credentials
      }
    } catch (e) {
      // Re-throw the exception to be handled by the controller
      rethrow;
    }
  }

  // Login with remember me option
  Future<User?> loginWithRememberMe(String username, String password, bool rememberMe) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.authLogin,
        data: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == ApiConstants.statusOk && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        
        // Extract tokens
        final accessToken = data['access_token'] as String?;
        final refreshToken = data['refresh_token'] as String?;
        
        if (accessToken != null && refreshToken != null) {
          // Save tokens with remember me preference
          await _tokenStorage.saveTokens(
            accessToken: accessToken,
            refreshToken: refreshToken,
            rememberMe: rememberMe,
          );

          // Fetch user info
          final user = await _fetchUserInfo();
          return user;
        } else {
          throw Exception('Invalid response: missing tokens');
        }
      } else {
        return null; // Invalid credentials
      }
    } catch (e) {
      // Re-throw the exception to be handled by the controller
      rethrow;
    }
  }

  // Register with real API call
  Future<bool> register(String username, String password, String name) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.authRegister,
        data: {
          'username': username,
          'password': password,
          'name': name,
        },
      );

      if (response.statusCode == ApiConstants.statusOk) {
        return true; // Registration successful
      } else {
        return false; // Registration failed (likely username already exists)
      }
    } catch (e) {
      // Re-throw the exception to be handled by the controller
      rethrow;
    }
  }

  // Logout - clear tokens
  Future<void> logout() async {
    await _tokenStorage.clearTokens();
  }

  // Fetch current user info
  Future<User?> _fetchUserInfo() async {
    try {
      final response = await _apiClient.get(ApiConstants.authMe);
      
      if (response.statusCode == ApiConstants.statusOk && response.data != null) {
        // Assuming the API returns user data directly
        // Adjust this based on actual API response structure
        return User.fromJson(response.data as Map<String, dynamic>);
      } else {
        return null;
      }
    } catch (e) {
      // If fetching user info fails, still consider login successful
      // Return a minimal user object if possible
      return null;
    }
  }

  // Check if user is already logged in (has valid tokens)
  Future<User?> getCurrentUser() async {
    try {
      final hasTokens = await _tokenStorage.hasValidTokens();
      if (!hasTokens) {
        return null;
      }

      // Try to fetch current user info
      return await _fetchUserInfo();
    } catch (e) {
      // If fetching fails, clear tokens and return null
      await _tokenStorage.clearTokens();
      return null;
    }
  }

  // Refresh tokens manually (handled automatically by interceptor)
  Future<bool> refreshTokens() async {
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      
      if (refreshToken == null) {
        return false;
      }

      final response = await _apiClient.post(
        ApiConstants.authRefresh,
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == ApiConstants.statusOk && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final newAccessToken = data['access_token'] as String?;
        final newRefreshToken = data['refresh_token'] as String?;

        if (newAccessToken != null) {
          await _tokenStorage.updateAccessToken(newAccessToken);
          
          // Update refresh token if provided
          if (newRefreshToken != null) {
            await _tokenStorage.saveTokens(
              accessToken: newAccessToken,
              refreshToken: newRefreshToken,
              rememberMe: _tokenStorage.rememberMe,
            );
          }

          return true;
        }
      }

      return false;
    } catch (e) {
      return false;
    }
  }
}