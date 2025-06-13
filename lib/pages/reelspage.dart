
 import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fitcheck/pages/profile_page.dart';


class VideoPostWidget extends StatefulWidget {
  final String videoPath;

  const VideoPostWidget({super.key, required this.videoPath});

  @override
  _VideoPostWidgetState createState() => _VideoPostWidgetState();
}

class _VideoPostWidgetState extends State<VideoPostWidget> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  final TextEditingController _descriptionController = TextEditingController();
  final DatabaseReference databaseRef = FirebaseDatabase.instance.ref();
 String _currentUsername = '';
   String _currentanimal = '';

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.contentUri(Uri.parse(widget.videoPath));
    _initializeVideoPlayerFuture = _controller.initialize();
    _controller.setLooping(true);
    _controller.setVolume(1.0);
    _loadUserData();
  }

  @override
  void dispose() {
    _controller.dispose();
    _descriptionController.dispose();
    super.dispose();
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


 Future<void> uploadVideoAndSaveUrl(String videoPath) async {
  try {
    final file = File(videoPath);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('user_videos/$_currentUsername/$timestamp.mp4');

    final uploadTask = storageRef.putFile(
      file,
      SettableMetadata(contentType: 'video/mp4'),
    );
    await uploadTask.whenComplete(() => null);
    final downloadUrl = await storageRef.getDownloadURL();

    final databaseRef = FirebaseDatabase.instance.ref();
    DatabaseReference newVideoRef = databaseRef.child('videos').push();
    String pushedKey = newVideoRef.key!;

    await newVideoRef.set({
      'url': downloadUrl,
      'timestamp': DateTime.now().toIso8601String(),
      'user': _currentUsername,
      'animal': _currentanimal,
      'likes': 0,
      'caption': _descriptionController.text,
      'saves': 0,
      'profilepicture':
          'https://firebasestorage.googleapis.com/v0/b/fitcheck-e648e.firebasestorage.app/o/profile_pictures%2F${_currentUsername}_$_currentanimal.jpg?alt=media',
    });

    // await databaseRef
    //     .child('users/$_currentUsername/pets/$_currentanimal/pictures/$pushedKey')
    //     .set({
    //   'url': downloadUrl,
    //   'timestamp': DateTime.now().toIso8601String(),
    // });

  } catch (e) {
    print('Error uploading video: $e');
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: FutureBuilder(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return  Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [
    // VIDEO PREVIEW
    SizedBox(
      height: MediaQuery.of(context).size.height * 0.75, // shorter video
      child: Stack(
        alignment: Alignment.center,
        children: [
          VideoPlayer(_controller),
          if (!_controller.value.isPlaying)
            IconButton(
              iconSize: 64,
              icon: const Icon(Icons.play_circle_fill, color: Colors.white),
              onPressed: () => setState(() => _controller.play()),
            ),
        ],
      ),
    ),

    


  ],
);

              
           
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
