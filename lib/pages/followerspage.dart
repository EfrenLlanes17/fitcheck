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
          final followerList = followersMap.keys.toList();

          return ListView.builder(
            itemCount: followerList.length,
            itemBuilder: (context, index) {
              final follower = followerList[index];
              return ListTile(
                title: Text(follower, style: const TextStyle(color: Colors.white)),
                leading: const Icon(Icons.person, color: Colors.white70),
              );
            },
          );
        },
      ),
    );
  }
}
