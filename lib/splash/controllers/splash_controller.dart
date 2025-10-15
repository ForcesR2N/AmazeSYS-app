import 'package:get/get.dart';
import '../../auth/services/auth_service.dart';
import '../../routes/app_pages.dart';

class SplashController extends GetxController {
  final AuthService _authService = AuthService();

  final RxBool _isAnimationComplete = false.obs;
  final RxBool _isCheckComplete = false.obs;
  final RxBool _hasNavigated = false.obs;
  final RxBool _isUserLoggedIn = false.obs;

  bool get isAnimationComplete => _isAnimationComplete.value;
  bool get isCheckComplete => _isCheckComplete.value;
  bool get hasNavigated => _hasNavigated.value;
  bool get isUserLoggedIn => _isUserLoggedIn.value;

  static const int minSplashDuration = 2000; // Minimum 2 seconds

  @override
  void onInit() {
    super.onInit();
    _checkAuthenticationStatus();
  }

  Future<void> _checkAuthenticationStatus() async {
    try {
      final startTime = DateTime.now();

      // Check if user has valid tokens
      final user = await _authService.getCurrentUser();
      _isUserLoggedIn.value = (user != null);

      // Ensure minimum splash duration
      final elapsedMs = DateTime.now().difference(startTime).inMilliseconds;
      final remainingMs = minSplashDuration - elapsedMs;

      if (remainingMs > 0) {
        await Future.delayed(Duration(milliseconds: remainingMs));
      }

      _isCheckComplete.value = true;
      _checkReadyToNavigate();
    } catch (e) {
      print('SplashController: Error checking authentication: $e');
      _isUserLoggedIn.value = false;
      _isCheckComplete.value = true;
      _checkReadyToNavigate();
    }
  }

  void onAnimationComplete() {
    print('SplashController: Animation completed');
    _isAnimationComplete.value = true;
    _checkReadyToNavigate();
  }

  void _checkReadyToNavigate() {
    if (_isAnimationComplete.value && _isCheckComplete.value && !_hasNavigated.value) {
      _navigateToNextScreen();
    } else {
      print('SplashController: Waiting... Animation: $_isAnimationComplete, Check: $_isCheckComplete');
    }
  }

  void _navigateToNextScreen() {
    if (_hasNavigated.value) return;

    _hasNavigated.value = true;

    Future.microtask(() {
      final nextRoute = _isUserLoggedIn.value ? Routes.HOME : Routes.LOGIN;
      print('SplashController: Navigating to $nextRoute');
      Get.offAllNamed(nextRoute);
    });
  }

  @override
  void onClose() {
    print('SplashController: Disposing');
    super.onClose();
  }
}
