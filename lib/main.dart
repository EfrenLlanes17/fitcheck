import 'package:flutter/material.dart';
import 'package:fitcheck/pages/home_page.dart';
import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fitcheck/pages/startpage.dart';
import 'package:fitcheck/pages/profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:awesome_notifications/awesome_notifications.dart';


late final List<CameraDescription> cameras;
// final firebaseApp = Firebase.app();
// final rtdb = FirebaseDatabase.instanceFor(app: firebaseApp, databaseURL: 'https://fitcheck-e648e-default-rtdb.firebaseio.com/');


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AwesomeNotifications().initialize(
    null, // icon for notification
    [
      NotificationChannel(
        channelKey: 'basic_channel',
        channelName: 'Basic Notifications',
        channelDescription: 'Notification channel for basic tests',
        defaultColor: Color(0xFF9D50DD),
        ledColor: Colors.white,
        importance: NotificationImportance.High,
      )
    ],
  );

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: Color.fromARGB(255, 255, 255, 255), // your desired color
    systemNavigationBarIconBrightness: Brightness.light, // or Brightness.light depending on contrast
  ));

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Firebase
  await Firebase.initializeApp();
  final firebaseApp = Firebase.app();
  final rtdb = FirebaseDatabase.instanceFor(
    app: firebaseApp,
    databaseURL: 'https://fitcheck-e648e-default-rtdb.firebaseio.com/',
  );

  // Initialize camera list
  cameras = await availableCameras();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> hasSavedUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('username');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: hasSavedUsername(),
      builder: (context, snapshot) {
        // While checking SharedPreferences
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData.light().copyWith(
              scaffoldBackgroundColor: const Color.fromARGB(255, 255, 255, 255),
            ),
            home: const Scaffold(
              backgroundColor: Color.fromARGB(255, 255, 255, 255),
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        // Once the check is complete
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: const Color.fromARGB(255, 255, 255, 255),
          ),
          home: snapshot.data == true
              ? const HomePage()
              : const StarterPage(),
        );
      },
    );
  }
}

