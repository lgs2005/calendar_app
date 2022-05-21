import 'package:calendar_app/data_types/calendar.dart';
import 'package:calendar_app/util/input_blocker.dart';
import 'package:flutter/material.dart';

class CalendarEditor extends StatelessWidget {
  const CalendarEditor(this.initialCalendar, { Key? key }) : super(key: key);

  final Calendar? initialCalendar;

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    String? title = initialCalendar?.title;
    String? description = initialCalendar?.description;

    return Form(
      key: formKey,
      child: SimpleDialog(
        contentPadding: const EdgeInsets.all(20),
        children: [
          TextFormField(
            autofocus: true,
            initialValue: title,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) => value == null || value.isEmpty ? 'Digite um nome' : null,
            onChanged: (value) => title = value,
            maxLength: 50,
            decoration: const InputDecoration(
              labelText: 'Título'
            ),
          ),

          TextFormField(
            maxLength: 500,
            minLines: 1,
            maxLines: 10,
            initialValue: description,
            onChanged: (value) => description = value,
            decoration: const InputDecoration(
              labelText: 'Descrição'
            ),
          ),
    
          TextButton(
            child: const Text('OK'),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                if (initialCalendar == null) {
                  Navigator.pop(context, await wrapServiceRequest(
                    context,
                    Calendar.create(title!, description ?? ''),
                  ).then((result) => result.value));
                } else {
                  final calendar = Calendar(
                    id: initialCalendar!.id,
                    title: title!,
                    description: description ?? '',
                    owner: initialCalendar!.owner,
                  );

                  await wrapServiceRequest(context, calendar.publish());
                  Navigator.pop(context, calendar);
                }
              }
            },
          )
        ],
      ),
    );
  }
}

Future<Calendar?> showCalendarEditor(BuildContext context, Calendar? calendar) {
  return showDialog(
    context: context,
    builder: (context) => CalendarEditor(calendar),
  );
}