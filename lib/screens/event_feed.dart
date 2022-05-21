import 'package:calendar_app/data_types/calendar_event.dart';
import 'package:calendar_app/util/refreshing_display.dart';
import 'package:calendar_app/widgets/app_drawer.dart';
import 'package:calendar_app/screens/event_editor.dart';
import 'package:calendar_app/widgets/event_list.dart';
import 'package:calendar_app/widgets/progress_builder.dart';
import 'package:flutter/material.dart';

class EventFeed extends StatefulWidget {
  const EventFeed({ Key? key }) : super(key: key);

  @override
  _EventFeedState createState() => _EventFeedState();
}

class _EventFeedState extends State<EventFeed> with RouteAware, RefreshingDisplayMixin {
  late Future<List<CalendarEvent>> _eventList;

  @override
  void refresh() {
    setState(() {
      _eventList = CalendarEvent.downloadFeed();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Novo evento',
            onPressed: () => editEvent(context: context).then((_) => refresh),
          ),

          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recarregar',
            onPressed: () => refresh(),
          ),
        ],

        title: const Text('Eventos'),
      ),

      drawer: const AppDrawer(),

      body: ProgressBuilder(
        future: _eventList,
        builder: (context, List<CalendarEvent> events) => EventList(events)
      ),
    );
  }
}