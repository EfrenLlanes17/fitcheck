import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fitcheck/pages/freinds_page.dart';
import 'package:fitcheck/pages/picture_page.dart';
import 'package:fitcheck/pages/profile_page.dart';
import 'package:fitcheck/pages/search_page.dart';
import 'package:fitcheck/main.dart'; // For `cameras`
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fitcheck/pages/commentinputfeild.dart';




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
  String _currentUsername = '';

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

   void initState() {
    super.initState();
    
    _loadUserData();
  }

  void _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUsername = prefs.getString('username');
    
    if (savedUsername != null) {
      setState(() {
        _currentUsername = savedUsername;
  
      });
      
    }
  }

 Future<void> shareImageFromUrl(String imageUrl) async {
  try {
    // Download the image
    final response = await http.get(Uri.parse(imageUrl));
    final bytes = response.bodyBytes;

    // Get temporary directory
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/shared_image.jpg');

    // Save image to file
    await file.writeAsBytes(bytes);

    // Share the image with text
    final xFile = XFile(file.path);

    await Share.shareXFiles(
      [xFile],
      text: 'Check out this picture from FitCheck!',
      subject: 'Shared from FitCheck',
    );
  } catch (e) {
    debugPrint('Error sharing image: $e');
  }
}

Future<int> _getUserStreak() async {
  final snapshot = await FirebaseDatabase.instance
      .ref('users/$_currentUsername/streak')
      .get();

  if (snapshot.exists && snapshot.value != null) {
    return int.tryParse(snapshot.value.toString()) ?? 0;
  }
  return 0;
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
    appBar: AppBar(
  backgroundColor: Colors.black,
  elevation: 0,
  title: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24.0),
    child: Row(
      children: [
        const FaIcon(FontAwesomeIcons.shirt, color: Color(0xFFFF681F), size: 24),
        const SizedBox(width: 8),
        FutureBuilder<int>(
          future: _getUserStreak(),
          builder: (context, snapshot) {
            final streak = snapshot.data ?? 0;
            return Text(
              '$streak',
              style: const TextStyle(color: Color(0xFFFF681F), fontSize: 18),
            );
          },
        ),
        Expanded(
          child: Center(
            child: Text(
              'FITCHECK',
              style: TextStyle(
              fontFamily: 'Roboto', // Or any built-in font
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),

            ),
          ),
        ),
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.search, color: Colors.white, size: 24),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SearchPage()),
            );
          },
        ),
      ],
    ),
  ),
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



  // The following code updates the visual style of each post to match the UI file
// while keeping the full functionality of likes, saves, shares, comments, and follows.

// Updated version of pictureWidgets to reflect UI style with full backend functionality

