import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class FollowersPage extends StatelessWidget {
  final String username;

  const FollowersPage({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    final databaseRef = FirebaseDatabase.instance.ref();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Followers'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: FutureBuilder<DataSnapshot>(
        future: databaseRef.child('users/$username/followers').get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.value == null) {
            return const Center(
              child: Text('No followers yet.', style: TextStyle(color: Colors.white70)),
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
                  backgroundColor: Colors.grey[800],
                ),
                title: Text(
                  followerUsername,
                  style: const TextStyle(color: Colors.white),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
