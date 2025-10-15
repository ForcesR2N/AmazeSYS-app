import 'dart:async';
import 'package:dio/dio.dart';
import 'package:get/get.dart' as getx;
import '../storage/token_storage.dart';
import 'api_constants.dart';

class ApiInterceptor extends Interceptor {
  final Dio _dio;
  final TokenStorage _tokenStorage = TokenStorage.instance;
  
  // Track ongoing refresh to prevent multiple concurrent refresh calls
  Completer<bool>? _refreshCompleter;

  ApiInterceptor(this._dio);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Auto-attach access token to all requests except auth endpoints
    if (!_isAuthEndpoint(options.path)) {
      // Check if token needs refresh before making the request
      if (_tokenStorage.shouldRefreshToken()) {
        await _handleTokenRefresh();
      }
      
      final accessToken = await _tokenStorage.getAccessToken();
      if (accessToken != null) {
        options.headers[ApiConstants.authorizationKey] = 
            '${ApiConstants.bearerPrefix}$accessToken';
      }
    }

    handler.next(options);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Handle 401 Unauthorized - attempt token refresh
    if (err.response?.statusCode == ApiConstants.statusUnauthorized &&
        !_isAuthEndpoint(err.requestOptions.path)) {
      
      final refreshed = await _handleTokenRefresh();
      
      if (refreshed) {
        // Retry the failed request with new token
        try {
          final response = await _retryRequest(err.requestOptions);
          handler.resolve(response);
          return;
        } catch (retryError) {
          // If retry fails, proceed with original error
        }
      } else {
        // Refresh failed - logout user
        await _handleLogout();
      }
    }

    handler.next(err);
  }

  // Handle token refresh with concurrency protection
  Future<bool> _handleTokenRefresh() async {
    // If refresh is already in progress, wait for it
    if (_refreshCompleter != null) {
      return await _refreshCompleter!.future;
    }

    _refreshCompleter = Completer<bool>();

    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      
      if (refreshToken == null) {
        _refreshCompleter!.complete(false);
        return false;
      }

      // Call refresh endpoint with proper JSON format
      final response = await _dio.post(
        ApiConstants.authRefresh,
        data: {'refresh_token': refreshToken},
        options: Options(
          contentType: Headers.jsonContentType,
          headers: {
            ApiConstants.contentTypeKey: ApiConstants.contentTypeValue,
          },
        ),
      );

      if (response.statusCode == ApiConstants.statusOk && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final newAccessToken = data['access_token'] as String?;
        final newRefreshToken = data['refresh_token'] as String?;
        final tokenType = data['token_type'] as String?; // Should be "bearer"

        if (newAccessToken != null) {
          // Update access token with 3600 second expiration (from backend)
          await _tokenStorage.updateAccessToken(newAccessToken, expiresInSeconds: 3600);
          
          // Update refresh token if provided
          if (newRefreshToken != null) {
            await _tokenStorage.saveTokens(
              accessToken: newAccessToken,
              refreshToken: newRefreshToken,
              rememberMe: _tokenStorage.rememberMe,
              expiresInSeconds: 3600, // Backend sets 3600 seconds
            );
          }

          _refreshCompleter!.complete(true);
          return true;
        }
      }

      _refreshCompleter!.complete(false);
      return false;
    } catch (e) {
      _refreshCompleter!.complete(false);
      return false;
    } finally {
      _refreshCompleter = null;
    }
  }

  // Retry the failed request with new token
  Future<Response> _retryRequest(RequestOptions requestOptions) async {
    final accessToken = await _tokenStorage.getAccessToken();
    
    if (accessToken != null) {
      requestOptions.headers[ApiConstants.authorizationKey] = 
          '${ApiConstants.bearerPrefix}$accessToken';
    }

    return await _dio.fetch(requestOptions);
  }

  // Handle logout when refresh fails
  Future<void> _handleLogout() async {
    await _tokenStorage.clearTokens();
    
    // Navigate to login screen
    // Use GetX navigation if available
    if (getx.Get.currentRoute != '/login') {
      getx.Get.offAllNamed('/login');
    }
  }

  // Check if the endpoint is an auth endpoint
  bool _isAuthEndpoint(String path) {
    return path == ApiConstants.authLogin ||
           path == ApiConstants.authRegister ||
           path == ApiConstants.authRefresh;
  }
}