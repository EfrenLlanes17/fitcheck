import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fitcheck/pages/diffrentuserpage.dart'; // <-- Make sure this import matches your file name
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fitcheck/pages/profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';


class FollowersPage extends StatefulWidget {
  final String username;
  final String animal;
  const FollowersPage({super.key, required this.username, required this.animal});

  @override
  State<FollowersPage> createState() => _FollowersPageState();
}

class _FollowersPageState extends State<FollowersPage> {
    late String username;
    late String animal;
    String _currentloggedInUsername = '';


   @override
  void initState() {
    super.initState();
    username = widget.username; // ✅ Proper use
    animal = widget.animal;
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
        iconTheme: const IconThemeData(color: Color(0xFFFFBA76)),
        title: const Text(
    'Followers',
    style: TextStyle(color: Color(0xFFFFBA76)), // Change text color here
  ),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: FutureBuilder<DataSnapshot>(
        future: databaseRef.child('users/$username/pets/$animal/followers').get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.value == null) {
            return const Center(
              child: Text('No followers yet.', style: TextStyle(color: Color(0xFFFFBA76))),
            );
          }

          final followersMap = Map<String, dynamic>.from(snapshot.data!.value as Map);

          return ListView.builder(
            itemCount: followersMap.length,
            itemBuilder: (context, index) {
              final followerUsername = followersMap.keys.elementAt(index);
              final followerData = Map<String, dynamic>.from(followersMap[followerUsername]);
              final profileUrl = followerData['profilepicture'] ?? '';

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(profileUrl),
                  backgroundColor: Color(0xFFFFBA76),
                ),
                title: Text(
                  followerUsername,
                  style: const TextStyle(color: Color(0xFFFFBA76)),
                ),
                 onTap: () {
              if (followerUsername != _currentloggedInUsername) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => diffrentProfilePage(
        username: followerUsername,
        usernameOfLoggedInUser: _currentloggedInUsername,
        animal: null,
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
