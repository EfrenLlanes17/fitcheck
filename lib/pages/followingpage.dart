import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

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
          final followingList = followingMap.keys.toList();

          return ListView.builder(
            itemCount: followingList.length,
            itemBuilder: (context, index) {
              final followingUser = followingList[index];
              return ListTile(
                title: Text(followingUser, style: const TextStyle(color: Colors.white)),
                leading: const Icon(Icons.person_outline, color: Colors.white70),
              );
            },
          );
        },
      ),
    );
  }
}
