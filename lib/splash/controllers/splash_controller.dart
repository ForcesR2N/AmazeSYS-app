import 'package:get/get.dart';
import '../../auth/services/auth_service.dart';
import '../../core/storage/token_storage.dart';
import '../../routes/app_pages.dart';

class SplashController extends GetxController {
  final AuthService _authService = AuthService();
  final TokenStorage _tokenStorage = TokenStorage.instance;

  final RxBool _isAnimationComplete = false.obs;
  final RxBool _isCheckComplete = false.obs;
  final RxBool _hasNavigated = false.obs;
  final RxBool _isUserLoggedIn = false.obs;
  final RxString _statusMessage = 'Initializing...'.obs;
  final RxBool _hasError = false.obs;

  bool get isAnimationComplete => _isAnimationComplete.value;
  bool get isCheckComplete => _isCheckComplete.value;
  bool get hasNavigated => _hasNavigated.value;
  bool get isUserLoggedIn => _isUserLoggedIn.value;
  String get statusMessage => _statusMessage.value;
  bool get hasError => _hasError.value;

  static const int minSplashDuration = 2000; // 2 seconds
  static const int maxRetryAttempts = 2;

  @override
  void onInit() {
    super.onInit();
    _checkAuthenticationStatus();
  }

  Future<void> _checkAuthenticationStatus({int retryCount = 0}) async {
    try {
      final startTime = DateTime.now();
      _statusMessage.value = 'Checking authentication...';
      _hasError.value = false;

      // Step 1: Check if tokens exist in storage
      final hasTokens = await _tokenStorage.hasValidTokens();
      print('SplashController: Has valid tokens: $hasTokens');

      if (!hasTokens) {
        // No tokens found - user needs to login
        _statusMessage.value = 'Welcome!';
        _isUserLoggedIn.value = false;
        await _ensureMinimumDuration(startTime);
        _isCheckComplete.value = true;
        _checkReadyToNavigate();
        return;
      }

      // Step 2: Tokens exist, validate by fetching user info to check token validity(nuuh expired)
      _statusMessage.value = 'Verifying session...';
      final user = await _authService.getCurrentUser();

      if (user != null) {
        // User authenticated successfully
        _statusMessage.value = 'Welcome back, ${user.name ?? 'User'}!';
        _isUserLoggedIn.value = true;
        print('SplashController: User authenticated: ${user.name}');
      } else {
        // Token validation failed (getCurrentUser already handles refresh & cleanup)
        _statusMessage.value = 'Session expired';
        _isUserLoggedIn.value = false;
        print('SplashController: Session validation failed');
      }

      await _ensureMinimumDuration(startTime);
      _isCheckComplete.value = true;
      _checkReadyToNavigate();
    } catch (e) {
      print('SplashController: Error checking authentication (attempt ${retryCount + 1}/$maxRetryAttempts): $e');

      // Retry logic for network errors
      if (retryCount < maxRetryAttempts && _isNetworkError(e)) {
        _statusMessage.value = 'Retrying connection...';
        await Future.delayed(const Duration(seconds: 1));
        return _checkAuthenticationStatus(retryCount: retryCount + 1);
      }

      // Max retries reached or non-network error
      _statusMessage.value = 'Connection failed';
      _hasError.value = true;
      _isUserLoggedIn.value = false;

      // Still complete the check to allow navigation to login
      await Future.delayed(const Duration(milliseconds: 500));
      _isCheckComplete.value = true;
      _checkReadyToNavigate();
    }
  }

  Future<void> _ensureMinimumDuration(DateTime startTime) async {
    final elapsedMs = DateTime.now().difference(startTime).inMilliseconds;
    final remainingMs = minSplashDuration - elapsedMs;

    if (remainingMs > 0) {
      await Future.delayed(Duration(milliseconds: remainingMs));
    }
  }

  bool _isNetworkError(dynamic error) {
    final errorStr = error.toString().toLowerCase();
    return errorStr.contains('socket') ||
        errorStr.contains('network') ||
        errorStr.contains('connection') ||
        errorStr.contains('timeout');
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
