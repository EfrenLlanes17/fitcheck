import 'package:flutter/material.dart';
import 'package:fitcheck/pages/home_page.dart';
import 'package:camera/camera.dart';

late final List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Await needs to be inside an async function
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
