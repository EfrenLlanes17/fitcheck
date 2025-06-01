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
import 'package:fitcheck/pages/moresettings.dart';
import 'package:fitcheck/pages/startpage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fitcheck/pages/message_page.dart';




class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  int currentIndex = 3;
  String _currentUsername = '';
  late TabController _tabController;

  bool _isEditingBio = false;
final TextEditingController _bioController = TextEditingController();



  final DatabaseReference databaseRef = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserData();
  }

  Future<void> _pickAndUploadProfilePicture() async {
  final picker = ImagePicker();
  final pickedFile = await showModalBottomSheet<XFile?>(
    context: context,
    builder: (_) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Upload from gallery'),
              onTap: () async {
                final file = await picker.pickImage(source: ImageSource.gallery);
                Navigator.pop(context, file);
              },
            ),
          ],
        ),
      );
    },
  );

  if (pickedFile == null) return;

  final file = File(pickedFile.path);
  final storageRef = FirebaseStorage.instance
      .ref()
      .child('profile_pictures')
      .child('$_currentUsername.jpg');

  try {
    final metadata = SettableMetadata(contentType: 'image/jpeg');
    await storageRef.putFile(file, metadata);

    final downloadUrl = await storageRef.getDownloadURL();

    await databaseRef.child('users/$_currentUsername/profilepicture').set(downloadUrl);

    setState(() {}); // Reload profile picture
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile picture updated.')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to upload image: $e')),
    );
  }
}


  void _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUsername = prefs.getString('username');

    if (savedUsername != null) {
      final snapshot = await databaseRef.child('users/$savedUsername').get();
      if (snapshot.exists) {
        final userData = snapshot.value as Map;
        setState(() {
          _currentUsername = savedUsername;
        });
      }
    }
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
      case 4:
        page = const MessagePage();
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }



  void _signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');

    setState(() {
      _currentUsername = '';
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const StarterPage(),
      ),
    );

  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
  backgroundColor: Colors.white,
  title:  Text(
          _currentUsername,
          style: const TextStyle(
            fontFamily: 'Roboto',
            color: Color(0xFFFFBA76),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        )
      ,
  centerTitle: true, // Important: center the title on both iOS and Android
  actions:  [
          IconButton(
  icon: const Icon(Icons.settings, color: Color(0xFFFFBA76)),
  onPressed: () async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(FontAwesomeIcons.frog, color: Color(0xFFFFBA76)),
                title: const Text('Invite a Freind', style: TextStyle(color: Color(0xFFFFBA76))),
                onTap: () {
                  Navigator.pop(context); // Close the BottomSheet
                  
                },
              ),
              ListTile(
                leading: const Icon(Icons.description, color: Color(0xFFFFBA76)),
                title: const Text('Terms of Service', style: TextStyle(color: Color(0xFFFFBA76))),
                onTap: () {
                  Navigator.pop(context); // Close the BottomSheet
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TermsOfServicePage(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Color(0xFFFFBA76)),
                title: const Text('Sign Out', style: TextStyle(color: Color(0xFFFFBA76))),
                onTap: () {
                  Navigator.pop(context);
                  _signOut();
                },
              ),
              ListTile(
              leading: const Icon(Icons.privacy_tip, color: Color(0xFFFFBA76)),
              title: const Text('Privacy Policy', style: TextStyle(color: Color(0xFFFFBA76))),
              onTap: () {
                Navigator.pop(context); // Close modal
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PrivacyPolicyPage()),
                );
              },
            ),

            ListTile(
                leading: const Icon(Icons.settings_suggest_outlined, color: Color(0xFFFFBA76)),
                title: const Text('More Settings', style: TextStyle(color: Color(0xFFFFBA76))),
                onTap: () {
                  Navigator.pop(context); // Close the BottomSheet
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MoreSettingsPage(),
                    ),
                  );
                },
              ),

            ],
          ),
        );
      },
    );
  },
)

        ],
),

      body: FutureBuilder<DataSnapshot>(
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
    GestureDetector(
      onTap: _pickAndUploadProfilePicture,
      child: CircleAvatar(
        radius: 90,
        backgroundImage: NetworkImage(profileUrl),
      ),
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
                      color: Color(0xFFFFBA76),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Followers',
                    style: TextStyle(color: Color(0xFFFFBA76)),
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
                color: Color(0xFFFFBA76),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'Following',
              style: TextStyle(color: Color(0xFFFFBA76)),
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
                color: Color(0xFFFFBA76),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'Posts',
              style: TextStyle(color: Color(0xFFFFBA76)),
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

                                if (!_isEditingBio) {
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _isEditingBio = true;
                                        _bioController.text = currentBio;
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                                      child: Text(
                                        currentBio.isEmpty ? 'Tap to add a bio' : currentBio,
                                        style: TextStyle(
                                          color: currentBio.isEmpty ? Color(0xFFFFBA76) : Color(0xFFFFBA76),
                                          fontStyle: currentBio.isEmpty ? FontStyle.italic : FontStyle.normal,
                                          fontSize: 16,
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                  );
                                } else {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                                    child: TextField(
                                      controller: _bioController,
                                      autofocus: true,
                                      maxLines: null,
                                      style: const TextStyle(color: Colors.white),
                                      decoration: InputDecoration(
                                        hintText: 'Enter your bio',
                                        hintStyle: const TextStyle(color: Color(0xFFFFBA76)),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: Color(0xFFFFBA76)),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: Color(0xFFFFBA76)),
                                        ),
                                        suffixIcon: IconButton(
                                          icon: const Icon(Icons.check, color: Color(0xFFFFBA76)),
                                          onPressed: () async {
                                            final newBio = _bioController.text.trim();
                                            await databaseRef.child('users/$_currentUsername/bio').set(newBio);
                                            setState(() {
                                              _isEditingBio = false;
                                            });
                                          },
                                        ),
                                      ),
                                      onSubmitted: (value) async {
                                        final newBio = value.trim();
                                        await databaseRef.child('users/$_currentUsername/bio').set(newBio);
                                        setState(() {
                                          _isEditingBio = false;
                                        });
                                      },
                                    ),
                                  );
                                }
                              },
                            ),

                            const SizedBox(height: 20),
                            // TabController for switching views
                            DefaultTabController(
                              length: 3,
                              child: Column(
                                children: [
                                  const TabBar(
                                    labelColor: Color(0xFFFFBA76),
                                    unselectedLabelColor:Color.fromARGB(255, 231, 167, 102),
                                    indicatorColor: Color(0xFFFFBA76),
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
                                                  style: TextStyle(color: Color(0xFFFFBA76)),
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
                                                      style: TextStyle(color: Color(0xFFFFBA76)),
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
                                                      style: TextStyle(color: Color(0xFFFFBA76)),
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
      ),
     // your else part for not logged in users
  
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        currentIndex: currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: Color.fromARGB(255, 250, 144, 39),
        unselectedItemColor: Color(0xFFFFBA76),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Row(
  mainAxisSize: MainAxisSize.min,
  children: const [
    Icon(FontAwesomeIcons.cat),
    SizedBox(width: 4),
   Icon(FontAwesomeIcons.dove),
  ],
), label: 'Friends'),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'Camera'),
          BottomNavigationBarItem(icon:Icon(FontAwesomeIcons.dog), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Message'),
        ],
      ),
    );
  }
}
