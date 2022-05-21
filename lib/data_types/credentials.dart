import 'package:shared_preferences/shared_preferences.dart';

class UserCredentials {
  final String name;
  final String password;

  UserCredentials(this.name, this.password);

  static Future<UserCredentials?> restore() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user.name');
    final password = prefs.getString('user.password');

    if (name != null && password != null) {
      return UserCredentials(name, password);
    }
  }

  Future<void> save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user.name', name);
      await prefs.setString('user.password', password);
    } catch (_) {
      return;
    }
  }

  static Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user.name');
      await prefs.remove('user.password');
    } catch (_) {
      return;
    }
  }
}