final pictureWidgets = sortedEntries.map((entry) {
  final data = Map<String, dynamic>.from(entry.value);
  final imageUrl = data['url'] ?? '';
  final timestamp = data['timestamp'].toString();
  final caption = data['caption'] ?? '';
  final username = data['user'] ?? '';
  final profilePicUrl = data['profilepicture'] ?? '';
  final postKey = entry.key;
  int likes = int.tryParse(data['likes'].toString()) ?? 0;

  return FutureBuilder<DataSnapshot>(
    future: FirebaseDatabase.instance.ref('pictures/$postKey/likedBy/$_currentUsername').get(),
    builder: (context, likeSnapshot) {
      bool isLiked = likeSnapshot.data?.value == true;

      return FutureBuilder<DataSnapshot>(
        future: FirebaseDatabase.instance.ref('pictures/$postKey/savedBy/$_currentUsername').get(),
        builder: (context, saveSnapshot) {
          bool isSaved = saveSnapshot.data?.value == true;
          bool showComments = false;
          return StatefulBuilder(
            builder: (context, setState) {
              

              return Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF181818),
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: profilePicUrl.isNotEmpty ? NetworkImage(profilePicUrl) : null,
                          backgroundColor: Colors.grey[700],
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '$username    ',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: '• ${timestamp.substring(0, 10)}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (username != _currentUsername)
                          FutureBuilder<DataSnapshot>(
                            future: FirebaseDatabase.instance.ref('users/$_currentUsername/following/$username').get(),
                            builder: (context, followSnapshot) {
                              bool isFollowing = followSnapshot.data?.hasChild('profilepicture') == true;

                              return TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: const Color(0xFF434343),
                                  padding: const EdgeInsets.symmetric(horizontal: 14),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: () async {
                                  final followingRef = FirebaseDatabase.instance
                                      .ref('users/$_currentUsername/following/$username');
                                  final followersRef = FirebaseDatabase.instance
                                      .ref('users/$username/followers/$_currentUsername');

                                  if (isFollowing) {
                                    await followingRef.remove();
                                    await followersRef.remove();
                                  } else {
                                    await followingRef.set({'profilepicture' : 'https://firebasestorage.googleapis.com/v0/b/fitcheck-e648e.firebasestorage.app/o/profile_pictures%2F$username.jpg?alt=media'});
                                    await followersRef.set({'profilepicture' : 'https://firebasestorage.googleapis.com/v0/b/fitcheck-e648e.firebasestorage.app/o/profile_pictures%2F$_currentUsername.jpg?alt=media'});
                                  }

                                  setState(() {});
                                },
                                child: Text(
                                  isFollowing ? 'Following' : 'Follow',
                                  style: const TextStyle(color: Colors.white, fontSize: 14),
                                ),
                              );
                            },
                          ),
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
                                        leading: const Icon(Icons.info),
                                        title: const Text('Option 1'),
                                        onTap: () => Navigator.pop(context),
                                      ),
                                      ListTile(
                                        leading: const Icon(Icons.delete),
                                        title: const Text('Option 2'),
                                        onTap: () => Navigator.pop(context),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        imageUrl,
                        width: MediaQuery.of(context).size.width * 0.95,
                        height: 400,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        caption,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                          icon: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color: isLiked ? Colors.red : Colors.white,
                          ),
                          onPressed: () async {
                            final ref = FirebaseDatabase.instance.ref();
                            final postRef = ref.child('pictures/$postKey');
                            final userLikesRef = ref.child('users/$_currentUsername/likedpictures');

                            if (isLiked) {
                              likes--;
                              await postRef.child('likes').set(likes);
                              await postRef.child('likedBy/$_currentUsername').remove();
                              await userLikesRef.remove();
                            } else {
                              likes++;
                              await postRef.child('likes').set(likes);
                              await postRef.child('likedBy/$_currentUsername').set(true);
                              await userLikesRef.push().set({'url': imageUrl});
                            }

                            setState(() {
                              isLiked = !isLiked;
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            isSaved ? Icons.bookmark : Icons.bookmark_border,
                            color: isSaved ? Colors.blue : Colors.white,
                          ),
                          onPressed: () async {
                            final ref = FirebaseDatabase.instance.ref();
                            final postRef = ref.child('pictures/$postKey');
                            final userSavesRef = ref.child('users/$_currentUsername/savedpictures');

                            if (isSaved) {
                              await postRef.child('saves').runTransaction((value) {
                                final current = (value ?? 0) as int;
                                return Transaction.success(current > 0 ? current - 1 : 0);
                              });
                              await postRef.child('savedBy/$_currentUsername').remove();
                              await userSavesRef.remove();
                            } else {
                              await postRef.child('saves').runTransaction((value) {
                                final current = (value ?? 0) as int;
                                return Transaction.success(current + 1);
                              });
                              await postRef.child('savedBy/$_currentUsername').set(true);
                              await userSavesRef.push().set({'url': imageUrl});
                            }

                            setState(() {
                              isSaved = !isSaved;
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.share, color: Colors.white),
                          onPressed: () => shareImageFromUrl(imageUrl),
                        ),
                        IconButton(
                          icon: const Icon(Icons.comment, color: Colors.white),
                          onPressed: () => setState(() => showComments = !showComments),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '$likes',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          const TextSpan(
                            text: ' likes',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    if (showComments) ...[
                      const Divider(color: Colors.white24),
                      StreamBuilder<DatabaseEvent>(
                        stream: FirebaseDatabase.instance.ref('pictures/$postKey/comments').onValue,
                        builder: (context, snapshot) {
                          final data = snapshot.data?.snapshot.value as Map<dynamic, dynamic>? ?? {};
                          final commentList = data.entries.toList()
                            ..sort((a, b) => b.value['timestamp'].compareTo(a.value['timestamp']));

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...commentList.map((entry) {
                                final comment = entry.value as Map<dynamic, dynamic>;
                                final user = comment['user'] ?? 'Unknown';
                                final text = comment['text'] ?? '';
                                final ts = DateTime.fromMillisecondsSinceEpoch(comment['timestamp'] ?? 0);
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Text(
                                    '$user: $text\n${ts.toLocal()}',
                                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                                  ),
                                );
                              }),
                              const SizedBox(height: 8),
                              CommentInputField(postKey: postKey, currentUser: _currentUsername),
                            ],
                          );
                        },
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      );
    },
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
