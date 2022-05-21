import 'package:flutter/material.dart';

final monthStringMap = [
  'Janeiro',
  'Fevereiro',
  'Março',
  'Abril',
  'Maio',
  'Junho',
  'Julho',
  'Agosto',
  'Setembro',
  'Outubro',
  'Novembro',
  'Dezembro'
];

final weekdayMap = [
  'Segunda',
  'Terça',
  'Quarta',
  'Quinta',
  'Sexta',
  'Sábado',
  'Domingo',
];

String padNumber(int number, int width) => number.toString().padLeft(width, '0');

extension DateTimeUtils on DateTime {
  DateTime get dateOnly => DateUtils.dateOnly(this);
  TimeOfDay get timeOfDay => TimeOfDay.fromDateTime(this);
  
  int get minutesSinceMidnight => (hour * 60) + minute;
  int get minutesSinceEpoch => secondsSinceEpoch ~/ 60;
  int get secondsSinceEpoch => millisecondsSinceEpoch ~/ 1000;
}

extension DateTimeFormatting on DateTime {
  String get weekdayString => weekdayMap[weekday - 1];
  String get monthString => monthStringMap[month - 1];
  String get monthStringShort => monthString.substring(1, 4);

  String get formatDay => padNumber(day, 2);
  String get formatYear => padNumber(year, 4);
  String get formatHour => padNumber(hour, 2);
  String get formatMinute => padNumber(minute, 2);
  String get formatSecond => padNumber(second, 2);

  String get formatMD => '$formatDay de $monthString';
  String get fullDateString => '$formatDay de $monthString de $formatYear';
  String get fullDescription => '$weekdayString, $fullDateString';
  String get formatHMS => '$formatHour:$formatMinute:$formatSecond';
}

extension TimeOfDayUtils on TimeOfDay {
  int get totalMinutes => (hour * 60) + minute;

  DateTime get asDate => DateTime.fromMillisecondsSinceEpoch(totalMinutes * 60000);
  Duration get asDuration => Duration(hours: hour, minutes: minute);

  int compareTo(TimeOfDay other) {
    return totalMinutes.compareTo(other.totalMinutes);
  }
}

extension TimeOfDayFormatting on TimeOfDay {
  String get formatHour => padNumber(hour, 2);
  String get formatMinute => padNumber(minute, 2);
  String get format24h => '$formatHour:$formatMinute';
}

extension DurationFormatting on Duration {
  String get fullDescription {
    final days = inDays;
    final hours = inHours - inDays * Duration.hoursPerDay;
    final minutes = inMinutes - inHours * Duration.minutesPerHour;
    final seconds = inSeconds - inMinutes * Duration.secondsPerMinute;

    return [
      if (days > 1) '$days dias, ',
      if (days == 1) '$days dia, ',
      if (hours > 0) '$hours horas, ',
      if (hours > 0 || minutes > 0) '$minutes minutos e ',
      '$seconds segundos',
    ].join();
  }
}