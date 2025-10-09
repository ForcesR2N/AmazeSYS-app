import 'package:get/get.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../routes/app_pages.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  
  final Rx<User?> _currentUser = Rx<User?>(null);
  final RxBool _isLoading = false.obs;
  
  User? get currentUser => _currentUser.value;
  bool get isLoading => _isLoading.value;
  bool get isLoggedIn => _currentUser.value != null;

  Future<bool> login(String email, String password) async {
    try {
      _isLoading.value = true;
      
      if (email.isEmpty || password.isEmpty) {
        Get.snackbar(
          'Error',
          'Email and password cannot be empty',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
      
      User? user = await _authService.login(email, password);
      
      if (user != null) {
        _currentUser.value = user;
        Get.snackbar(
          'Success',
          'Login successful!',
          snackPosition: SnackPosition.BOTTOM,
        );
        Get.offAllNamed(Routes.HOME);
        return true;
      } else {
        Get.snackbar(
          'Error',
          'Invalid email or password',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> register(String email, String password, String name) async {
    try {
      _isLoading.value = true;
      
      if (email.isEmpty || password.isEmpty || name.isEmpty) {
        Get.snackbar(
          'Error',
          'All fields are required',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
      
      if (!GetUtils.isEmail(email)) {
        Get.snackbar(
          'Error',
          'Invalid email format',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
      
      if (password.length < 6) {
        Get.snackbar(
          'Error',
          'Password must be at least 6 characters',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
      
      bool success = await _authService.register(email, password, name);
      
      if (success) {
        Get.snackbar(
          'Success',
          'Registration successful! Please login',
          snackPosition: SnackPosition.BOTTOM,
        );
        Get.offNamed(Routes.LOGIN);
        return true;
      } else {
        Get.snackbar(
          'Error',
          'Email already exists',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      _isLoading.value = true;
      await _authService.logout();
      _currentUser.value = null;
      Get.offAllNamed(Routes.LOGIN);
      Get.snackbar(
        'Success',
        'Logout successful',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred during logout: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }
}