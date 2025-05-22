import 'package:flutter/material.dart';
import 'package:fitcheck/pages/freinds_page.dart';
import 'package:fitcheck/pages/profile_page.dart';
import 'package:fitcheck/pages/home_page.dart';
import 'package:fitcheck/pages/displayPicture_page.dart';
import 'package:camera/camera.dart';

class PicturePage extends StatefulWidget {
  const PicturePage({super.key, required this.camera});

  final CameraDescription camera;

  @override
  State<PicturePage> createState() => _PicturePageState();
}

class _PicturePageState extends State<PicturePage> {
  int currentIndex = 2; // FitCheck tab index
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();

    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );

    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (index == currentIndex) return;

    Widget page;
    switch (index) {
      case 0:
        page = const HomePage();
        break;
      case 1:
        page = const FreindsPage();
        break;
      case 2:
        // Pass the current camera to PicturePage to avoid errors
        page = PicturePage(camera: widget.camera);
        break;
      case 3:
        page = const ProfilePage();
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
  padding: const EdgeInsets.only(top: 60),
  child: SizedBox(
  //height:MediaQuery.of(context).size.height - 60 -kBottomNavigationBarHeight,
  width: double.infinity,
  child: FutureBuilder<void>(
    future: _initializeControllerFuture,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.done) {
        return ClipRect(
          child: OverflowBox(
            alignment: Alignment.center,
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                height: MediaQuery.of(context).size.width +kBottomNavigationBarHeight,
                child: CameraPreview(_controller),
              ),
            ),
          ),
        );
      } else {
        return const Center(child: CircularProgressIndicator());
      }
    },
  ),
),

),


      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        currentIndex: currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.people_alt_outlined), label: 'Friends'),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt_outlined), label: 'FitCheck'),
          BottomNavigationBarItem(icon: Icon(Icons.person_2_outlined), label: 'Profile'),
        ],
      ),
      floatingActionButton: Align(
  alignment: Alignment.bottomCenter,
  child: Padding(
    padding: const EdgeInsets.only(bottom: 170), // Adjust this value as needed
    child: GestureDetector(
      onTap: () async {
        try {
          await _initializeControllerFuture;
          final image = await _controller.takePicture();

          if (!mounted) return;

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DisplayPictureScreen(imagePath: image.path),
            ),
          );
        } catch (e) {
          print('Error taking picture: $e');
        }
      },
      child: Container(
        width: 85,
        height: 85,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 7),
          color: Colors.transparent,
        ),
      ),
    ),
  ),
),
floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,


    );
  }
}
