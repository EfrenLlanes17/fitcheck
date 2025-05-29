import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fitcheck/pages/freinds_page.dart';
import 'package:fitcheck/pages/picture_page.dart';
import 'package:fitcheck/pages/home_page.dart';
import 'package:fitcheck/main.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fitcheck/pages/termsofservice.dart';
import 'package:fitcheck/pages/privacypolicy.dart';
import 'package:fitcheck/pages/followerspage.dart';
import 'package:fitcheck/pages/followingpage.dart';
import 'package:fitcheck/pages/profile_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


class diffrentProfilePage extends StatefulWidget {
  final String username;
  final String usernameOfLoggedInUser;
  const diffrentProfilePage({super.key, required this.username, required this.usernameOfLoggedInUser});

  @override
  State<diffrentProfilePage> createState() => _DiffrentProfilePageState();
}

class _DiffrentProfilePageState extends State<diffrentProfilePage> with SingleTickerProviderStateMixin {
  int currentIndex = 3;
  String _currentUsername = '';
  String usernameOfLoggedInUser = "";
  late TabController _tabController;

  bool _isEditingBio = false;
final TextEditingController _bioController = TextEditingController();

  final TextEditingController _signInUsernameController = TextEditingController();
  final TextEditingController _signInPasswordController = TextEditingController();
  final TextEditingController _createUsernameController = TextEditingController();
  final TextEditingController _createPasswordController = TextEditingController();

