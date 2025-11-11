import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/constants/hive_constants.dart';

abstract class AuthLocalDataSource {
  Future<String?> getStoredToken();
  Future<void> saveToken(String token);
  Future<void> deleteToken();
  Future<bool> isLoggedIn();
}

@LazySingleton(as: AuthLocalDataSource)
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences _sharedPreferences;

  AuthLocalDataSourceImpl(this._sharedPreferences);

  @override
  Future<String?> getStoredToken() async {
    return _sharedPreferences.getString(HiveConst.authTokenKey);
  }

  @override
  Future<void> saveToken(String token) async {
    await _sharedPreferences.setString(HiveConst.authTokenKey, token);
  }

  @override
  Future<void> deleteToken() async {
    await _sharedPreferences.remove(HiveConst.authTokenKey);
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = _sharedPreferences.getString(HiveConst.authTokenKey);
    return token != null && token.isNotEmpty;
  }
}
