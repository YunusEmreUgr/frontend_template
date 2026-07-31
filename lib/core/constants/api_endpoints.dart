abstract class ApiEndpoints {
  // Base URL (Development / Production)
  static const String baseUrl = 'http://localhost:5000/api';

  // Auth Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh';
  static const String getUserClaims = '/auth/claims';

  // User Endpoints
  static const String userProfile = '/users/profile';
  static const String updateProfile = '/users/update';
}
