import 'package:calendar_app/data_types/calendar.dart';
import 'package:calendar_app/screens/calendar_details.dart';
import 'package:calendar_app/screens/calendar_editor.dart';
import 'package:calendar_app/screens/calendar_picker.dart';
import 'package:calendar_app/util/route_provider.dart';
import 'package:calendar_app/widgets/app_drawer.dart';
import 'package:calendar_app/util/refreshing_display.dart';
import 'package:calendar_app/widgets/progress_builder.dart';
import 'package:flutter/material.dart';

class CalendarListScreen extends StatefulWidget with RouteProviderMixin<void> {
  const CalendarListScreen({ Key? key }) : super(key: key);

  @override
  _CalendarListScreenState createState() => _CalendarListScreenState();
}

class _CalendarListScreenState extends State<CalendarListScreen>
  with RouteAware, RefreshingDisplayMixin
{
  late Future<List<Calendar>> _calendars;

  @override
  void refresh() => setState(() {
    _calendars = Calendar.downloadList();
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: const [
            Icon(Icons.calendar_today),
            Padding(padding: EdgeInsets.only(left: 15)),
            Text('Calendários'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Criar calendário',
            onPressed: () async {
              await showCalendarEditor(context, null);
              refresh();
            },
          ),

          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recarregar lista',
            onPressed: () => refresh(),
          ),
        ],
      ),

      drawer: const AppDrawer(),
      body: ProgressBuilder(
        future: _calendars,
        builder: (context, List<Calendar> calendars) => ListView.builder(
          itemCount: calendars.length,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.all(15),
            child: CalendarButton(
              calendar: calendars[index],
              onPressed: () => CalendarDisplay(calendars[index].id).pushOnto(context),
            ),
          ),
        ),
      ),
    );
  }
}