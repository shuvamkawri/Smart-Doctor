import 'package:ai_medi_doctor/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'notification.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    await _notificationService.initialize();
  }

  // This method will show the video call approved notification
  Future<void> _showVideoCallApprovedNotification(String message) async {
    await _notificationService.showNotification(
        'Video Call Request Approved', message);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.splashScreen,
      routes: AppRoutes.routes,
    );
  }
}
