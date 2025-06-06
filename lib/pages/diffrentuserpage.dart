import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fitcheck/pages/groups_page.dart';
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
import 'package:fitcheck/pages/postveiwer.dart';
import 'package:fitcheck/pages/usermessage_page.dart';
import 'package:fitcheck/pages/timelaps.dart';





class diffrentProfilePage extends StatefulWidget {
  final String username;
  final String usernameOfLoggedInUser;
  const diffrentProfilePage({super.key, required this.username, required this.usernameOfLoggedInUser});

  @override
  State<diffrentProfilePage> createState() => _DiffrentProfilePageState();
}

class _DiffrentProfilePageState extends State<diffrentProfilePage> with SingleTickerProviderStateMixin {
  String _currentUsername = '';
  String usernameOfLoggedInUser = "";
  late TabController _tabController;

  bool _isEditingBio = false;
final TextEditingController _bioController = TextEditingController();


  final DatabaseReference databaseRef = FirebaseDatabase.instance.ref();

 @override
void initState() {
  super.initState();

  _currentUsername = widget.username;
  usernameOfLoggedInUser = widget.usernameOfLoggedInUser;
  _tabController = TabController(length: 2, vsync: this);
}

void goToTimelapse(int selectedIndex) async {
  final databaseRef = FirebaseDatabase.instance.ref();
  final pictureSnapshot = await databaseRef.child('users/$_currentUsername/pictures').get();

  if (pictureSnapshot.exists && pictureSnapshot.value != null) {
    final picturesMap = Map<String, dynamic>.from(pictureSnapshot.value as Map);

    final sortedEntries = picturesMap.entries.toList()
      ..sort((a, b) {
        DateTime parseTimestamp(dynamic value) {
          if (value is int) {
            return DateTime.fromMillisecondsSinceEpoch(value);
          } else if (value is String) {
            try {
              return DateTime.parse(value);
            } catch (_) {
              return DateTime.fromMillisecondsSinceEpoch(int.tryParse(value) ?? 0);
            }
          }
          return DateTime.fromMillisecondsSinceEpoch(0);
        }

        final aData = Map<String, dynamic>.from(a.value);
        final bData = Map<String, dynamic>.from(b.value);
        final aTimestamp = parseTimestamp(aData['timestamp']);
        final bTimestamp = parseTimestamp(bData['timestamp']);

        return aTimestamp.compareTo(bTimestamp); // Oldest first
      });

    final postDataList = sortedEntries.map((entry) {
      final data = Map<String, dynamic>.from(entry.value);
      return {
        'imageUrl': data['url'] ?? '',
        'timestamp': data['timestamp'].toString(),
        'caption': data['caption'] ?? '',
        'username': data['user'] ?? '',
        'profilePicUrl': data['profilepicture'] ?? '',
        'postKey': entry.key,
      };
    }).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TimelapsPage(
          postDataList: postDataList,
          initialIndex: selectedIndex,
        ),
      ),
    );
  } else {
    debugPrint('No pictures found for user $_currentUsername.');
  }
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

  

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
  backgroundColor: const Color.fromARGB(255, 255, 255, 255),
  iconTheme: const IconThemeData(color: Color(0xFFFFBA76)),
  title: true
      ? Text(
          _currentUsername,
          style: const TextStyle(
            fontFamily: 'Roboto',
            color: Color(0xFFFFBA76),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        )
      : null,
  centerTitle: true, // Important: center the title on both iOS and Android
  
  actions: true
      ? [
        IconButton(
  icon: const Icon(FontAwesomeIcons.solidMessage),
  onPressed: () async {
    String chatId = "";
    final userChatsRef = FirebaseDatabase.instance.ref().child('users/$usernameOfLoggedInUser/chats');
    final userChatsSnapshot = await userChatsRef.get();

    if (userChatsSnapshot.exists) {
      final Map userChats = userChatsSnapshot.value as Map;

      for (var entry in userChats.entries) {
        final chatKey = entry.key;
        final participantsSnapshot = await FirebaseDatabase.instance
            .ref()
            .child('users/$usernameOfLoggedInUser/chats/$chatKey/participants')
            .get();

        if (participantsSnapshot.exists) {
          final participants = participantsSnapshot.value as Map;

          if (participants.length == 1 &&
              participants.containsKey(_currentUsername)) {
            chatId = chatKey;
            break;
          }
        }
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserMessagePage(
          username: _currentUsername,
          chatId: chatId,
        ),
      ),
    );
  },
),
IconButton(
  icon: const Icon(FontAwesomeIcons.solidClock, color: Color(0xFFFFBA76)),
  onPressed: () {
    
    goToTimelapse(0);
  },
),

          IconButton(
  icon: const Icon(Icons.more_vert, color: Color(0xFFFFBA76)),
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

              ListTile(
                leading: const Icon(Icons.block),
                title: const Text('Block User'),
                onTap: () {
                  Navigator.pop(context);
                 
                },
              ),

            ],
          ),
        );
      },
    );
  },
),


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
                imageWidgets = List.generate(sortedEntries.length, (index) {
        final entry = sortedEntries[index];
        final data = Map<String, dynamic>.from(entry.value);
        final imageUrl = data['url'] as String?;
        if (imageUrl == null || imageUrl.isEmpty) return const SizedBox();

        return GestureDetector(
          onTap: () {
            final postDataList = sortedEntries.map((entry) {
              final item = Map<String, dynamic>.from(entry.value);
              return {
                'imageUrl': item['url'] ?? '',
                'timestamp': item['timestamp'].toString(),
                'caption': item['caption'] ?? '',
                'username': item['user'] ?? '',
                'profilePicUrl': item['profilepicture'] ?? '',
                'postKey': entry.key,
              };
            }).toList();

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
          child: Image.network(imageUrl, fit: BoxFit.cover),
        );
      });
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
    Container(
      width: 180,
      height: 180,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: Image.network(
        profileUrl,
        fit: BoxFit.cover,
      ),
    ),

    // Shirt Icon and Streak Bottom-Left
    Positioned(
      bottom: 8,
      left: 8,
      child: FutureBuilder<DataSnapshot>(
        future: databaseRef.child('users/$_currentUsername/streak').get(),
        builder: (context, snapshot) {
          int streak = 0;
          if (snapshot.hasData && snapshot.data!.value != null) {
            streak = int.tryParse(snapshot.data!.value.toString()) ?? 0;
          }

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const FaIcon(
                  FontAwesomeIcons.paw,
                  color: Color(0xFFFFBA76),
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '$streak',
                  style: const TextStyle(
                    color: Color(0xFFFFBA76),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
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

                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      currentBio.isEmpty ? 'no bio' : currentBio,
                                      style: TextStyle(
                                        color: currentBio.isEmpty ? Color(0xFFFFBA76) : Color(0xFFFFBA76),
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

                            return Align(
  alignment: AlignmentDirectional(-1, -1),
  child: Padding(
    padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
    child: Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: SizedBox(
            height: 40,
            child: OutlinedButton(
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

                setState(() {});
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Color(0xFFFFBA76),
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFFFFBA76), width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                isFollowing ? 'Following' : 'Follow',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ),
        ),
      ],
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
                                              final sortedEntries = likedMap.entries.toList()
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
                                             likedImages = List.generate(sortedEntries.length, (index) {
        final entry = sortedEntries[index];
        final pictureData = Map<String, dynamic>.from(entry.value);
        final url = pictureData['url'] as String?;
        if (url == null || url.isEmpty) return const SizedBox();
                                                return GestureDetector(
          onTap: () {
            final postDataList = sortedEntries.map((entry) {
              final data = Map<String, dynamic>.from(entry.value);
              return {
                'imageUrl': data['url'] ?? '',
                'timestamp': data['timestamp'].toString(),
                'caption': data['caption'] ?? '',
                'username': data['user'] ?? '',
                'profilePicUrl': data['profilepicture'] ?? '',
                'postKey': entry.key,
              };
            }).toList();

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
                                            final sortedEntries = savedMap.entries.toList()
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
                                            savedImages = List.generate(sortedEntries.length, (index) {
  final entry = sortedEntries[index];
  final pictureData = Map<String, dynamic>.from(entry.value);
  final url = pictureData['url'] as String?;
  if (url == null || url.isEmpty) return const SizedBox();

  return GestureDetector(
    onTap: () {
      final postDataList = sortedEntries.map((entry) {
        final data = Map<String, dynamic>.from(entry.value);
        return {
          'imageUrl': data['url'] ?? '',
          'timestamp': data['timestamp'].toString(),
          'caption': data['caption'] ?? '',
          'username': data['user'] ?? '',
          'profilePicUrl': data['profilepicture'] ?? '',
          'postKey': entry.key,
        };
      }).toList();
      
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
});
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
      )
     // your else part for not logged in users

          : Padding(
              padding: const EdgeInsets.all(24.0),
              
            ),
      
    );
  }
}
