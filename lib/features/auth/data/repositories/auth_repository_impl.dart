import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:template/core/storages/json_list_store.dart';
import 'package:template/features/auth/domain/entities/app_user.dart';
import 'package:template/features/auth/domain/repositories/auth_repository.dart';
import 'package:uuid/uuid.dart';

/// Fake, fully local authentication used for the demo build: there is no
/// real backend, accounts are stored on-device and passwords are only
/// hashed (not a substitute for real security).
@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._store, this._prefs);

  final JsonListStore _store;
  final SharedPreferences _prefs;

  static const _usersKey = 'auth_users';
  static const _sessionKey = 'auth_current_user_id';
  static const _uuid = Uuid();

  String _hash(String value) => sha256.convert(utf8.encode(value)).toString();

  List<AppUser> _readUsers() =>
      _store.readList(_usersKey).map(AppUser.fromJson).toList();

  Future<void> _writeUsers(List<AppUser> users) =>
      _store.writeList(_usersKey, users.map((e) => e.toJson()).toList());

  @override
  Future<bool> isLoggedIn() async => _prefs.getString(_sessionKey) != null;

  @override
  Future<AppUser?> getCurrentUser() async {
    final id = _prefs.getString(_sessionKey);
    if (id == null) return null;
    final users = _readUsers();
    for (final user in users) {
      if (user.id == id) return user;
    }
    return null;
  }

  @override
  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    final users = _readUsers();
    final normalizedEmail = email.trim().toLowerCase();
    final hashed = _hash(password);
    final match = users
        .where((u) => u.email.toLowerCase() == normalizedEmail)
        .toList();

    if (match.isEmpty) {
      throw const AuthException('Aucun compte trouvé avec cet email.');
    }
    if (match.first.passwordHash != hashed) {
      throw const AuthException('Mot de passe incorrect.');
    }

    await _prefs.setString(_sessionKey, match.first.id);
    return match.first;
  }

  @override
  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final users = _readUsers();
    final normalizedEmail = email.trim().toLowerCase();

    if (users.any((u) => u.email.toLowerCase() == normalizedEmail)) {
      throw const AuthException('Un compte existe déjà avec cet email.');
    }

    final user = AppUser(
      id: _uuid.v4(),
      name: name.trim(),
      email: normalizedEmail,
      passwordHash: _hash(password),
    );
    users.add(user);
    await _writeUsers(users);
    await _prefs.setString(_sessionKey, user.id);
    return user;
  }

  @override
  Future<void> logout() async {
    await _prefs.remove(_sessionKey);
  }
}
