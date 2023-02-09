import 'package:flutter/material.dart';
import 'services/local_notification_service.dart';
import 'screens/second_screen.dart';

class notification extends StatefulWidget {
  const notification({super.key});

  @override
  State<notification> createState() => _notificationState();
}

class _notificationState extends State<notification> {
  late final LocalNotificationService service;

  @override
  void initState() {
    service = LocalNotificationService();
    service.intialize();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Drawer(
      child: new ListView(
        children: <Widget>[
          new DrawerHeader(child: new Text('Header')),
          new ListTile(
            title: new Text("Item 1"),
          ),
          new ListTile(
            title: new Text("Item 1"),
            onTap: () async {
              await service.showNotification(
                  id: 0, title: 'Notification Title', body: 'Some body');
            },
          )
        ],
      ),
    );
  }
}
