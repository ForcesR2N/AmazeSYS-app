class ApiConstants {
  // Base Configuration
  static const String baseUrl = 'https://intelligent-determination-production.up.railway.app';
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
  
  // Headers
  static const String contentTypeKey = 'Content-Type';
  static const String contentTypeValue = 'application/json';
  static const String authorizationKey = 'Authorization';
  static const String bearerPrefix = 'Bearer ';
  
  // Auth Endpoints
  static const String authLogin = '/api/auth/login';
  static const String authRegister = '/api/auth/register';
  static const String authRefresh = '/api/auth/refresh';
  static const String authMe = '/api/auth/me';
  
  // Status Codes
  static const int statusOk = 200;
  static const int statusUnauthorized = 401;
  static const int statusValidationError = 422;
  
  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String rememberMeKey = 'remember_me';
}