import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:notifications/notifications.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class PushNotificationService{
 final FirebaseMessaging fcm= FirebaseMessaging.instance;

  Future initialize(){

    fcm.getToken();

  }
}


class notification extends StatefulWidget {
  @override
  _notificationState createState() => _notificationState();
}

class _notificationState extends State<notification> {
  Notifications _notifications;
  StreamSubscription<NotificationEvent> _subscription;
  List<NotificationEvent> _log = [];
  bool started = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    startListening();
  }

  void onData(NotificationEvent event) {
    setState(() {
      _log.add(event);
    });
    print(event.toString());
  }

  void startListening() {
    _notifications = new Notifications();
    try {
      _subscription = _notifications.notificationStream.listen(onData);
      setState(() => started = true);
    } on NotificationException catch (exception) {
      print(exception);
    }
  }

  void stopListening() {
    _subscription.cancel();
    setState(() => started = false);
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text('Notifications Example app'),
        ),
        body: new Center(
            child: new ListView.builder(
                itemCount: _log.length,
                reverse: true,
                itemBuilder: (BuildContext context, int idx) {
                  final entry = _log[idx];
                  return ListTile(
                      leading:
                      Text(entry.timeStamp.toString().substring(0, 19)),
                      trailing:
                      Text(entry.packageName.toString().split('.').last));
                })),
        floatingActionButton: new FloatingActionButton(
          onPressed: started ? stopListening : startListening,
          tooltip: 'Start/Stop sensing',
          child: started ? Icon(Icons.stop) : Icon(Icons.play_arrow),
        ),
      ),
    );
  }
}