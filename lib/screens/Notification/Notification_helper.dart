import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class Notifications {
  late BuildContext _context;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  Future<FlutterLocalNotificationsPlugin> initNotifies() async {
    //-----------------------------| Initialize local notifications |--------------------------------------
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS);
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        new FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
    return flutterLocalNotificationsPlugin;
    //======================================================================================================
  }

  Future showNotification(
      String title,
      String description,
      TimeOfDay time,
      int id,
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Warsaw'));

    tz.TZDateTime scheduledTime = _getNextInstanceOfTime(time);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      description,
      scheduledTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'medicines_id',
          'medicines',
          'medicines_notification_channel',
          importance: Importance.high,
          priority: Priority.high,
          color: Colors.cyanAccent,
          playSound: true,
          sound: RawResourceAndroidNotificationSound('notification'),
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

tz.TZDateTime _getNextInstanceOfTime(TimeOfDay time) {
  tz.TZDateTime now = tz.TZDateTime.now(tz.local);

  tz.TZDateTime scheduled = tz.TZDateTime(
    tz.local,
    now.year,
    now.month,
    now.day,
    time.hour,
    time.minute,
  );

  // Check if the scheduled time is in the past
  if (scheduled.isBefore(now)) {
    // If yes, add one day to schedule it for the next occurrence
    scheduled = scheduled.add(Duration(days: 1));
  }

  // Schedule the notification daily at the specified time
  return tz.TZDateTime(
    tz.local,
    scheduled.year,
    scheduled.month,
    scheduled.day,
    time.hour,
    time.minute,
  );
}






  Future removeNotify(int notifyId,
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    try {
      return await flutterLocalNotificationsPlugin.cancel(notifyId);
    } catch (e) {
      return null;
    }
  }

  Future<dynamic> onSelectNotification(String? payload) async {
    showDialog(
      context: _context,
      builder: (_) {
        return AlertDialog(
          title: Text("PayLoad"),
          content: Text("Payload : $payload"),
        );
      },
    );
  }

  tz.TZDateTime parseTime(String time) {
    DateTime now = DateTime.now();
    List<String> parts = time.split(':');
    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);

    tz.TZDateTime scheduledTime = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    return scheduledTime;
  }


 
}
