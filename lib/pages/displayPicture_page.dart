import 'package:flutter/material.dart';
import 'package:fitcheck/pages/groups_page.dart';
import 'package:fitcheck/pages/picture_page.dart';
import 'package:fitcheck/pages/profile_page.dart';
import 'package:fitcheck/main.dart'; // for cameras
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:fitcheck/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fitcheck/pages/VideoDemo.dart';

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
   String _currentanimal = '';

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


  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUsername = prefs.getString('username');
    
    if (savedUsername != null) {
      setState(() {
        _currentUsername = savedUsername;
  
      });
      
    }
    final savedAnimal = prefs.getString('animal');

    if (savedAnimal != null) {
      final snapshot = await databaseRef.child('users/$savedUsername/pets/$savedAnimal').get();
      if (snapshot.exists) {
        final userData = snapshot.value as Map;
        setState(() {
          _currentanimal = savedAnimal;
        });
      }
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
      'animal': _currentanimal,
      'likes': 0,
      'caption': _descriptionController.text,
      'saves' : 0,
      'profilepicture' : 'https://firebasestorage.googleapis.com/v0/b/fitcheck-e648e.firebasestorage.app/o/profile_pictures%2F${_currentUsername}_$_currentanimal.jpg?alt=media'
      
    });



    await databaseRef.child('users/$_currentUsername/pets/$_currentanimal/pictures/$pushedKey').set({
      'url': downloadUrl,
      'timestamp': DateTime.now().toIso8601String(),
    });

    print('Image uploaded and URL saved!');
  } catch (e) {
    print('Error uploading image: $e');
  }
}


@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      iconTheme: const IconThemeData(color: Color(0xFFFFBA76)),
      title: const Text(
        'Retake',
        style: TextStyle(color: Color(0xFFFFBA76)),
      ),
      backgroundColor: Colors.white,
    ),
    body: Stack(
      children: [
        // Background image inside the body (not behind AppBar)
        
        // Foreground content
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Image.file(File(widget.imagePath)),
                const SizedBox(height: 50),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Add a caption...',
                    labelStyle: TextStyle(
                      color: Color(0xFFFFBA76),
                      fontSize: 18,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFFFBA76)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFFFBA76), width: 2.0),
                    ),
                  ),
                  style: const TextStyle(
                    color: Color(0xFFFFBA76),
                    fontSize: 18,
                  ),
                  maxLines: null,
                  cursorColor: Color(0xFFFFBA76),
                ),
                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [

                    Expanded(
  child: ElevatedButton.icon(
    label: const Text(
      'Post',
      style: TextStyle(color: Colors.white),
    ),
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFFFBA76), // Button background
      padding: const EdgeInsets.symmetric(vertical: 20), // Button height
      textStyle: const TextStyle(fontSize: 22), // Text size
    ),
    onPressed: () async {
      _updateLoginStreak();
      await uploadImageAndSaveUrl(widget.imagePath);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ProfilePage(),
        ),
      );
      
      
    },
  ),
),


                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}


}
