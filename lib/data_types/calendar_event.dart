import 'package:calendar_app/data_types/calendar.dart';
import 'package:calendar_app/util/time_utils.dart';

import '../service.dart';

class CalendarEvent {
  final int id;
  final String title;
  final DateTime localDate;
  final String description;
  final int calendar;

  const CalendarEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.localDate,
    required this.calendar,
  });

  factory CalendarEvent.fromMap(Map<String, dynamic> data) {
    if (
      data['id'] is! int
      || data['title'] is! String
      || data['timestamp'] is! int
      || data['description'] is! String
      || data['calendar'] is! int
    ) throw const FormatException();

    final date = DateTime.fromMillisecondsSinceEpoch(data['timestamp'] * 60000);

    return CalendarEvent(
      id: data['id'],
      title: data['title'],
      localDate: date,
      description: data['description'],
      calendar: data['calendar'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'calendar': calendar,
      'timestamp': localDate.minutesSinceEpoch,
      'description': description,
    };
  }

  Future<CalendarEvent> publish() {
    return sendRequest(
      method: HttpMethod.post,
      path: '/publish/events',
      body: toMap(),
      parser: (data) => CalendarEvent.fromMap(data),
    );
  }

  Future<void> delete() {
    return sendRequest<void>(
      method: HttpMethod.delete,
      path: '/delete/events',
      body: {'id': id},
    );
  }

  Future<Calendar?> getCalendar() {
    return Calendar.download(calendar);
  }

  static Future<CalendarEvent?> download(int id) async {
    final result = await sendRequest(
      method: HttpMethod.get,
      path: '/search/events',
      body: {
        'id': id
      },
      listParser: (list) => list.map((data) => CalendarEvent.fromMap(data)).toList(),
    );

    return result.isNotEmpty ? result[0] : null;
  }

  static Future<List<CalendarEvent>> downloadFeed() {
    return sendRequest(
      method: HttpMethod.get,
      path: '/search/events',
      body: {
        'after': DateTime.now().minutesSinceEpoch,
      },
      listParser: (list) => list.map((data) => CalendarEvent.fromMap(data)).toList(),
    );
  }
}