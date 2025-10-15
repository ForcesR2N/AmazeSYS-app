import 'package:get/get.dart';
import '../../profile/models/user_model.dart';
import '../services/auth_service.dart';
import '../../routes/app_pages.dart';
import '../../core/api/api_client.dart';
import '../../core/storage/token_storage.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  final TokenStorage _tokenStorage = TokenStorage.instance;
  
  final Rx<User?> _currentUser = Rx<User?>(null);
  final RxBool _isLoading = false.obs;
  final RxBool _isInitializing = true.obs;
  
  User? get currentUser => _currentUser.value;
  bool get isLoading => _isLoading.value;
  bool get isLoggedIn => _currentUser.value != null;
  bool get isInitializing => _isInitializing.value;

  @override
  void onInit() {
    super.onInit();
    _initializeApp();
  }

  // Initialize app - check for existing tokens and auto-login
  Future<void> _initializeApp() async {
    try {
      _isInitializing.value = true;

      // Initialize API client and token storage
      ApiClient.instance.initialize();
      await _tokenStorage.initialize();

      // Try to get current user if tokens exist
      final user = await _authService.getCurrentUser();
      if (user != null) {
        _currentUser.value = user;
      }
      // Note: Navigation is now handled by SplashController
      // AuthController only manages authentication state
    } catch (e) {
      print('AuthController: Initialization error: $e');
      // Don't navigate on error, let SplashController handle it
    } finally {
      _isInitializing.value = false;
    }
  }

  Future<bool> login(String username, String password, {bool rememberMe = false}) async {
    try {
      _isLoading.value = true;
      
      if (username.isEmpty || password.isEmpty) {
        _showError('Username and password cannot be empty');
        return false;
      }

      // Validate username
      if (username.length < 3) {
        _showError('Username must be at least 3 characters');
        return false;
      }
      
      User? user;
      if (rememberMe) {
        user = await _authService.loginWithRememberMe(username, password, rememberMe);
      } else {
        user = await _authService.login(username, password);
      }
      
      if (user != null) {
        _currentUser.value = user;
        _showSuccess('Login successful!');
        Get.offAllNamed(Routes.HOME);
        return true;
      } else {
        _showError('Invalid username or password');
        return false;
      }
    } catch (e) {
      _showError(_parseErrorMessage(e.toString()));
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Backward compatibility - maintain original method signature
  Future<bool> loginWithCredentials(String username, String password) async {
    return login(username, password, rememberMe: false);
  }

  Future<bool> register(String username, String password, String name) async {
    try {
      _isLoading.value = true;
      
      if (username.isEmpty || password.isEmpty || name.isEmpty) {
        _showError('All fields are required');
        return false;
      }
      
      if (username.length < 3) {
        _showError('Username must be at least 3 characters');
        return false;
      }
      
      if (password.length < 6) {
        _showError('Password must be at least 6 characters');
        return false;
      }
      
      bool success = await _authService.register(username, password, name);
      
      if (success) {
        _showSuccess('Registration successful! Please login');
        Get.offNamed(Routes.LOGIN);
        return true;
      } else {
        _showError('Username already exists');
        return false;
      }
    } catch (e) {
      _showError(_parseErrorMessage(e.toString()));
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      _isLoading.value = true;
      
      // Clear tokens and user data
      await _authService.logout();
      _currentUser.value = null;
      
      // Navigate to login
      Get.offAllNamed(Routes.LOGIN);
      _showSuccess('Logout successful');
    } catch (e) {
      // Even if logout fails, clear local state and navigate
      _currentUser.value = null;
      Get.offAllNamed(Routes.LOGIN);
      _showError('Logout completed with warnings');
    } finally {
      _isLoading.value = false;
    }
  }

  // Handle token refresh failures (called by interceptor)
  void handleTokenRefreshFailure() {
    _currentUser.value = null;
    Get.offAllNamed(Routes.LOGIN);
    _showError('Session expired. Please login again.');
  }

  // Helper method to show error messages
  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.errorContainer,
      colorText: Get.theme.colorScheme.onErrorContainer,
      duration: const Duration(seconds: 3),
    );
  }

  // Helper method to show success messages
  void _showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.primaryContainer,
      colorText: Get.theme.colorScheme.onPrimaryContainer,
      duration: const Duration(seconds: 2),
    );
  }

  // Parse error messages to be user-friendly
  String _parseErrorMessage(String error) {
    // Extract meaningful error messages
    if (error.contains('Exception:')) {
      return error.split('Exception:').last.trim();
    }
    if (error.contains('Network timeout')) {
      return 'Network timeout. Please check your connection.';
    }
    if (error.contains('Network error')) {
      return 'Network error. Please check your connection.';
    }
    if (error.contains('Session expired')) {
      return 'Session expired. Please login again.';
    }
    
    // Default generic message
    return 'Something went wrong. Please try again.';
  }
}