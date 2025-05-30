import 'package:flutter/material.dart';
import 'package:fitcheck/pages/freinds_page.dart';
import 'package:fitcheck/pages/profile_page.dart';
import 'package:fitcheck/pages/home_page.dart';
import 'package:fitcheck/pages/displayPicture_page.dart';
import 'package:camera/camera.dart';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fitcheck/main.dart';
import 'package:image_picker/image_picker.dart';


class PicturePage extends StatefulWidget {
  final CameraDescription camera;
  

  const PicturePage({
    super.key,
    required this.camera,

  });

  @override
  State<PicturePage> createState() => _PicturePageState();
}

class _PicturePageState extends State<PicturePage> {
  int currentIndex = 2;
  final DatabaseReference databaseRef = FirebaseDatabase.instance.ref();
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late List<CameraDescription> _cameras;
  int _currentCameraIndex = 0;

  Future<void> _pickImageFromGallery() async {
  try {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DisplayPictureScreen(imagePath: pickedFile.path),
        ),
      );
    }
  } catch (e) {
    print('Error picking image from gallery: $e');
  }
}


  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.max,
    );
    //_initializeControllerFuture = _controller.initialize();
    _initializeCamera();
    
  }

  Future<void> _initializeCamera() async {
  _cameras = cameras; // From main.dart, already initialized
  _currentCameraIndex = _cameras.indexOf(widget.camera);
  _controller = CameraController(_cameras[_currentCameraIndex], ResolutionPreset.max);
  _initializeControllerFuture = _controller.initialize();
  setState(() {}); // Refresh to show preview
}

void _flipCamera() async {
  if (_cameras.length < 2) return;

  _currentCameraIndex = (_currentCameraIndex + 1) % _cameras.length;

  await _controller.dispose();
  _controller = CameraController(_cameras[_currentCameraIndex], ResolutionPreset.max);
  _initializeControllerFuture = _controller.initialize();

  setState(() {});
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
                        height: MediaQuery.of(context).size.width + kBottomNavigationBarHeight,
                        child: Transform(
                        alignment: Alignment.center,
                        transform: _cameras[_currentCameraIndex].lensDirection == CameraLensDirection.front
                            ? Matrix4.rotationY(3.1415926535)  // Flip horizontally (π radians)
                            : Matrix4.identity(),              // No flip for rear camera
                        child: CameraPreview(_controller),
                      ),

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

      floatingActionButton: Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    Padding(
      padding: const EdgeInsets.only(bottom: 300),
      child: FloatingActionButton(
        heroTag: 'gallery',
        backgroundColor: Colors.white10,
        onPressed: _pickImageFromGallery,
        child: const Icon(Icons.photo_library, color: Colors.white),
      ),
    ),
    Padding(
      padding: const EdgeInsets.only(bottom: 230),
      child: FloatingActionButton(
        heroTag: 'flip',
        backgroundColor: Colors.white10,
        onPressed: _flipCamera,
        child: const Icon(Icons.flip_camera_ios, color: Colors.white),
      ),
    ),
    Padding(
      padding: const EdgeInsets.only(bottom: 120),
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
  child: Center(
    child: Icon(
      Icons.pets_rounded,
      size: 40, // Adjust to your liking
      color: Colors.white, // Hollow look = icon outline color
    ),
  ),
),

      ),
    ),
  ],
),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,



      
    );
  }
}
