import 'package:flutter/material.dart';
import 'package:fitcheck/pages/home_page.dart';
import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';


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

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
       theme: ThemeData.dark().copyWith(
    scaffoldBackgroundColor: Colors.black,
  ),
      home: const HomePage(),
      
    );
  }
}
