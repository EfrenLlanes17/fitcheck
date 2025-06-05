import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fitcheck/pages/groups_page.dart';
import 'package:fitcheck/pages/picture_page.dart';
import 'package:fitcheck/pages/home_page.dart';
import 'package:fitcheck/main.dart';
import 'package:fitcheck/pages/diffrentuserpage.dart'; // <-- Make sure this import matches your file name
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fitcheck/pages/profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fitcheck/pages/message_page.dart';


class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  int currentIndex = 0;
  String searchQuery = '';
  String _currentloggedInUsername = '';


   @override
  void initState() {
    super.initState();
    
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
  return DefaultTabController(
    length: 2,
    child: Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: PreferredSize(
  preferredSize: const Size.fromHeight(110),
  child: AppBar(
    backgroundColor: Colors.white,
    elevation: 0,
    automaticallyImplyLeading: false,
    titleSpacing: 0,
    title: Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFFFFBA76)),
            onPressed: () => Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: const Color.fromARGB(56, 172, 171, 171),
                borderRadius: BorderRadius.circular(32),
              ),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value.trim().toLowerCase();
                  });
                },
                style: const TextStyle(color: Color(0xFFFFBA76)),
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  hintStyle: TextStyle(color: Color.fromARGB(255, 231, 167, 102)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
    bottom: const TabBar(
      labelColor: Color(0xFFFFBA76),
      unselectedLabelColor: Color.fromARGB(255, 231, 167, 102),
      indicatorColor: Color(0xFFFFBA76),
      indicatorWeight: 2,
      tabs: [
        Tab(text: 'Accounts'),
        Tab(text: 'Posts'),
      ],
    ),
  ),
),

      body: Column(
        children: [
          // Search bar just below AppBar
          
          Expanded(
            child: TabBarView(
              children: [
                // ACCOUNTS TAB
                FutureBuilder<DataSnapshot>(
                  future: FirebaseDatabase.instance.ref('users').get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.value == null) {
                      return const Center(child: Text('No users found', style: TextStyle(color: Color(0xFFFFBA76))));
                    }

                    final userMap = Map<String, dynamic>.from(snapshot.data!.value as Map);
                    final filteredUsers = userMap.entries.where((entry) {
                      final username = entry.key.toLowerCase();
                      return username.contains(searchQuery);
                    }).toList();

                    if (filteredUsers.isEmpty) {
                      return const Center(
                        child: Text(
                          'No users found.',
                          style: TextStyle(color: Color(0xFFFFBA76), fontSize: 16),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: filteredUsers.length,
                      itemBuilder: (context, index) {
                        final username = filteredUsers[index].key;
                        final userData = Map<String, dynamic>.from(filteredUsers[index].value);
                        final profileUrl = userData['profilepicture'] ?? 'https://via.placeholder.com/150';

                        return FutureBuilder<DataSnapshot>(
                          future: FirebaseDatabase.instance.ref('users/$username/followers').get(),
                          builder: (context, followerSnapshot) {
                            int followerCount = 0;
                            if (followerSnapshot.hasData && followerSnapshot.data!.value != null) {
                              final followersMap = Map<String, dynamic>.from(followerSnapshot.data!.value as Map);
                              followerCount = followersMap.length;
                            }

                            return GestureDetector(
                              onTap: () {
                                if (username != _currentloggedInUsername) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => diffrentProfilePage(
                                        username: username,
                                        usernameOfLoggedInUser: _currentloggedInUsername,
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
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(profileUrl),
                                ),
                                title: Text(username, style: const TextStyle(color: Color(0xFFFFBA76))),
                                subtitle: Text(
                                  '$followerCount followers',
                                  style: const TextStyle(color: Color(0xFFFFBA76)),
                                ),
                              ),
                            );
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
                      return const Center(child: Text('No posts found', style: TextStyle(color: Color(0xFFFFBA76))));
                    }

                    final postMap = Map<String, dynamic>.from(snapshot.data!.value as Map);
                    final filteredPosts = postMap.entries.where((entry) {
                      final data = Map<String, dynamic>.from(entry.value);
                      final caption = (data['caption'] ?? '').toString().toLowerCase();
                      return caption.contains(searchQuery);
                    }).toList();

                    if (filteredPosts.isEmpty) {
                      return const Center(
                        child: Text(
                          'No Posts found.',
                          style: TextStyle(color: Color(0xFFFFBA76), fontSize: 16),
                        ),
                      );
                    }

                    return GridView.count(
                      crossAxisCount: 3,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                      childAspectRatio: 0.75,
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
          ),
        ],
      ),
    ),
  );
}

}
