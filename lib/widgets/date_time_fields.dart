import 'package:flutter/material.dart';
import 'package:calendar_app/util/time_utils.dart';

const labelStyle = TextStyle(
  color: Colors.black,
  fontSize: 20,
);

final missingStyle = labelStyle.copyWith(
  color: Colors.grey,
  fontStyle: FontStyle.italic,
);

class DatePicker extends StatefulWidget {
  const DatePicker({
    Key? key,
    this.initialDate,
    required this.onSubmitted,
  }) : super(key: key);

  final DateTime? initialDate;
  final void Function(DateTime?) onSubmitted;

  @override
  _DatePickerState createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  DateTime? _date;

  @override
  void initState() {
    _date = widget.initialDate;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      style: TextButton.styleFrom(
        splashFactory: NoSplash.splashFactory,
        padding: EdgeInsets.zero,
      ),

      icon: const Icon(Icons.event, size: 30, color: Colors.black),
      label: _date == null
        ? Text('Escolha uma data', style: missingStyle)
        : Text.rich(
            TextSpan(
              children: [
                TextSpan(text: 'Data: ', style: labelStyle.copyWith(fontWeight: FontWeight.bold)),
                TextSpan(text: _date!.fullDescription, style: labelStyle),
              ],
            )
          ),

      onPressed: () async {
        final chosenDate = await showDatePicker(
          context: context,
          initialDate: _date ?? DateTime.now(),
          firstDate: DateTime.fromMillisecondsSinceEpoch(0),
          lastDate: DateTime.utc(3000).toLocal(),
        );

        if (chosenDate != null) {
          setState(() {
            _date = chosenDate;
          });

          widget.onSubmitted(_date);
        }
      },
    );
  }
}

class TimeOfDayPicker extends StatefulWidget {
  const TimeOfDayPicker({
    Key? key,
    this.initialTime,
    required this.onSubmitted,
  }) : super(key: key);

  final TimeOfDay? initialTime;
  final void Function(TimeOfDay?) onSubmitted;

  @override
  State<TimeOfDayPicker> createState() => _TimeOfDayPickerState();
}

class _TimeOfDayPickerState extends State<TimeOfDayPicker> {
  TimeOfDay? _time;

  @override
  void initState() {
    _time = widget.initialTime;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      style: TextButton.styleFrom(
        splashFactory: NoSplash.splashFactory,
        padding: EdgeInsets.zero,
      ),

      icon: const Icon(Icons.timer, size: 30, color: Colors.black),
      label: _time == null
        ? Text('Escolha um horário', style: missingStyle)
        : Text.rich(
            TextSpan(
              children: [
                TextSpan(text: 'Horário: ', style: labelStyle.copyWith(fontWeight: FontWeight.bold)),
                TextSpan(text: _time!.format24h, style: labelStyle),
              ],
            )
          ),

      onPressed: () async {
        final chosenTime = await showTimePicker(
          context: context,
          initialTime: _time ?? TimeOfDay.now(),
        );

        if (chosenTime != null ){
          setState(() {
            _time = chosenTime;
          });

          widget.onSubmitted(_time);
        }
      },
    );
  }
}