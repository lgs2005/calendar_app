import 'package:calendar_app/data_types/calendar.dart';
import 'package:calendar_app/data_types/calendar_event.dart';
import 'package:calendar_app/screens/calendar_picker.dart';
import 'package:calendar_app/util/time_utils.dart';
import 'package:calendar_app/util/input_blocker.dart';
import 'package:calendar_app/util/route_provider.dart';
import 'package:calendar_app/widgets/date_time_fields.dart';
import 'package:flutter/material.dart';

class EventEditor extends StatefulWidget with RouteProviderMixin<CalendarEvent> {
  const EventEditor({
    Key? key,
    this.initialEvent,
    required this.calendar,
    this.publishEvent = true,
  }) : super(key: key);

  final CalendarEvent? initialEvent;
  final Calendar calendar;
  final bool publishEvent;

  @override
  State<EventEditor> createState() => _EventEditorState();
}

class _EventEditorState extends State<EventEditor> {
  DateTime? _date;
  TimeOfDay? _time;
  String? _title;
  String? _description;

  @override
  void initState() {
    final event = widget.initialEvent;

    if (event != null) {
      _title = event.title;
      _description = event.description;
      _date = event.localDate.dateOnly;
      _time = event.localDate.timeOfDay;
    }

    super.initState();
  }

  void _onSubmitted() async {
    if (_title != null && _title!.isNotEmpty && _date != null && _time != null) {
      final newEvent = CalendarEvent(
        id: widget.initialEvent?.id ?? 0,
        title: _title!,
        description: _description ?? '',
        localDate: _date!.add(_time!.asDuration),
        calendar: widget.calendar.id,
      );

      if (widget.publishEvent) {
        await wrapServiceRequest(context, newEvent.publish());
      }

      Navigator.pop(context, newEvent);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurar evento'),
      ),

      floatingActionButton: FloatingActionButton.extended(
        label: const Text('Confirmar'),
        backgroundColor: Colors.blue,
        onPressed: _onSubmitted,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PhysicalModel(
              color: Colors.white,
              elevation: 10,
              borderRadius: BorderRadius.circular(25),
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        style: const TextStyle(fontSize: 20),
                        children: [
                          const WidgetSpan(child: Icon(Icons.calendar_today_outlined)),
                          const TextSpan(text: ' Calendário: ', style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: widget.calendar.title)
                        ]
                      )
                    ),

                    const SizedBox(height: 15),
                    DatePicker(
                      onSubmitted: (date) => _date = date,
                      initialDate: _date,
                    ),

                    const SizedBox(height: 15),
                    TimeOfDayPicker(
                      onSubmitted: (time) => _time = time,
                      initialTime: _time,
                    ),

                    const SizedBox(height: 15),
                    const Divider(),

                    TextFormField(
                      maxLength: 50,
                      initialValue: _title,
                      onChanged: (value) => _title = value,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'É necessário um título.';
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: 'Título',
                        floatingLabelBehavior: FloatingLabelBehavior.always
                      ),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),

                    TextFormField(
                      minLines: 10,
                      maxLines: 10,
                      maxLength: 500,
                      initialValue: _description,
                      onChanged: (value) => _description = value,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.all(10),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        labelText: 'Descrição',
                        hintText: '(Nenhuma descrição)',
                      ),
                    )
                  ],
                ),
              ),
            ),
          ]
        ),
      ),
    );
  }
}

Future<CalendarEvent?> editEvent({
  required BuildContext context,
  CalendarEvent? event,
  Calendar? calendar,
}) async {
  calendar ??= await const CalendarPicker().pushOnto(context);

  if (calendar != null) {
    final editor = EventEditor(
      calendar: calendar,
      initialEvent: event,
    );

    return await editor.pushOnto(context);
  }
}