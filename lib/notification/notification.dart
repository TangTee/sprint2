import 'package:flutter/material.dart';
import 'services/local_notification_service.dart';

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
    return Drawer(
      child: ListView(
        children: <Widget>[
          const DrawerHeader(child: Text('Header')),
          const ListTile(
            title: Text("Item 1"),
          ),
          ListTile(
            title: const Text("Item 1"),
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
