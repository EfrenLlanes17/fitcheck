import 'package:flutter/material.dart';
import 'package:fitcheck/pages/freinds_page.dart';
import 'package:fitcheck/pages/picture_page.dart';
import 'package:fitcheck/pages/profile_page.dart';
import 'package:fitcheck/main.dart'; // for cameras
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:fitcheck/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:firebase_storage/firebase_storage.dart';

class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;

  const DisplayPictureScreen({super.key, required this.imagePath});

  @override
  State<DisplayPictureScreen> createState() => _DisplayPictureScreenState();
}

 

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  final TextEditingController _descriptionController = TextEditingController();
 final DatabaseReference databaseRef = FirebaseDatabase.instance.ref();
 String _currentUsername = '';
  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

   @override
  void initState() {
    super.initState();
    
    _loadUserData();
  }

  Future<void> _updateLoginStreak() async {
  final ref = FirebaseDatabase.instance.ref();
  final userRef = ref.child('users/$_currentUsername');

  final snapshot = await userRef.get();

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  if (snapshot.exists) {
    final data = Map<String, dynamic>.from(snapshot.value as Map);
    final lastLoginRaw = data['lastLogin'];
    final streak = data['streak'] ?? 0;

    DateTime? lastLogin;
    if (lastLoginRaw != null) {
      if (lastLoginRaw is int) {
        lastLogin = DateTime.fromMillisecondsSinceEpoch(lastLoginRaw);
      } else if (lastLoginRaw is String) {
        lastLogin = DateTime.tryParse(lastLoginRaw);
      }
    }

    final lastLoginDate = lastLogin != null
        ? DateTime(lastLogin.year, lastLogin.month, lastLogin.day)
        : null;

    int newStreak = streak;

    if (lastLoginDate == null || today.difference(lastLoginDate).inDays > 1) {
      newStreak = 1;
    } else if (today.difference(lastLoginDate).inDays == 1) {
      newStreak += 1;
    }

    await userRef.update({
      'lastLogin': now.toIso8601String(),
      'streak': newStreak,
    });
  } else {
    // New user or no data
    await userRef.set({
      'lastLogin': now.toIso8601String(),
      'streak': 1,
    });
  }
}


  void _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUsername = prefs.getString('username');
    
    if (savedUsername != null) {
      setState(() {
        _currentUsername = savedUsername;
  
      });
      
    }
  }


  Future<void> uploadImageAndSaveUrl(String imagePath) async {
  try {
    final file = File(imagePath);
    final storageRef = FirebaseStorage.instance.ref().child('user_images/$_currentUsername/${DateTime.now().millisecondsSinceEpoch}.jpg');

   final uploadTask = storageRef.putFile(file,SettableMetadata());
   await uploadTask.whenComplete(() => null);
   final downloadUrl = await storageRef.getDownloadURL();


    final databaseRef = FirebaseDatabase.instance.ref();


    DatabaseReference newPicRef = databaseRef.child('pictures').push();
    String pushedKey = newPicRef.key!;

    // Step 2: Set full picture data under /pictures/{pushedKey}
    await newPicRef.set({
      'url': downloadUrl,
      'timestamp': DateTime.now().toIso8601String(),
      'user': _currentUsername,
      'likes': 0,
      'caption': _descriptionController.text,
      'saves' : 0,
      'profilepicture' : 'https://firebasestorage.googleapis.com/v0/b/fitcheck-e648e.firebasestorage.app/o/profile_pictures%2F$_currentUsername.jpg?alt=media'
      
    });



    await databaseRef.child('users/$_currentUsername/pictures/$pushedKey').set({
      'url': downloadUrl,
    });

    print('Image uploaded and URL saved!');
  } catch (e) {
    print('Error uploading image: $e');
  }
}

  // Future<void> _uploadPictureToDatabase(String imagePath) async {
  //   try {
  //     final file = File(imagePath);
  //     final bytes = await file.readAsBytes();
  //     final base64Image = base64Encode(bytes);
  //     final databaseRef = FirebaseDatabase.instance.ref();

  //     await databaseRef.child('users/$_currentUsername/pictures')
  //         .push()
  //         .set({
  //       'imageData': base64Image,
  //       'timestamp': DateTime.now().toIso8601String(),
  //     });

  //     print('Image uploaded to database successfully.');
  //   } catch (e) {
  //     print('Failed to upload image: $e');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Center(child: Image.file(File(widget.imagePath))),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Add a description...',
                border: OutlineInputBorder(),
              ),
              maxLines: null,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.camera_alt),
                label: const Text('Retake'),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PicturePage(camera: cameras.first),
                    ),
                  );
                },
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.check_circle),
                label: const Text('Post'),
                onPressed: () async {
                  final description = _descriptionController.text;
                  // You can pass this to ProfilePage or save it as needed
                   _loadUserData();
                  await _updateLoginStreak();
                  await uploadImageAndSaveUrl(widget.imagePath);
                   Navigator.pushReplacement(
                     context,
                     MaterialPageRoute(
                      builder: (context) => const ProfilePage(),
                     ),
                   );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
