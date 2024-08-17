// main.dart
import 'package:cron/cron.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'screens/Add_med.dart';
import 'screens/edit_med.dart';
import 'screens/homepage.dart';
import 'screens/welcome.dart'; // Import the WelcomePage widget
import 'package:app/screens/Notification/Notification_helper.dart';

final dio = Dio();
void main() {
  runApp(MyApp());
// Initialize notifications
  Notifications notifications = Notifications();
  // Schedule notifications every 24 hours
final cron = Cron();
cron.schedule(Schedule.parse('* * * *'), () async {
 notifications.initNotifies();
 });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Set debug banner to false
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Add a delay to navigate to the home page after 3 seconds
    Future.delayed(Duration(seconds: 3), () {
      // Navigate to the home page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return WelcomePage(); // Display the WelcomePage initially
  }
}
