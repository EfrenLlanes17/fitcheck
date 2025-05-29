import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fitcheck/pages/diffrentuserpage.dart'; // Add this import

class FollowingPage extends StatelessWidget {
  final String username;

  const FollowingPage({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    final databaseRef = FirebaseDatabase.instance.ref();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Following'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: FutureBuilder<DataSnapshot>(
        future: databaseRef.child('users/$username/following').get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.value == null) {
            return const Center(
              child: Text('Not following anyone yet.', style: TextStyle(color: Colors.white70)),
            );
          }

          final followingMap = Map<String, dynamic>.from(snapshot.data!.value as Map);

          return ListView.builder(
            itemCount: followingMap.length,
            itemBuilder: (context, index) {
              final followingUsername = followingMap.keys.elementAt(index);
              final followingData = Map<String, dynamic>.from(followingMap[followingUsername]);
              final profileUrl = followingData['profilepicture'] ?? '';

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(profileUrl),
                  backgroundColor: Colors.grey[800],
                ),
                title: Text(
                  followingUsername,
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => diffrentProfilePage(
                        username: followingUsername,
                        usernameOfLoggedInUser: username,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
