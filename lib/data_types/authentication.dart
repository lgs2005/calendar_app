import 'package:calendar_app/data_types/credentials.dart';
import 'package:calendar_app/data_types/result.dart';
import 'package:calendar_app/service.dart';

enum LoginResult {
  wrongPassword,
  wrongUsername,
  takenUsername,
  failed,
  ok,
}

class Authentication {
  final int userid;
  final String token;

  Authentication(this.userid, this.token);

  static Authentication? currentUser;
  static String? currentUsername;

  factory Authentication.fromMap(Map<String, dynamic> data) {
    if (
      data['userid'] is! int ||
      data['token'] is! String
    ) throw const FormatException();
    
    return Authentication(data['userid'], data['token']);
  }

  static Future<LoginResult> login(UserCredentials credentials, bool register) async {
    final result = await sendRequest(
      method: HttpMethod.get,
      path: '/login',
      body: {
        'username': credentials.name,
        'password': credentials.password,
        'register': register,
      },
      parser: (result) => Result.fromMap(result, parser: Authentication.fromMap),
    );

    if (result.ok) {
      currentUser = result.value;
      currentUsername = credentials.name;

      await credentials.save();
      return LoginResult.ok;
    } else {
      const errMap = {
        'wrong_password': LoginResult.wrongPassword,
        'wrong_username': LoginResult.wrongUsername,
        'taken_username': LoginResult.takenUsername,
      };

      return errMap[result.err] ?? LoginResult.failed;
    }
  }
}