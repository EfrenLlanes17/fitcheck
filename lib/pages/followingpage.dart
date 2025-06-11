import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fitcheck/pages/diffrentuserpage.dart'; // Add this import
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fitcheck/pages/profile_page.dart';




class FollowingPage extends StatefulWidget {
  final String username;
  const FollowingPage({super.key,  required this.username});

  @override
  State<FollowingPage> createState() => _FollowingPage();
}

class _FollowingPage extends State<FollowingPage> {
   late String username;
   String _currentloggedInUsername = '';

  @override
  void initState() {
    super.initState();
    username = widget.username; // ✅ Proper use
    
    _loadUserData();
  }

  void _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUsername = prefs.getString('username');
    
    if (savedUsername != null) {
      setState(() {
        _currentloggedInUsername = savedUsername;
  
      });
      
    }
  }

  @override
  Widget build(BuildContext context) {
    final databaseRef = FirebaseDatabase.instance.ref();

    return Scaffold(
      appBar: AppBar(
  title: const Text(
    'Following',
    style: TextStyle(color: Color(0xFFFFBA76)), // Change text color here
  ),
  backgroundColor: Colors.white,
  iconTheme: const IconThemeData(color: Color(0xFFFFBA76)), // Also changes back button/icon color
),

      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: FutureBuilder<DataSnapshot>(
        future: databaseRef.child('users/$username/following').get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.value == null) {
            return const Center(
              child: Text('Not following anyone yet.', style: TextStyle(color: Color(0xFFFFBA76))),
            );
          }

          final followingMap = Map<String, dynamic>.from(snapshot.data!.value as Map);

          return ListView.builder(
            itemCount: followingMap.length,
            itemBuilder: (context, index) {
              final followingUsername = followingMap.keys.elementAt(index);
              final followingData = Map<String, dynamic>.from(followingMap[followingUsername]);
              final profileUrl = followingData['profilepicture'] ?? '';
              int indexOfUnderscore =followingUsername.indexOf('_');

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(profileUrl),
                  backgroundColor: Color(0xFFFFBA76),
                ),
                title: Text(
                  followingUsername,
                  style: const TextStyle(color: Color(0xFFFFBA76)),
                ),
                onTap: () {
              if (followingUsername != _currentloggedInUsername) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => diffrentProfilePage(
        username: followingUsername.substring(0,indexOfUnderscore),
        usernameOfLoggedInUser: _currentloggedInUsername,
        animal: followingUsername.substring(indexOfUnderscore+1),
      ),
    ),
  );
} else {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const ProfilePage(),
    ),
  );
}

            },
              );
            },
          );
        },
      ),
    );
  }
}
