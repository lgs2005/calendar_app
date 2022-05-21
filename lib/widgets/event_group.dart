import 'package:calendar_app/data_types/calendar_event.dart';
import 'package:calendar_app/util/time_utils.dart';
import 'package:calendar_app/screens/event_details.dart';
import 'package:flutter/material.dart';

class EventEntry extends StatelessWidget {
  const EventEntry(this.event, {Key? key}) : super(key: key);

  final CalendarEvent event;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        EventDetailsScreen(event.id).pushOnto(context);
      },

      style: TextButton.styleFrom(
        primary: Colors.black,
      ),

      child: event.description.isEmpty
      ? Text(event.title, style: const TextStyle(fontSize: 20))
      : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(event.title, style: const TextStyle(fontSize: 20)),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Text(event.description),
          ),
        ],
      )
    );
  }
}

class EventGroup extends StatelessWidget {
  EventGroup({
    Key? key,
    required DateTime date,
    required List<CalendarEvent> events,
  }) 
  : date = date.toLocal(),
    super(key: key)
  {
    for (final event in events) {
      _events.update(
        event.localDate.timeOfDay,
        (list) => list..add(event),
        ifAbsent: () => [event],
      );
    }
  }

  final DateTime date;
  final Map<TimeOfDay, List<CalendarEvent>> _events = {};

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(25),
      child: PhysicalModel(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        elevation: 10,

        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                date.formatMD,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),

              for (final time in _events.keys.toList()..sort((a, b) => a.compareTo(b)))
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: Text(
                            time.format24h,
                            style: const TextStyle(color: Colors.blue, fontSize: 16),
                          ),
                        ),
                        Expanded(child: Container(height: .5, color: Colors.blue)),
                      ],
                    ),

                    for (final event in _events[time]!)
                    Padding(
                      padding: const EdgeInsets.only(left: 25, bottom: 5),
                      child: EventEntry(event),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}