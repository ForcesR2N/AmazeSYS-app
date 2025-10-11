import 'package:dio/dio.dart';
import 'api_constants.dart';
import 'api_interceptor.dart';

class ApiClient {
  static ApiClient? _instance;
  static ApiClient get instance => _instance ??= ApiClient._();
  ApiClient._();

  late final Dio _dio;
  Dio get dio => _dio;

  // Initialize the API client
  void initialize() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      sendTimeout: ApiConstants.sendTimeout,
      headers: {
        ApiConstants.contentTypeKey: ApiConstants.contentTypeValue,
      },
      validateStatus: (status) {
        // Accept all status codes to handle them manually
        return status != null && status < 500;
      },
    ));

    // Add interceptors
    _dio.interceptors.add(ApiInterceptor(_dio));
    
    // Add logging in debug mode only
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: false, // Don't log headers to avoid exposing tokens
      responseHeader: false,
      error: true,
      logPrint: (obj) {
        // Only log in debug mode and sanitize any tokens
        if (_isDebugMode()) {
          final sanitized = _sanitizeLog(obj.toString());
          print(sanitized);
        }
      },
    ));
  }

  // GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  // POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  // PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  // DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  // Handle Dio exceptions and convert to user-friendly messages
  Exception _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Network timeout. Please check your connection.');
      
      case DioExceptionType.connectionError:
        return Exception('Network error. Please check your connection.');
      
      case DioExceptionType.badResponse:
        return _handleBadResponse(e);
      
      case DioExceptionType.cancel:
        return Exception('Request was cancelled.');
      
      default:
        return Exception('Something went wrong. Please try again.');
    }
  }

  // Handle bad response errors
  Exception _handleBadResponse(DioException e) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;

    switch (statusCode) {
      case ApiConstants.statusUnauthorized:
        return Exception('Session expired. Please login again.');
      
      case ApiConstants.statusValidationError:
        if (data is Map<String, dynamic> && data['detail'] is List) {
          final details = data['detail'] as List;
          if (details.isNotEmpty && details.first is Map) {
            final firstError = details.first as Map<String, dynamic>;
            return Exception(firstError['msg'] ?? 'Validation error');
          }
        }
        return Exception('Invalid input. Please check your data.');
      
      default:
        if (data is Map<String, dynamic> && data['detail'] is String) {
          return Exception(data['detail']);
        }
        return Exception('Server error. Please try again later.');
    }
  }

  // Check if running in debug mode
  bool _isDebugMode() {
    bool debugMode = false;
    assert(debugMode = true);
    return debugMode;
  }

  // Sanitize logs to remove sensitive information
  String _sanitizeLog(String log) {
    // Remove any potential tokens from logs
    return log
        .replaceAll(RegExp(r'Bearer [A-Za-z0-9\-_]+'), 'Bearer [REDACTED]')
        .replaceAll(RegExp(r'"access_token":\s*"[^"]*"'), '"access_token": "[REDACTED]"')
        .replaceAll(RegExp(r'"refresh_token":\s*"[^"]*"'), '"refresh_token": "[REDACTED]"')
        .replaceAll(RegExp(r'"password":\s*"[^"]*"'), '"password": "[REDACTED]"');
  }
}