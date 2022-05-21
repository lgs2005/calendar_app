import 'package:calendar_app/data_types/calendar.dart';
import 'package:calendar_app/screens/calendar_editor.dart';
import 'package:calendar_app/util/route_provider.dart';
import 'package:calendar_app/widgets/maybe_empty_description.dart';
import 'package:calendar_app/widgets/progress_builder.dart';
import 'package:flutter/material.dart';

class CalendarButton extends StatelessWidget {
  const CalendarButton({
    Key? key,
    required this.calendar,
    required this.onPressed,
  }) : super(key: key);

  final Calendar calendar;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,

      style: ElevatedButton.styleFrom(
        alignment: Alignment.topLeft,
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        padding: const EdgeInsets.all(25),
        onPrimary: Colors.cyan,
        primary: Colors.white,
      ),
    
      child: DefaultTextStyle(
        style: const TextStyle(
          color: Colors.black,
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              calendar.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              )
            ),
              
            Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 10),
              child: maybeEmptyDescription(calendar.description)
            ),
          ],
        ),
      ),
    );
  }
}

class CalendarPicker extends StatefulWidget with RouteProviderMixin<Calendar?> {
  const CalendarPicker({
    Key? key,
  }) : super(key: key);

  @override
  _CalendarPickerState createState() => _CalendarPickerState();
}

class _CalendarPickerState extends State<CalendarPicker> {
  late Future<List<Calendar>> _calendars;

  void _refresh() {
    setState(() {
      _calendars = Calendar.downloadList();
    });
  }

  @override
  void initState() {
    _refresh();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendários'),

        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Criar calendário',
            onPressed: () async {
              await showCalendarEditor(context, null);
              _refresh();
            },
          ),

          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recarregar lista',
            onPressed: _refresh,
          ),
        ],
      ),

      body: ProgressBuilder(
        future: _calendars,
        builder: (context, List<Calendar> calendars) => ListView.builder(
          itemCount: calendars.length,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.all(15),
            child: CalendarButton(
              calendar: calendars[index],
              onPressed: () => Navigator.pop(context, calendars[index]),
            ),
          ),
        ),
      ),
    );
  }
}