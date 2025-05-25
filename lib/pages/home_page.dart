import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fitcheck/pages/freinds_page.dart';
import 'package:fitcheck/pages/picture_page.dart';
import 'package:fitcheck/pages/profile_page.dart';
import 'package:fitcheck/pages/search_page.dart';
import 'package:fitcheck/main.dart'; // For `cameras`

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;

  void _onTabTapped(int index) {
    Widget page;
    switch (index) {
      case 0:
        page = const HomePage();
        break;
      case 1:
        page = const FreindsPage();
        break;
      case 2:
        page = PicturePage(camera: cameras.first);
        break;
      case 3:
        page = const ProfilePage();
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const SearchPage()),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<DataSnapshot>(
        future: FirebaseDatabase.instance.ref().child('pictures').get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.value == null) {
            return const Center(
              child: Text(
                'No pictures yet.',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          final picturesMap = Map<String, dynamic>.from(snapshot.data!.value as Map);

final sortedEntries = picturesMap.entries.toList()
  ..sort((a, b) {
    final aData = Map<String, dynamic>.from(a.value);
    final bData = Map<String, dynamic>.from(b.value);

    DateTime parseTimestamp(dynamic value) {
      if (value is int) {
        // If stored as milliseconds since epoch
        return DateTime.fromMillisecondsSinceEpoch(value);
      }
      if (value is String) {
        try {
          return DateTime.parse(value); // Works for ISO 8601
        } catch (_) {
          return DateTime.fromMillisecondsSinceEpoch(int.tryParse(value) ?? 0);
        }
      }
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    final aTimestamp = parseTimestamp(aData['timestamp']);
    final bTimestamp = parseTimestamp(bData['timestamp']);

    return bTimestamp.compareTo(aTimestamp); // Most recent first
  });



    final pictureWidgets = sortedEntries.map((entry) {
      final data = Map<String, dynamic>.from(entry.value);
      final imageUrl = data['url'] ?? '';
      final timestamp = data['timestamp'].toString();
      final caption = data['caption'] ?? '';
      final username = data['user'] ?? '';
      final likes = data['likes']?.toString() ?? '0';

      return Card(
        color: Colors.grey[900],
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(username, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Image.network(imageUrl),
              const SizedBox(height: 8),
              Text(caption, style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 4),
              Text('Likes: $likes', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              Text(timestamp, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
      );
    }).toList();

          return ListView(children: pictureWidgets);
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() => currentIndex = index);
          _onTabTapped(index);
        },
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_outlined),
            label: 'Friends',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt_outlined),
            label: 'FitCheck',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_2_outlined),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
