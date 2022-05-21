import 'package:calendar_app/data_types/calendar_event.dart';
import 'package:calendar_app/service.dart';

enum CalendarShareResult {
  userDoesntExist,
  calendarDoesntExist,
  unauthorized,
  alreadyShared,
  failed,
  ok,
}

extension CalendarShareResultMessage on CalendarShareResult {
  String get errorMessage {
    switch (this) {
      case CalendarShareResult.alreadyShared: return 'Este usuário já tem acesso';
      case CalendarShareResult.userDoesntExist: return 'Este usuário não existe';
      default: return 'Ocorreu um erro';
    }
  }

  static CalendarShareResult fromStringCode(String errorCode) {
    switch (errorCode) {
      case 'ok': return CalendarShareResult.ok;
      case 'user_doesnt_exist': return CalendarShareResult.userDoesntExist;
      case 'calendar_doesnt_exist': return CalendarShareResult.calendarDoesntExist;
      case 'unauthorized': return CalendarShareResult.unauthorized;
      case 'already_shared': return CalendarShareResult.alreadyShared;
      default: return CalendarShareResult.failed;
    }
  }
}

class Calendar {
  final int id;
  final String title;
  final String description;
  final int owner;

  Calendar({
    required this.id,
    required this.title,
    required this.owner,
    required this.description
  });

  factory Calendar.fromMap(Map<String, dynamic> data) {
    if (
      data['title'] is! String ||
      data['description'] is! String ||
      data['id'] is! int ||
      data['owner'] is! int
    ) throw const FormatException();

    return Calendar(
      id: data['id'],
      title: data['title'],
      owner: data['owner'],
      description: data['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'owner': owner,
      'description': description,
    };
  }

  Future<List<CalendarEvent>> downloadEvents() {
    return sendRequest(
      method: HttpMethod.get,
      path: '/search/events',
      body: {
        'calendar': id,
      },
      listParser: (list) => list.map((data) => CalendarEvent.fromMap(data)).toList(),
    );
  }

  static Future<List<Calendar>> downloadList() {
    return sendRequest(
      method: HttpMethod.get,
      path: '/search/calendars',
      body: {},
      listParser: (list) => list.map((data) => Calendar.fromMap(data)).toList(),
    );
  }

  static Future<Calendar> create(String title, String description) {
    return sendRequest(
      method: HttpMethod.post,
      path: '/publish/calendars',
      parser: Calendar.fromMap,
      body: {
        'id': 0,
        'title': title,
        'description': description,
      },
    );
  }

  Future<void> delete() {
    return sendRequest(
      method: HttpMethod.delete,
      path: '/delete/calendars',
      body: {
        'id': id,
      }
    );
  }

  static Future<Calendar?> download(int id) async {
    final result = await sendRequest(
      method: HttpMethod.get,
      path: '/search/calendars',
      body: {
        'id': id
      },
      listParser: (data) => data.map((map) => Calendar.fromMap(map)).toList(),
    );
    
    return result.isNotEmpty ? result[0] : null;
  }

  Future<Calendar> publish() {
    return sendRequest(
      method: HttpMethod.post,
      path: '/publish/calendars',
      body: toMap(),
      parser: (data) => Calendar.fromMap(data),
    );
  }

  Future<List<String>> getSharedWith() {
    return sendRequest<List<String>>(
      method: HttpMethod.get,
      path: '/share/get',
      body: {
        'calendar': id,
      },
      listParser: (list) => list.map((value) => value.toString()).toList(),
    );
  }

  Future<CalendarShareResult> shareWith(String username) async {
    final result = await sendRequest<String>(
      method: HttpMethod.post,
      path: '/share/add',
      body: {
        'calendar': id,
        'user': username,
      },
    );

    return CalendarShareResultMessage.fromStringCode(result);
  }

  Future<void> revokeShare(String username) async {
    return sendRequest(
      method: HttpMethod.delete,
      path: '/share/revoke',
      body: {
        'calendar': id,
        'user': username,
      },
    );
  }
}