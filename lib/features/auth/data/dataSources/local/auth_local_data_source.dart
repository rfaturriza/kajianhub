import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthLocalDataSource {
  Future<String?> getStoredToken();
  Future<void> saveToken(String token);
  Future<void> deleteToken();
  Future<bool> isLoggedIn();
}

@LazySingleton(as: AuthLocalDataSource)
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences _sharedPreferences;

  static const String _tokenKey = 'auth_token';

  AuthLocalDataSourceImpl(this._sharedPreferences);

  @override
  Future<String?> getStoredToken() async {
    return _sharedPreferences.getString(_tokenKey);
  }

  @override
  Future<void> saveToken(String token) async {
    await _sharedPreferences.setString(_tokenKey, token);
  }

  @override
  Future<void> deleteToken() async {
    await _sharedPreferences.remove(_tokenKey);
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = _sharedPreferences.getString(_tokenKey);
    return token != null && token.isNotEmpty;
  }
}
