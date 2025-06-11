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
import 'package:fitcheck/pages/postveiwer.dart';



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
  preferredSize: const Size.fromHeight(100),
  child: AppBar(
    backgroundColor: Colors.white,
    elevation: 0,
    automaticallyImplyLeading: false,
    titleSpacing: 0,
    title: Padding(
      padding: const EdgeInsets.only(top: 0.0),
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
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
    final List<Map<String, String>> petList = [];

    userMap.forEach((username, userDataRaw) {
      final userData = Map<String, dynamic>.from(userDataRaw);
      final pets = userData['pets'];

      if (pets != null && pets is Map) {
        pets.forEach((petName, petDataRaw) {
          final petData = Map<String, dynamic>.from(petDataRaw);
          final profilePic = petData['profilepicture'] ?? '';
          petList.add({
            'username': username,
            'petName': petName,
            'profilepicture': profilePic,
          });
        });
      }
    });

    final filteredPets = petList.where((entry) {
      final petName = entry['petName']!.toLowerCase();
      final user = entry['username']!.toLowerCase();
      return petName.contains(searchQuery) || user.contains(searchQuery);
    }).toList();

    if (filteredPets.isEmpty) {
      return const Center(
        child: Text('No pets found.', style: TextStyle(color: Color(0xFFFFBA76))),
      );
    }

    return ListView.builder(
      itemCount: filteredPets.length,
      itemBuilder: (context, index) {
        final entry = filteredPets[index];
        final username = entry['username']!;
        final petName = entry['petName']!;
        final profilePicUrl = entry['profilepicture']!.isNotEmpty
            ? entry['profilepicture']!
            : 'https://via.placeholder.com/150'; // Default pic

        return FutureBuilder<DataSnapshot>(
          future: FirebaseDatabase.instance
              .ref('users/$username/pets/$petName/followers')
              .get(),
          builder: (context, followerSnapshot) {
            int followerCount = 0;
            if (followerSnapshot.hasData && followerSnapshot.data!.value != null) {
              final followers = Map<String, dynamic>.from(followerSnapshot.data!.value as Map);
              followerCount = followers.length;
            }

            return ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(profilePicUrl),
                backgroundColor: const Color(0xFFFFBA76),
              ),
              title: Text(
                '$username ~ $petName',
                style: const TextStyle(color: Color(0xFFFFBA76)),
              ),
              subtitle: Text(
                '$followerCount followers',
                style: const TextStyle(color: Color(0xFFFFBA76)),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => diffrentProfilePage(
                      username: username,
                      usernameOfLoggedInUser: _currentloggedInUsername,
                      animal: petName,
                    ),
                  ),
                );
              },
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
  children: List.generate(filteredPosts.length, (index) {
    final entry = filteredPosts[index];
    final data = Map<String, dynamic>.from(entry.value);
    final url = data['url'] ?? '';
    if (url == null || url.isEmpty) return const SizedBox();

    // Build the list of posts for full-screen viewer
    final postDataList = filteredPosts.map((entry) {
      final post = Map<String, dynamic>.from(entry.value);
      return {
        'imageUrl': post['url'] ?? '',
        'timestamp': post['timestamp'].toString(),
        'caption': post['caption'] ?? '',
        'username': post['user'] ?? '',
        'profilePicUrl': post['profilepicture'] ?? '',
        'postKey': entry.key,
      };
    }).toList();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostViewerPage(
              postDataList: postDataList,
              initialIndex: index,
            ),
          ),
        );
      },
      child: Image.network(url, fit: BoxFit.cover),
    );
  }),
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
