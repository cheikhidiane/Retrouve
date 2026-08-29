import 'package:template/features/auth/domain/entities/app_user.dart';

abstract class AuthRepository {
  Future<AppUser?> getCurrentUser();

  Future<bool> isLoggedIn();

  /// Returns the authenticated user, or throws an [AuthException] with a
  /// human readable message when credentials are invalid.
  Future<AppUser> login({required String email, required String password});

  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
  });

  Future<void> logout();
}

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}
