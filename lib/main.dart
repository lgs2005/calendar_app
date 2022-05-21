import 'package:calendar_app/data_types/authentication.dart';
import 'package:calendar_app/data_types/credentials.dart';
import 'package:calendar_app/screens/event_feed.dart';
import 'package:calendar_app/screens/login.dart';
import 'package:calendar_app/screens/calendar_list.dart';
import 'package:calendar_app/util/refreshing_display.dart';
import 'package:flutter/material.dart';

enum AppRoute {
  login,
  events,
  calendars,
}

extension RouteName on AppRoute {
  String get name {
    switch (this) {
      case AppRoute.login: return '/login';
      case AppRoute.events: return '/events';
      case AppRoute.calendars: return '/calendars';
    }
  }
}

Future<bool> restoreSession() async {
  final credentials = await UserCredentials.restore();
  return (
    credentials != null &&
    await Authentication.login(credentials, false) == LoginResult.ok
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final initialRoute = //AppRoute.login;
    await restoreSession()
      .then((restored) => restored ? AppRoute.events : AppRoute.login)
      .catchError((_) => AppRoute.login);

  print(initialRoute);

  runApp(
    MaterialApp(
      title: 'Calendário',
      initialRoute: initialRoute.name,
      debugShowCheckedModeBanner: false,
      navigatorObservers: [routeObserver],
      routes: {
        AppRoute.login.name: (context) => const LoginScreen(),
        AppRoute.events.name: (context) => const EventFeed(),
        AppRoute.calendars.name: (context) => const CalendarListScreen(),
      },
    )
  );
}