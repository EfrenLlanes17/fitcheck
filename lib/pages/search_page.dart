import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fitcheck/pages/freinds_page.dart';
import 'package:fitcheck/pages/picture_page.dart';
import 'package:fitcheck/pages/profile_page.dart';
import 'package:fitcheck/pages/home_page.dart';
import 'package:fitcheck/main.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  int currentIndex = 0;
  String searchQuery = '';

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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: TextField(
            onChanged: (value) {
              setState(() {
                searchQuery = value.trim().toLowerCase();
              });
            },
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Search users or posts',
              hintStyle: TextStyle(color: Colors.white54),
              border: InputBorder.none,
            ),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.person), text: 'Users'),
              Tab(icon: Icon(Icons.image), text: 'Posts'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // USERS TAB
            FutureBuilder<DataSnapshot>(
              future: FirebaseDatabase.instance.ref('users').get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.value == null) {
                  return const Center(child: Text('No users found', style: TextStyle(color: Colors.white70)));
                }

                final userMap = Map<String, dynamic>.from(snapshot.data!.value as Map);
                final filteredUsers = userMap.entries.where((entry) {
                  final username = entry.key.toLowerCase();
                  return username.contains(searchQuery);
                }).toList();

                return ListView.builder(
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final username = filteredUsers[index].key;
                    return ListTile(
                      title: Text(username, style: const TextStyle(color: Colors.white)),
                      onTap: () {
                        // You can navigate to their profile or show a dialog
                      },
                    );
                  },
                );
              },
            ),

            // POSTS TAB
            FutureBuilder<DataSnapshot>(
              future: FirebaseDatabase.instance.ref('pictures').get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.value == null) {
                  return const Center(child: Text('No posts found', style: TextStyle(color: Colors.white70)));
                }

                final postMap = Map<String, dynamic>.from(snapshot.data!.value as Map);
                final filteredPosts = postMap.entries.where((entry) {
                  final data = Map<String, dynamic>.from(entry.value);
                  final caption = (data['caption'] ?? '').toString().toLowerCase();
                  return caption.contains(searchQuery);
                }).toList();

                return GridView.count(
                  crossAxisCount: 3,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                  childAspectRatio: 1,
                  padding: const EdgeInsets.all(8),
                  children: filteredPosts.map((entry) {
                    final data = Map<String, dynamic>.from(entry.value);
                    final url = data['url'] ?? '';
                    return Image.network(url, fit: BoxFit.cover);
                  }).toList(),
                );
              },
            ),
          ],
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
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.people_alt_outlined), label: 'Friends'),
            BottomNavigationBarItem(icon: Icon(Icons.camera_alt_outlined), label: 'FitCheck'),
            BottomNavigationBarItem(icon: Icon(Icons.person_2_outlined), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
