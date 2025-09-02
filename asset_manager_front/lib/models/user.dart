import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class User {
  final String username;
  final String role;
  final String token;

  User({required this.username, required this.role, required this.token});

  static Future<void> saveAuthData(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
    final decodedToken = JwtDecoder.decode(token);
    final role =
        decodedToken['http://schemas.microsoft.com/ws/2008/06/identity/claims/role'] ??
        'User';
    await prefs.setString('user_role', role);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_role');
  }

  static Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('user_role');
  }
}

class UserLoginDto {
  final String username;
  final String password;

  UserLoginDto({required this.username, required this.password});

  Map<String, dynamic> toJson() {
    return {'username': username, 'password': password};
  }
}