  final DatabaseReference databaseRef = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
     _currentUsername = widget.username;
     usernameOfLoggedInUser = widget.usernameOfLoggedInUser;
  }

  void showReportBottomSheet(BuildContext context) {
  final TextEditingController reportController = TextEditingController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Report User',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Please let us know why you are reporting this user:',
            ),
            const SizedBox(height: 10),
            TextField(
              controller: reportController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Enter your report here...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () async {
                  final reportText = reportController.text.trim();
                  if (reportText.isNotEmpty) {
                    await databaseRef.child('userreports').push().set({
      'text': reportText, 'reporter' : usernameOfLoggedInUser, 'reported' : _currentUsername
      
    });
                    Navigator.pop(context);
                  }
                },
                child: const Text('Send'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      );
    },
  );
}

  void _onTabTapped(int index) {
    if (index == currentIndex) return;

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
  void dispose() {
    _tabController.dispose();
    _signInUsernameController.dispose();
    _signInPasswordController.dispose();
    _createUsernameController.dispose();
    _createPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
  backgroundColor: Colors.black,
  title: true
      ? Text(
          _currentUsername,
          style: const TextStyle(
            fontFamily: 'Roboto',
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        )
      : null,
  centerTitle: true, // Important: center the title on both iOS and Android
  
  actions: true
      ? [
          IconButton(
  icon: const Icon(Icons.more_vert, color: Colors.white),
  onPressed: () async {
    await showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              
              ListTile(
                leading: const Icon(Icons.flag),
                title: const Text('Report User'),
                onTap: () {
                  Navigator.pop(context);
                  showReportBottomSheet(context);
                },
              ),

            ],
          ),
        );
      },
    );
  },
)

        ]
      : [],
),

      body: true
    ? FutureBuilder<DataSnapshot>(
        future: databaseRef.child('users/$_currentUsername/profilepicture').get(),
        builder: (context, profileSnapshot) {
          String profileUrl = 'https://th.bing.com/th/id/OIP.VvvX4Ug_y6j3qz2l5aJIMAAAAA?w=169&h=169&c=7&r=0&o=5&cb=iwc2&dpr=1.3&pid=1.7';
          if (profileSnapshot.hasData &&
              profileSnapshot.data!.value != null &&
              profileSnapshot.data!.value.toString().isNotEmpty) {
            profileUrl = profileSnapshot.data!.value.toString();
          }

          return FutureBuilder<DataSnapshot>(
            future: databaseRef.child('users/$_currentUsername/pictures').get(),
            builder: (context, pictureSnapshot) {
              if (pictureSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              List<Widget> imageWidgets = [];

              if (pictureSnapshot.hasData && pictureSnapshot.data!.value != null) {
                final picturesMap = Map<String, dynamic>.from(pictureSnapshot.data!.value as Map);
                imageWidgets = picturesMap.entries.map((entry) {
                  final imageUrl = entry.value['url'] as String?;

                  if (imageUrl == null || imageUrl.isEmpty) return const SizedBox();

                  return Image.network(imageUrl, fit: BoxFit.cover);

                }).toList();
              }

              // New: FutureBuilder for followers count
              return FutureBuilder<DataSnapshot>(
                future: databaseRef.child('users/$_currentUsername/followers').get(),
                builder: (context, followersSnapshot) {
                  int followersCount = 0;
                  if (followersSnapshot.hasData && followersSnapshot.data!.value != null) {
                    final followersMap = Map<String, dynamic>.from(followersSnapshot.data!.value as Map);
                    followersCount = followersMap.length;
                  }

                  // New: FutureBuilder for following count
                  return FutureBuilder<DataSnapshot>(
                    future: databaseRef.child('users/$_currentUsername/following').get(),
                    builder: (context, followingSnapshot) {
                      int followingCount = 0;
                      if (followingSnapshot.hasData && followingSnapshot.data!.value != null) {
                        final followingMap = Map<String, dynamic>.from(followingSnapshot.data!.value as Map);
                        followingCount = followingMap.length;
                      }

                    return FutureBuilder<DataSnapshot>(
                    future: databaseRef.child('users/$_currentUsername/pictures').get(),
                    builder: (context, pictureSnapshot) {
                      int pictureCount = 0;
                      if (pictureSnapshot.hasData && pictureSnapshot.data!.value != null) {
                        final picturesMap = Map<String, dynamic>.from(pictureSnapshot.data!.value as Map);
                        pictureCount = picturesMap.length;
                      }  

                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
  mainAxisAlignment: MainAxisAlignment.center,
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    // Profile Picture

     
     Stack(
  children: [
    // Profile Picture
    CircleAvatar(
      radius: 90,
      backgroundImage: NetworkImage(profileUrl),
    ),

    

    // Orange T-shirt Icon with streak
    Positioned(
      bottom: -5,
      left: 0,
      child: FutureBuilder<DataSnapshot>(
        future: databaseRef.child('users/$_currentUsername/streak').get(),
        builder: (context, snapshot) {
          int streak = 0;
          if (snapshot.hasData && snapshot.data!.value != null) {
            streak = int.tryParse(snapshot.data!.value.toString()) ?? 0;
          }

          return Row(
            children: [
              const FaIcon(FontAwesomeIcons.shirt, color: Color(0xFFFF681F), size: 22),
              const SizedBox(width: 2),
              Text(
                '$streak',
                style: const TextStyle(
                  color: Color(0xFFFF681F),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          );
        },
      ),
    ),
  ],
),

   
    const SizedBox(width: 24), // space between picture and stats

    // Stats vertically stacked
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
            behavior: HitTestBehavior.opaque, // 👈 ensures the entire area responds to taps
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FollowersPage(username: _currentUsername),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$followersCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Followers',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),

          ],
        ),
        const SizedBox(height: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FollowingPage(username: _currentUsername),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$followingCount',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'Following',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    ),

          ],
        ),
        const SizedBox(height: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$pictureCount',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'Posts',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ],
    ),
  ],
),

                          
                              FutureBuilder<DataSnapshot>(
                              future: databaseRef.child('users/$_currentUsername/bio').get(),
                              builder: (context, bioSnapshot) {
                                if (bioSnapshot.connectionState == ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                }

                                String currentBio = '';
                                if (bioSnapshot.hasData && bioSnapshot.data!.value != null) {
                                  currentBio = bioSnapshot.data!.value.toString();
                                }

                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      currentBio.isEmpty ? 'no bio' : currentBio,
                                      style: TextStyle(
                                        color: currentBio.isEmpty ? Colors.white54 : Colors.white70,
                                        fontStyle: currentBio.isEmpty ? FontStyle.italic : FontStyle.normal,
                                        fontSize: 16,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                );
                              },
                            ),


                          if (usernameOfLoggedInUser != _currentUsername)
                        FutureBuilder<DataSnapshot>(
                          future: FirebaseDatabase.instance
                              .ref('users/$usernameOfLoggedInUser/following/$_currentUsername')
                              .get(),
                          builder: (context, followSnapshot) {
                            bool isFollowing =
                                followSnapshot.data?.hasChild('profilepicture') == true;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: const Color(0xFF434343),
                                  padding: const EdgeInsets.symmetric(horizontal: 14),
                                  shape:
                                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: () async {
                                  final followingRef = FirebaseDatabase.instance
                                      .ref('users/$usernameOfLoggedInUser/following/$_currentUsername');
                                  final followersRef = FirebaseDatabase.instance
                                      .ref('users/$_currentUsername/followers/$usernameOfLoggedInUser');

                                  if (isFollowing) {
                                    await followingRef.remove();
                                    await followersRef.remove();
                                  } else {
                                    await followingRef.set({
                                      'profilepicture':
                                          'https://firebasestorage.googleapis.com/v0/b/fitcheck-e648e.firebasestorage.app/o/profile_pictures%2F$_currentUsername.jpg?alt=media'
                                    });
                                    await followersRef.set({
                                      'profilepicture':
                                          'https://firebasestorage.googleapis.com/v0/b/fitcheck-e648e.firebasestorage.app/o/profile_pictures%2F$usernameOfLoggedInUser.jpg?alt=media'
                                    });
                                  }

                                  setState(() {}); // Refresh button label
                                },
                                child: Text(
                                  isFollowing ? 'Following' : 'Follow',
                                  style: const TextStyle(color: Colors.white, fontSize: 14),
                                ),
                              ),
                            );
                          },
                        ),



                            const SizedBox(height: 20),
                            // TabController for switching views
                            DefaultTabController(
                              length: 3,
                              child: Column(
                                children: [
                                  const TabBar(
                                    indicatorColor: Colors.white,
                                    labelColor: Colors.white,
                                    unselectedLabelColor: Colors.white54,
                                    tabs: [
                                      Tab(icon: Icon(Icons.camera_alt)),   // Uploads
                                      Tab(icon: Icon(Icons.favorite)),     // Liked
                                      Tab(icon: Icon(Icons.bookmark)),     // Saved
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height, // Adjust height as needed
                                    child: TabBarView(
                                      children: [
                                        // --- UPLOADED PICTURES ---
                                        imageWidgets.isNotEmpty
                                            ? GridView.count(
                                                crossAxisCount: 3,
                                                shrinkWrap: true,
                                                physics: const NeverScrollableScrollPhysics(),
                                                crossAxisSpacing: 8,
                                                mainAxisSpacing: 8,
                                                childAspectRatio: 0.75,
                                                children: imageWidgets,
                                              )
                                            : const Center(
                                                child: Text(
                                                  'No pictures uploaded yet.',
                                                  style: TextStyle(color: Colors.white70),
                                                ),
                                              ),

                                        // --- LIKED PICTURES ---
                                        FutureBuilder<DataSnapshot>(
                                          future: databaseRef.child('users/$_currentUsername/likedpictures').get(),
                                          builder: (context, likedSnapshot) {
                                            if (likedSnapshot.connectionState == ConnectionState.waiting) {
                                              return const Center(child: CircularProgressIndicator());
                                            }

                                            List<Widget> likedImages = [];
                                            if (likedSnapshot.hasData && likedSnapshot.data!.value != null) {
                                              final likedMap = Map<String, dynamic>.from(likedSnapshot.data!.value as Map);
                                              likedImages = likedMap.entries.map((entry) {
                                                final url = entry.value['url'] as String?;
                                                if (url == null || url.isEmpty) return const SizedBox();
                                                return Image.network(url, fit: BoxFit.cover);
                                              }).toList();
                                            }

                                            return likedImages.isNotEmpty
                                                ? GridView.count(
                                                    crossAxisCount: 3,
                                                    crossAxisSpacing: 8,
                                                    mainAxisSpacing: 8,
                                                    childAspectRatio: 0.75,
                                                    children: likedImages,
                                                  )
                                                : const Center(
                                                    child: Text(
                                                      'No liked pictures.',
                                                      style: TextStyle(color: Colors.white70),
                                                    ),
                                                  );
                                          },
                                        ),

                                        // --- SAVED PICTURES ---
                                        FutureBuilder<DataSnapshot>(
                                          future: databaseRef.child('users/$_currentUsername/savedpictures').get(),
                                          builder: (context, savedSnapshot) {
                                            if (savedSnapshot.connectionState == ConnectionState.waiting) {
                                              return const Center(child: CircularProgressIndicator());
                                            }

                                            List<Widget> savedImages = [];
                                           if (savedSnapshot.hasData && savedSnapshot.data!.value != null) {
                                            final savedMap = Map<String, dynamic>.from(savedSnapshot.data!.value as Map);
                                            savedImages = savedMap.entries.map((entry) {
                                              final pictureData = Map<String, dynamic>.from(entry.value);
                                              final url = pictureData['url'] as String?;
                                              if (url == null || url.isEmpty) return const SizedBox();
                                              return Image.network(url, fit: BoxFit.cover);
                                            }).toList();
                                          }

                                            return savedImages.isNotEmpty
                                                ? GridView.count(
                                                    crossAxisCount: 3,
                                                    crossAxisSpacing: 8,
                                                    mainAxisSpacing: 8,
                                                    childAspectRatio: 0.75,
                                                    children: savedImages,
                                                  )
                                                : const Center(
                                                    child: Text(
                                                      'No saved pictures.',
                                                      style: TextStyle(color: Colors.white70),
                                                    ),
                                                  );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          ],
                        ),
                      );
                      },
                  );
                    },
                  );
                },
              );
            },
          );
        },
      )
     // your else part for not logged in users

          : Padding(
              padding: const EdgeInsets.all(24.0),
              
            ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        currentIndex: currentIndex,
        onTap: _onTabTapped,
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
    );
  }
}
