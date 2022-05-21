import 'package:calendar_app/data_types/calendar_event.dart';
import 'package:calendar_app/util/time_utils.dart';
import 'package:calendar_app/util/delete_prompt.dart';
import 'package:calendar_app/util/error_prompt.dart';
import 'package:calendar_app/util/input_blocker.dart';
import 'package:calendar_app/util/refreshing_display.dart';
import 'package:calendar_app/util/route_provider.dart';
import 'package:calendar_app/widgets/clock.dart';
import 'package:calendar_app/screens/event_editor.dart';
import 'package:calendar_app/widgets/maybe_empty_description.dart';
import 'package:calendar_app/widgets/progress_builder.dart';
import 'package:flutter/material.dart';

enum _EventOptions {
  edit,
  delete,
}

class EventDetails extends StatelessWidget {
  const EventDetails(this.event, { Key? key }) : super(key: key);
  final CalendarEvent event;

  @override
  Widget build(BuildContext context) {
    return PhysicalModel(
      color: Colors.white,
      elevation: 10,
      borderRadius: BorderRadius.circular(25),

      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DefaultTextStyle.merge(
              style: const TextStyle(fontSize: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        const WidgetSpan(child: Icon(Icons.event)),
                        const TextSpan(text: ' Data: ', style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: event.localDate.fullDescription),
                      ]
                    ),
                  ),

                  const SizedBox(height: 15),
                  Text.rich(
                    TextSpan(
                      children: [
                        const WidgetSpan(child: Icon(Icons.timer)),
                        const TextSpan(text: ' Horário: ', style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: event.localDate.timeOfDay.format24h),
                      ],
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 15),
            const Divider(),

            Text(
              event.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
            ),

            Padding(
              padding: const EdgeInsets.all(10),
              child: maybeEmptyDescription(event.description),
            ),

            const SizedBox(height: 50),
            Countdown(event.localDate, style: const TextStyle(fontSize: 15)),
          ],
        ),
      ),
    );
  }
}

class EventDetailsScreen extends StatefulWidget with RouteProviderMixin<void> {
  const EventDetailsScreen(this.eventId, { Key? key }) : super(key: key);

  final int eventId;

  @override
  _EventDetailsScreenState createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> with RouteAware, RefreshingDisplayMixin {
  late Future<CalendarEvent?> _event;

  @override
  void refresh() {
    setState(() {
      _event = CalendarEvent.download(widget.eventId);
    });
  }

  Future<void> _showEventEditor(CalendarEvent event) async {
    final result = await wrapServiceRequest(context, Future.sync(() async {
      final calendar = await event.getCalendar();

      if (calendar == null) {
        showErrorPrompt(
          context: context,
          onDismissed: () => Navigator.pop(context),
        );
      } else {
        return calendar;
      }
    }));

    if (result.ok) {
      if (result.value != null) {
        final newEvent = await editEvent(
          context: context,
          event: event,
          calendar: result.value,
        );

        if (newEvent != null) {
          EventDetailsScreen(newEvent.id).pushReplacementOnto(context);
        }
      } else {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes'),

        actions: [
          FutureBuilder(
            future: _event,
            builder: (context, AsyncSnapshot<CalendarEvent?> snapshot) {
              if (snapshot.connectionState == ConnectionState.done && !snapshot.hasError) {
                if (snapshot.data != null) {
                  final event = snapshot.data!;

                  return PopupMenuButton(
                    onSelected: (option) async {
                      switch (option) {
                        case _EventOptions.edit:
                          _showEventEditor(event);
                          break;
                        case _EventOptions.delete:
                          if (await showDeletePrompt(context, 'Este evento sumirá para sempre.') == true) {
                            await blockInput(context, event.delete());
                            Navigator.pop(context);
                          }
                          break;
                      }
                    },
    
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: _EventOptions.edit,
                        child: Text('Editar'),
                      ),
    
                      const PopupMenuItem(
                        value: _EventOptions.delete,
                        child: Text('Excluir'),
                      ),
                    ],
                  );
                }
              }

              return const SizedBox();
            },
          ),

          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => refresh(),
          ),
        ],
      ),

      body: ProgressBuilder(
        future: _event,
        builder: (context, CalendarEvent? event) {
          if (event == null) {
            showErrorPrompt(
              context: context,
              onDismissed: () => Navigator.pop(context),
            );
            return const SizedBox();
          } else {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(15),
              child: EventDetails(event),
            );
          }
        },
      ),
    );
  }
}