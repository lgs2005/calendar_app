import 'dart:convert';
import 'dart:io';

import 'package:calendar_app/data_types/authentication.dart';
import 'package:http/http.dart' as http;

//const serviceHost = 'localhost:3000';
const serviceHost = 'sturdy-thread-web.glitch.me';
final client = http.Client();

class ServiceException implements Exception {
  String message;
  ServiceException(this.message);
  @override String toString() => 'ServiceException: $message';
}

enum HttpMethod {
  get,
  post,
  delete,
}

Future<T> sendRequest<T>({
  required HttpMethod method,
  required String path,
  Map<String, dynamic>? body,
  T Function(Map<String, dynamic>)? parser,
  T Function(List<dynamic>)? listParser,
}) async {
  try {
    late final http.Response response;
    final Map<String, String> headers = {};
    final userAuth = Authentication.currentUser;

    if (userAuth != null) {
      headers.addAll({
        'x-auth-id': userAuth.userid.toString(),
        'x-auth-token': userAuth.token,
      });
    }

    //await Future.value(null).delay(2);

    if (method == HttpMethod.get) {
      response = await client.get(
        Uri.http(serviceHost, path, body?.map((key, value) => MapEntry(key, value.toString()))),
        headers: headers,
      );
    } else {
      final uri = Uri.http(serviceHost, path);
      final payload = jsonEncode(body);
      headers['content-type'] = 'application/json';

      if (method == HttpMethod.post) {
        response = await client.post(
          uri,
          body: payload,
          headers: headers,
        );
      } else if (method == HttpMethod.delete) {
        response = await client.delete(
          uri,
          body: payload,
          headers: headers,
        );
      }
    }
    
    if (response.statusCode != 200) {
      throw ServiceException('Returned status code: ${response.statusCode}');
    }

    late final dynamic data;
    if (response.headers['content-type']?.contains('application/json') == true) {
      data = jsonDecode(response.body);
    } else {
      data = response.body;
    }

    if (data is Map<String, dynamic> && parser != null) {
      return parser(data);
    } else if (data is List<dynamic> && listParser != null) {
      return listParser(data);
    } else if (data is T) {
      return data;
    } else {
      throw ServiceException('Unexpected data type: $data');
    }
  }
  on FormatException {
    throw ServiceException('Malformed response.');
  }
  on http.ClientException catch (err) {
    throw ServiceException('Request failed: $err');
  }
  on SocketException catch (err) {
    throw ServiceException('Request rejected: $err');
  }
}