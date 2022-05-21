import 'package:calendar_app/data_types/authentication.dart';
import 'package:calendar_app/data_types/credentials.dart';
import 'package:calendar_app/main.dart';
import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  static String currentRoute = AppRoute.events.name;

  const AppDrawer({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ListTile makeTile(IconData icon, String text, String route) {
      return ListTile(
        leading: Icon(icon),
        title: Text(text),
        selected: currentRoute == route,
        onTap: () {
          currentRoute = route;
          Navigator.pushReplacementNamed(context, route);
        },
      );
    }

    return Drawer(
      child: ListView(
        controller: ScrollController(),
        children: [
          DrawerHeader(
            child: Column(
              children: [
                const Icon(Icons.person, size: 80, color: Colors.blue),
                Text(Authentication.currentUsername ?? 'NULL'),
              ]
            )
          ),

          makeTile(Icons.event, 'Eventos', AppRoute.events.name),
          makeTile(Icons.calendar_today_outlined, 'Calendários', AppRoute.calendars.name),

          ListTile(
            leading: const Icon(Icons.remove_circle, color: Colors.red),
            title: const Text('Desconectar'),
            onTap: () async {
              await UserCredentials.clear();
              Navigator.pushReplacementNamed(context, AppRoute.login.name);
            },
          ),
        ],
      ),
    );
  }
}