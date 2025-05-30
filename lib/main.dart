import 'package:flutter/material.dart';
import 'package:fitcheck/pages/home_page.dart';
import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fitcheck/pages/startpage.dart';
import 'package:fitcheck/pages/profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';


late final List<CameraDescription> cameras;
// final firebaseApp = Firebase.app();
// final rtdb = FirebaseDatabase.instanceFor(app: firebaseApp, databaseURL: 'https://fitcheck-e648e-default-rtdb.firebaseio.com/');


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
            theme: ThemeData.dark().copyWith(
              scaffoldBackgroundColor: Colors.black,
            ),
            home: const Scaffold(
              backgroundColor: Colors.black,
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        // Once the check is complete
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: Colors.black,
          ),
          home: snapshot.data == true
              ? const ProfilePage()
              : const StarterPage(),
        );
      },
    );
  }
}

