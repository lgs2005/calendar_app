import 'dart:async';

import 'package:flutter/material.dart';
import 'package:calendar_app/util/time_utils.dart';

class TimerNotifier extends ValueNotifier<DateTime> {
  TimerNotifier(Duration period) : super(DateTime.now()) {
    _timer = Timer.periodic(period, (timer) => value = DateTime.now());
  }

  late final Timer _timer;

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}

final _tick = TimerNotifier(const Duration(seconds: 1));

class Clock extends StatelessWidget {
  const Clock({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _tick,
      builder: (context, DateTime time, widget) => Text(time.formatHMS),
    );
  }
}

class Countdown extends StatelessWidget {
  const Countdown(this.until, { Key? key, this.style }) : super(key: key);

  final TextStyle? style;
  final DateTime until;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _tick,
      builder: (context, DateTime now, child) {
        final difference = until.difference(now);

        if (difference.isNegative) {
          return Text('${difference.abs().fullDescription} atrás.', style: style);
        } else {
          return Text('Faltam ${difference.fullDescription}', style: style);
        }
      },
    );
  }
}