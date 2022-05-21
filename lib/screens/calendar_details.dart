import 'package:calendar_app/data_types/authentication.dart';
import 'package:calendar_app/data_types/calendar.dart';
import 'package:calendar_app/data_types/calendar_event.dart';
import 'package:calendar_app/screens/calendar_editor.dart';
import 'package:calendar_app/screens/event_editor.dart';
import 'package:calendar_app/util/delete_prompt.dart';
import 'package:calendar_app/util/input_blocker.dart';
import 'package:calendar_app/util/refreshing_display.dart';
import 'package:calendar_app/util/route_provider.dart';
import 'package:calendar_app/widgets/event_list.dart';
import 'package:calendar_app/widgets/maybe_empty_description.dart';
import 'package:calendar_app/widgets/progress_builder.dart';
import 'package:flutter/material.dart';

enum _CalendarOptions {
  addEvent,
  edit,
  share,
  delete,
}

Future<bool?> _showShareDialog(BuildContext context, Calendar calendar) async {
  final fieldKey = GlobalKey<FormFieldState>();
  String? errorOverride;

  return await showDialog(
    context: context,
    builder: (context) => SimpleDialog(
      title: const Text('Compartilhar calendário'),
      contentPadding: const EdgeInsets.all(15),
      children: [
        TextFormField(
          key: fieldKey,
          maxLength: 50,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (value) {
            if (errorOverride != null) {
              return errorOverride;
            } else if (value == null || value.isEmpty) {
              return 'Digite um nome';
            }
          },
          onChanged: (_) => errorOverride = null,
          decoration: const InputDecoration(
            labelText: 'Usuário:'
          ),
        ),

        TextButton(
          child: const Text('OK'),
          onPressed: () async {
            if (fieldKey.currentState!.validate()) {
              final username = fieldKey.currentState!.value;
              final result = await wrapServiceRequest(context, calendar.shareWith(username));

              if (result.ok) {
                if (result.value == CalendarShareResult.ok) {
                  Navigator.pop(context, true);
                } else {
                  errorOverride = result.value!.errorMessage;
                  fieldKey.currentState!.validate();
                }
              }
            }
          },
        )
      ],
    )
  );
}

class CalendarDetails extends StatelessWidget {
  const CalendarDetails(this.calendar, { Key? key }) : super(key: key);
  final Calendar calendar;

  @override
  Widget build(BuildContext context) {
    return PhysicalModel(
      color: Colors.white,
      borderRadius: BorderRadius.circular(25),
      elevation: 10,
    
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
    
          children: [
            Text(
              calendar.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
              )
            ),
    
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: maybeEmptyDescription(calendar.description),
            ),
          ],
        ),
      ),
    );
  }
}

class CalendarDisplay extends StatefulWidget with RouteProviderMixin<void> {
  const CalendarDisplay(this.calendarId, { Key? key }) : super(key: key);
  final int calendarId;

  @override
  State<CalendarDisplay> createState() => _CalendarDisplayState();
}

class _CalendarDisplayState extends State<CalendarDisplay> with RouteAware, RefreshingDisplayMixin {
  late Future<Calendar?> _calendar;
  late Future<List<CalendarEvent>> _events;
  late Future<List<String>> _sharedWith;

  @override
  void refresh() => setState(() {
    _calendar = Calendar.download(widget.calendarId);
    _events = _calendar.then((calendar) => calendar?.downloadEvents() ?? Future.value([]));
    _sharedWith = _calendar.then((calendar) => calendar?.getSharedWith() ?? Future.value([]));
  });

  Function (_CalendarOptions) _optionsHandler(Calendar calendar) {
    return (_CalendarOptions option) async {
      switch (option) {
        case _CalendarOptions.addEvent:
          editEvent(
            context: context,
            calendar: calendar,
          );
          break;
        case _CalendarOptions.delete:
          if (await showDeletePrompt(context, 'Esse calendário sumirá para sempre.') == true) {
            await wrapServiceRequest(context, calendar.delete());
            Navigator.pop(context);
          }
          break;
        case _CalendarOptions.edit:
          final newCalendar = await showCalendarEditor(context, calendar);

          if (newCalendar != null) {
            await wrapServiceRequest(context, newCalendar.publish());
            refresh();
          }

          break;
        case _CalendarOptions.share:
          if (await _showShareDialog(context, calendar) == true) refresh();
          break;
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: const [
              Icon(Icons.calendar_today),
              SizedBox(width: 15),
              Text('Detalhes'),
            ]
          ),
    
          actions: [
            FutureBuilder(
              future: _calendar,
              builder: (context, AsyncSnapshot<Calendar?> snapshot) {
                if (
                  snapshot.connectionState == ConnectionState.done
                  && !snapshot.hasError
                  && snapshot.data != null
                ) {
                  final calendar = snapshot.data!;
                  final currentUser = Authentication.currentUser?.userid;
    
                  return PopupMenuButton(
                    onSelected: _optionsHandler(calendar),
    
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: _CalendarOptions.addEvent,
                        child: Text('Novo evento'),
                      ),
    
                      const PopupMenuItem(
                        value: _CalendarOptions.edit,
                        child: Text('Editar'),
                      ),
    
                      PopupMenuItem(
                        value: _CalendarOptions.share,
                        child: const Text('Compartilhar'),
                        enabled: calendar.owner == currentUser,
                      ),
    
                      PopupMenuItem(
                        value: _CalendarOptions.delete,
                        child: const Text('Excluir'),
                        enabled: calendar.owner == currentUser,
                      ),
                    ],
                  );
                } else {
                  return const SizedBox();
                }
              },
            ),

            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => refresh(),
              tooltip: 'Recarregar página',
            )
          ],
    
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Detalhes'),
              Tab(text: 'Eventos'),
              Tab(text: 'Usuários'),
            ],
          ),
        ),
    
        body: TabBarView(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(25),
              child: ProgressBuilder(
                future: _calendar,
                builder: (context, Calendar? calendar) {
                  if (calendar == null) {
                    Navigator.pop(context);
                    return const SizedBox();
                  } else {
                    return CalendarDetails(calendar);
                  }
                },
              ),
            ),
    
            ProgressBuilder(
              future: _events,
              builder: (context, List<CalendarEvent> events) => EventList(events),
            ),
    
            ProgressBuilder(
              future: Future.wait([_calendar, _sharedWith]),
              builder: (context, List futures) {
                final Calendar calendar = futures[0];
                final List<String> users = futures[1];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 25, top: 25),
                      child: Text(
                        'Compartilhado com:',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: users.length,
                        itemBuilder: (context, index) => ListTile(
                          contentPadding: const EdgeInsets.only(left: 35),
                          title: Text(users[index]),
                          onTap: () async {
                            if (Authentication.currentUser?.userid == calendar.owner) {
                              final result = await showDeletePrompt(context, 'Excluir o acesso deste usuário?');

                              if (result == true) {
                                await wrapServiceRequest(
                                  context, 
                                  _calendar.then((calendar) => calendar?.revokeShare(users[index]))
                                );
                                
                                refresh();
                              }
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                );
              }
            ),
          ],
        )
      ),
    );
  }
}