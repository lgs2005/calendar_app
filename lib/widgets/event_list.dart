import 'package:calendar_app/data_types/calendar_event.dart';
import 'package:calendar_app/util/time_utils.dart';
import 'package:calendar_app/widgets/event_group.dart';
import 'package:flutter/material.dart';

class EventList extends StatelessWidget {
  EventList(List<CalendarEvent> events, { Key? key }) : super(key: key) {
    for (final event in events) {
      _events.update(
        event.localDate.dateOnly,
        (list) => list..add(event),
        ifAbsent: () => [event],
      );
    }

    _dayOrder = _events.keys.toList()..sort();

    if (_dayOrder.isNotEmpty && _dayOrder[0].year > DateTime.now().year) {
      _dayOrder.insert(0, _dayOrder[0]);
    }


    int i = 1;
    while (_dayOrder.length > i) {
      final date = _dayOrder[i];
      final last = _dayOrder[i-1];

      if (date.year > last.year) {
        _dayOrder.insert(i, DateTime(date.year));
      }
      i++;
    }
  }

  final Map<DateTime, List<CalendarEvent>> _events = {};
  late final List<DateTime> _dayOrder;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _dayOrder.length,
      itemBuilder: (context, index) {
        final date = _dayOrder[index];
        final last = index > 0 ? _dayOrder[index-1] : DateTime.now();
        
        if (date.year > last.year) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 25),
            color: Colors.blue.withAlpha(255~/4),
            child: Text(
              'Após ' + date.year.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 30,
              ),
            ),
          );
        } else {
          return EventGroup(
            date: date,
            events: _events[date]!,
          );
        }
      },
    );
  }
}