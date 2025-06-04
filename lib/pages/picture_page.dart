import 'package:flutter/material.dart';
import 'package:fitcheck/pages/groups_page.dart';
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
import 'package:audioplayers/audioplayers.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fitcheck/pages/message_page.dart';






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
  final AudioPlayer _audioPlayer = AudioPlayer();


  void _playBarkSound() {
    _audioPlayer.play(AssetSource('sounds/bark.mp3'));
  }

   void _playMeowSound() {
    _audioPlayer.play(AssetSource('sounds/meow.mp3'));
  }

  void _playSqueakSound() {
    _audioPlayer.play(AssetSource('sounds/squeak.mp3'));
  }

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
      case 4:
        page = const MessagePage();
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
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Padding(
  padding: const EdgeInsets.only(top: 25),
  child: Stack(
    children: [
      // Camera preview
      SizedBox(
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
                            ? Matrix4.rotationY(3.1415926535)
                            : Matrix4.identity(),
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

      // Bark button overlayed in top-right corner
     Positioned(
  top: 35,
  left: 0,
  right: 0,
  child: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      // Bark Button
      Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Color(0xFFFFBA76),
              shape: BoxShape.circle,
              
            ),
            child: IconButton(
              iconSize: 36,
              icon: const Icon(Icons.volume_up, color: Colors.white),
              tooltip: 'Bark!',
              onPressed: _playBarkSound,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Bark!',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFFBA76),
            ),
          ),
        ],
      ),

      const SizedBox(width: 24), // spacing between Bark and Meow

      // Meow Button
      Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Color(0xFFFFBA76),
              shape: BoxShape.circle,
              
            ),
            child: IconButton(
              iconSize: 36,
              icon: const Icon(Icons.volume_up, color: Colors.white),
              tooltip: 'Meow!',
              onPressed: _playMeowSound, // Replace this with the actual Meow function
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Meow!',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFFBA76),
            ),
          ),
        ],
      ),
      const SizedBox(width: 24),

      Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Color(0xFFFFBA76),
              shape: BoxShape.circle,
              
            ),
            child: IconButton(
              iconSize: 36,
              icon: const Icon(Icons.volume_up, color: Colors.white),
              tooltip: 'Toy!',
              onPressed: _playSqueakSound, // Replace this with the actual Meow function
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Toy!',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFFBA76),
            ),
          ),
        ],
      ),
    ],
  ),
),

  

    ],
  ),
),

      
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        currentIndex: currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: Color.fromARGB(255, 250, 144, 39),
        unselectedItemColor: Color(0xFFFFBA76),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(FontAwesomeIcons.bone), label: 'Feed'),
          BottomNavigationBarItem(icon: Row(
  mainAxisSize: MainAxisSize.min,
  children: const [
    Icon(FontAwesomeIcons.cat),
    SizedBox(width: 4),
   Icon(FontAwesomeIcons.dove),
  ],
), label: 'Groups'),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'Camera'),
          BottomNavigationBarItem(icon:Icon(FontAwesomeIcons.dog), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(FontAwesomeIcons.solidMessage), label: 'Message'),
        ],
      ),

      bottomSheet: Container(
        color: Color.fromARGB(255, 255, 255, 255),
  padding: const EdgeInsets.only(bottom: 30),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      // Gallery Button
      FloatingActionButton(
        heroTag: 'gallery',
        backgroundColor: Color(0xFFFFBA76),
        elevation: 0,
        onPressed: _pickImageFromGallery,
        child: const Icon(Icons.photo_library, color: Color.fromARGB(255, 255, 255, 255)),
      ),

      // Take Picture Button
      GestureDetector(
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
            border: Border.all(color: Color(0xFFFFBA76), width: 7),
            color: Colors.transparent,
          ),
          child: const Center(
            child: Icon(
              Icons.pets_rounded,
              size: 40,
              color: Color(0xFFFFBA76),
            ),
          ),
        ),
      ),

      // Flip Camera Button
      FloatingActionButton(
        heroTag: 'flip',
        backgroundColor: const Color(0xFFFFBA76),
        elevation: 0,
        onPressed: _flipCamera,
        child: const Icon(Icons.flip_camera_ios, color: Color.fromARGB(255, 255, 255, 255)),
      ),
      
    ],
  ),
),




      
    );
  }
}
