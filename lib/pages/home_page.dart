import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fitcheck/pages/reels_page.dart';
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
import 'package:fitcheck/pages/diffrentuserpage.dart';
import 'package:flutter/services.dart';
import 'package:fitcheck/pages/message_page.dart';
import 'package:fitcheck/pages/fullscreenimage.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:fitcheck/pages/group_page.dart';
import 'package:fitcheck/pages/competition.dart';
import 'package:lottie/lottie.dart';






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
    String _currentanimal = '';

  final DatabaseReference databaseRef = FirebaseDatabase.instance.ref();


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

   void initState() {
    super.initState();
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
    if (!isAllowed) {
      AwesomeNotifications().requestPermissionToSendNotifications();
    }

    AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: 1,
      channelKey: 'basic_channel',
      title: 'Daily Pet Pic!',
      body: 'Here is your daily dose of cuteness 🐶',
    ),
    schedule: NotificationCalendar(
      hour: 17,
      minute: 30,
      second: 0,
      repeats: true,
    ),
  );

  });
    
    _loadUserData();
  }

  String _getTimeAgo(DateTime postDate) {
  final now = DateTime.now();
  final difference = now.difference(postDate);

  if (difference.inSeconds < 60) {
    return '${difference.inSeconds}sec';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes}min';
  } else if (difference.inHours < 24) {
    return '${difference.inHours}hr';
  } else if (difference.inDays < 7) {
    return '${difference.inDays}d';
  } else if (difference.inDays < 30) {
    return '${(difference.inDays / 7).floor()}w';
  } else if (difference.inDays < 365) {
    return '${(difference.inDays / 30).floor()}m';
  } else {
    return '${(difference.inDays / 365).floor()}y';
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

    final savedAnimal = prefs.getString('animal');

    if (savedAnimal != null) {
      final snapshot = await databaseRef.child('users/$savedUsername/pets/$savedAnimal').get();
      if (snapshot.exists) {
        final userData = snapshot.value as Map;
        setState(() {
          _currentanimal = savedAnimal;
        });
      }
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

void showReportBottomSheet(BuildContext context, String postKey) {
  final TextEditingController reportController = TextEditingController();
  debugPrint('Trying to show notification...');


  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
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
              'Report Post',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFFFBA76)),
            ),
            const SizedBox(height: 10),
            const Text(
              'Please let us know why you are reporting this post:',  style: TextStyle(color: Color(0xFFFFBA76)),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: reportController,
              maxLines: 4,
              style: const TextStyle(color: Color(0xFFFFBA76)),
              decoration: const InputDecoration(
                hintText: 'Enter your report here...',
                hintStyle: TextStyle(color: Color(0xFFFFBA76)),
                border: OutlineInputBorder(),
                
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                 
                  backgroundColor: const Color(0xFFFFBA76), // Button background
                ),
                onPressed: () async {
                  final reportText = reportController.text.trim();
                  if (reportText.isNotEmpty) {
                    await databaseRef.child('postreports').push().set({
      'text': reportText, 'reporter' : _currentUsername, 'postreported' : postKey
      
    });
                    Navigator.pop(context);
                  }
                },
                child: const Text('Send', style: TextStyle(color: Color.fromARGB(255, 255, 255, 255))),
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
  Widget build(BuildContext context) {

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: Color.fromARGB(255, 255, 255, 255), // your desired color
    systemNavigationBarIconBrightness: Brightness.dark, // or Brightness.light depending on contrast
  ));
    return Scaffold(
      
    appBar: AppBar(
  automaticallyImplyLeading: false,
  backgroundColor: const Color.fromARGB(255, 255, 255, 255),
  elevation: 0,
  title: SizedBox(
    width: double.infinity,
    child: Stack(
      alignment: Alignment.center,
      children: [
        // Centered Title
        const Text(
          'PAWPRINT',
          style: TextStyle(
            fontFamily: 'Roboto',
            color: Color(0xFFFFBA76),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        // Left Section (Paw + Streak + Trophy)
        Align(
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const FaIcon(FontAwesomeIcons.paw, color: Color(0xFFFFBA76), size: 24),
              const SizedBox(width: 5),
              FutureBuilder<int>(
                future: _getUserStreak(),
                builder: (context, snapshot) {
  final streak = snapshot.data ?? 0;
  return Row(
    children: [
      Text(
        '$streak',
        style: const TextStyle(color: Color(0xFFFFBA76), fontSize: 18),
      ),
      const SizedBox(width: 10),
      GestureDetector(
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const CompetitionPage()),
          );
        },
        child: const FaIcon(
          FontAwesomeIcons.trophy,
          size: 24,
          color: Color(0xFFFFBA76),
        ),
      ),
    ],
  );
}

              ),
            ],
          ),
        ),
        // Right Section (Cat + Dove + Search)
        Align(
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(FontAwesomeIcons.cat, size: 20, color: Color(0xFFFFBA76)),
                    SizedBox(width: 2),
                    Icon(FontAwesomeIcons.dove, size: 20, color: Color(0xFFFFBA76)),
                  ],
                ),
                onPressed: () {
                  Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const GroupPage()),
          );
                },
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const FaIcon(FontAwesomeIcons.magnifyingGlass, size: 24, color: Color(0xFFFFBA76)),
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
      ],
    ),
  ),
),



 body:
 DefaultTabController(
  length: 2,
  child: Column(
    children: [
      const TabBar(
        labelColor: Color(0xFFFFBA76),
        unselectedLabelColor: Colors.grey,
        indicatorColor: Color(0xFFFFBA76),
        tabs: [
          Tab(text: 'Discover'),
          Tab(text: 'Following'),
        ],
      ),
      Expanded(
        child: TabBarView(
          children: [ Stack(
      children: [

        Positioned.fill(
      child: Image.asset(
        'assets/images/background.png', // ✅ Make sure it's declared in pubspec.yaml
        fit: BoxFit.cover,
      ),
    ),
        
        
    FutureBuilder<DataSnapshot>(
        future: FirebaseDatabase.instance.ref().child('pictures').get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox(
  width: 30,
  height: 30,
  child: Transform.scale(
    scale: 0.5, // adjust scale factor as needed
    child: Lottie.asset(
      'assets/animations/dogloader.json',
      repeat: true,
      fit: BoxFit.contain,
    ),
  ),
);
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
  final animal = data['animal'] ?? '';
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
                  color: const Color.fromARGB(255, 255, 255, 255),
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
  child: GestureDetector(
    onTap: () {
      if (username != _currentUsername) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => diffrentProfilePage(
              username: username,
              usernameOfLoggedInUser: _currentUsername,
              animal: animal,
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
    child: Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundImage:
              profilePicUrl.isNotEmpty ? NetworkImage(profilePicUrl) : null,
          backgroundColor: const Color(0xFFFFBA76),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           Text(
  '${animal[0].toUpperCase()}${animal.substring(1).toLowerCase()}',
  style: const TextStyle(
    color: Color(0xFFFFBA76),
    fontWeight: FontWeight.bold,
  ),
),

            const SizedBox(height: 2),
            Text(
              '@$username  ${_getTimeAgo(DateTime.parse(timestamp))}',
              style: const TextStyle(
                color: Color(0xFFFFBA76),
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      ],
    ),
  ),
),


                          
                        
                        if (username != _currentUsername)
                          FutureBuilder<DataSnapshot>(
                            future: FirebaseDatabase.instance.ref('users/$_currentUsername/following/${username}_$animal').get(),
                            builder: (context, followSnapshot) {
                              bool isFollowing = followSnapshot.data?.hasChild('profilepicture') == true;

                              return TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFBA76),
                                  padding: const EdgeInsets.symmetric(horizontal: 14),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: () async {
                                  final followingRef = FirebaseDatabase.instance
                                      .ref('users/$_currentUsername/following/${username}_$animal');
                                  final followersRef = FirebaseDatabase.instance
                                      .ref('users/$username/pets/$animal/followers/$_currentUsername');

                                  if (isFollowing) {
                                    await followingRef.remove();
                                    await followersRef.remove();
                                  } else {
                                    await followingRef.set({'profilepicture' : 'https://firebasestorage.googleapis.com/v0/b/fitcheck-e648e.firebasestorage.app/o/profile_pictures%2F${username}_$animal.jpg?alt=media'});
                                    await followersRef.set({'profilepicture' : 'https://firebasestorage.googleapis.com/v0/b/fitcheck-e648e.firebasestorage.app/o/profile_pictures%2F${username}_$_currentanimal.jpg?alt=media'});
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
                          icon: const Icon(Icons.more_vert, color: Color(0xFFFFBA76)),
                          onPressed: () async {
                            await showModalBottomSheet(
                              context: context,
                              builder: (_) {
                                return SafeArea(
                              child: Container(
                                color: Colors.white, // Background color of the bottom sheet
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    
                                    ListTile(
                                      leading: Icon(Icons.flag, color: Color(0xFFFFBA76)),
                                      title: Text('Report Post', style: TextStyle(color: Color(0xFFFFBA76))),
                                      onTap: () {
                                        Navigator.pop(context);
                                        showReportBottomSheet(context, postKey);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );

                              },
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullscreenImagePage(imageUrl: imageUrl),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        imageUrl,
                        width: MediaQuery.of(context).size.width * 0.95,
                        height: 500,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                        IconButton(
                          icon: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color: isLiked ? Colors.red : Color(0xFFFFBA76),
                          ),
                          onPressed: () async {
                            final ref = FirebaseDatabase.instance.ref();
                            final postRef = ref.child('pictures/$postKey');
                            final userLikesRef = ref.child('users/$_currentUsername/likedpictures');

                            if (isLiked) {
                              likes--;
                              await postRef.child('likes').set(likes);
                              await postRef.child('likedBy/$_currentUsername').remove();
                              await userLikesRef.child(postKey).remove();
                            } else {
                              likes++;
                              await postRef.child('likes').set(likes);
                              await postRef.child('likedBy/$_currentUsername').set(true);
                              await userLikesRef.child(postKey).set({'url': imageUrl, 'timestamp': DateTime.now().toIso8601String()});
                            }

                            setState(() {
                              isLiked = !isLiked;
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            isSaved ? Icons.bookmark : Icons.bookmark_border,
                            color: isSaved ? Colors.blue : Color(0xFFFFBA76),
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
                              await userSavesRef.child(postKey).remove();
                            } else {
                              await postRef.child('saves').runTransaction((value) {
                                final current = (value ?? 0) as int;
                                return Transaction.success(current + 1);
                              });
                              await postRef.child('savedBy/$_currentUsername').set(true);
                              await userSavesRef.child(postKey).set({'url': imageUrl, 'timestamp': DateTime.now().toIso8601String()});
                            }

                            setState(() {
                              isSaved = !isSaved;
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.chat_bubble_outline_outlined, color: Color(0xFFFFBA76)),
                          onPressed: () => setState(() => showComments = !showComments),
                        ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.share_outlined, color: Color(0xFFFFBA76)),
                          onPressed: () => shareImageFromUrl(imageUrl),
                        ),
                        
                      ],
                    ),
                    const SizedBox(height: 8),
                    Padding(
  padding: const EdgeInsets.only(left: 15),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$likes',
              style: const TextStyle(
                color: Color(0xFFFFBA76),
                fontWeight: FontWeight.bold,
              ),
            ),
            const TextSpan(
              text: ' likes',
              style: TextStyle(color: Color(0xFFFFBA76)),
            ),
          ],
        ),
      ),
      Text(
        caption,
        style: const TextStyle(
          color: Color(0xFFFFBA76),
          fontSize: 14,
        ),
      ),
    ],
  ),
),

                    const SizedBox(height: 12),
                    if (showComments) ...[
                      const Divider(color: Color(0xFFFFBA76)),
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
                                    
                                    '$user: $text\n${_getTimeAgo(ts.toLocal())}',
                                    style: const TextStyle(color: Color(0xFFFFBA76), fontSize: 13),
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
      ],
 ),
 Stack(
      children: [

        Positioned.fill(
      child: Image.asset(
        'assets/images/background.png', // ✅ Make sure it's declared in pubspec.yaml
        fit: BoxFit.cover,
      ),
    ),
        
        
    FutureBuilder<Map<String, dynamic>>(
  future: () async {
    // Step 1: Get following list
    final followingSnapshot = await FirebaseDatabase.instance
        .ref('users/$_currentUsername/following')
        .get();

    final followingMap = followingSnapshot.value as Map<dynamic, dynamic>? ?? {};
    final followingKeys = followingMap.keys.cast<String>().toSet(); // ex: {'user1_dog', 'user2_cat'}

    // Step 2: Get all pictures
    final picturesSnapshot =
        await FirebaseDatabase.instance.ref('pictures').get();
    final picturesMap =
        Map<String, dynamic>.from(picturesSnapshot.value as Map);

    // Step 3: Filter and sort
    final sortedEntries = picturesMap.entries.where((entry) {
      final data = Map<String, dynamic>.from(entry.value);
      final username = data['user'] ?? '';
      final animal = data['animal'] ?? '';
      return followingKeys.contains('${username}_$animal');
    }).toList()
      ..sort((a, b) {
        final aData = Map<String, dynamic>.from(a.value);
        final bData = Map<String, dynamic>.from(b.value);

        DateTime parseTimestamp(dynamic value) {
          if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
          if (value is String) {
            try {
              return DateTime.parse(value);
            } catch (_) {
              return DateTime.fromMillisecondsSinceEpoch(int.tryParse(value) ?? 0);
            }
          }
          return DateTime.fromMillisecondsSinceEpoch(0);
        }

        return parseTimestamp(bData['timestamp']).compareTo(parseTimestamp(aData['timestamp']));
      });

    return {
      'entries': sortedEntries,
    };
  }(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox(
  width: 30,
  height: 30,
  child: Transform.scale(
    scale: 0.5, // adjust scale factor as needed
    child: Lottie.asset(
      'assets/animations/dogloader.json',
      repeat: true,
      fit: BoxFit.contain,
    ),
  ),
);
          }

          if (!snapshot.hasData || snapshot.data!['entries'].isEmpty) {
      return const Center(
        child: Text(
          'No posts from followed users.',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

          final picturesMap = snapshot.data!['entries'] as List<MapEntry<String, dynamic>>;

final sortedEntries = picturesMap.toList()
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
  final animal = data['animal'] ?? '';
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
                  color: const Color.fromARGB(255, 255, 255, 255),
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      GestureDetector(
  onTap: () {
  if (username != _currentUsername) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => diffrentProfilePage(
          username: username,
          usernameOfLoggedInUser: _currentUsername,
          animal: animal,
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

  child: Row(
    children: [
      CircleAvatar(
        radius: 20,
        backgroundImage: profilePicUrl.isNotEmpty
            ? NetworkImage(profilePicUrl)
            : null,
        backgroundColor: Color(0xFFFFBA76),
      ),
      const SizedBox(width: 8),
      Text(
        animal + " ~ " + username,
        style: const TextStyle(
          color: Color(0xFFFFBA76),
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  ),
),

      const SizedBox(height: 2), // Optional spacing
      Text(
  '• ${_getTimeAgo(DateTime.parse(timestamp))}',
  style: const TextStyle(
    color: Color(0xFFFFBA76),
    fontWeight: FontWeight.w300,
  ),
),

    ],
  ),
),

                          
                        
                        if (username != _currentUsername)
                          FutureBuilder<DataSnapshot>(
                            future: FirebaseDatabase.instance.ref('users/$_currentUsername/following/${username}_$animal').get(),
                            builder: (context, followSnapshot) {
                              bool isFollowing = followSnapshot.data?.hasChild('profilepicture') == true;

                              return TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFBA76),
                                  padding: const EdgeInsets.symmetric(horizontal: 14),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: () async {
                                  final followingRef = FirebaseDatabase.instance
                                      .ref('users/$_currentUsername/following/${username}_$animal');
                                  final followersRef = FirebaseDatabase.instance
                                      .ref('users/$username/followers/$_currentUsername');

                                  if (isFollowing) {
                                    await followingRef.remove();
                                    await followersRef.remove();
                                  } else {
                                    await followingRef.set({'profilepicture' : 'https://firebasestorage.googleapis.com/v0/b/fitcheck-e648e.firebasestorage.app/o/profile_pictures%2F${username}_$animal.jpg?alt=media'});
                                    await followersRef.set({'profilepicture' : 'https://firebasestorage.googleapis.com/v0/b/fitcheck-e648e.firebasestorage.app/o/profile_pictures%2F${username}_$_currentanimal.jpg?alt=media'});
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
                          icon: const Icon(Icons.more_vert, color: Color(0xFFFFBA76)),
                          onPressed: () async {
                            await showModalBottomSheet(
                              context: context,
                              builder: (_) {
                                return SafeArea(
                              child: Container(
                                color: Colors.white, // Background color of the bottom sheet
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    
                                    ListTile(
                                      leading: Icon(Icons.flag, color: Color(0xFFFFBA76)),
                                      title: Text('Report Post', style: TextStyle(color: Color(0xFFFFBA76))),
                                      onTap: () {
                                        Navigator.pop(context);
                                        showReportBottomSheet(context, postKey);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );

                              },
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullscreenImagePage(imageUrl: imageUrl),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        imageUrl,
                        width: MediaQuery.of(context).size.width * 0.95,
                        height: 500,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        caption,
                        style: const TextStyle(color: Color(0xFFFFBA76), fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                          icon: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color: isLiked ? Colors.red : Color(0xFFFFBA76),
                          ),
                          onPressed: () async {
                            final ref = FirebaseDatabase.instance.ref();
                            final postRef = ref.child('pictures/$postKey');
                            final userLikesRef = ref.child('users/$_currentUsername/likedpictures');

                            if (isLiked) {
                              likes--;
                              await postRef.child('likes').set(likes);
                              await postRef.child('likedBy/$_currentUsername').remove();
                              await userLikesRef.child(postKey).remove();
                            } else {
                              likes++;
                              await postRef.child('likes').set(likes);
                              await postRef.child('likedBy/$_currentUsername').set(true);
                              await userLikesRef.child(postKey).set({'url': imageUrl, 'timestamp': DateTime.now().toIso8601String()});
                            }

                            setState(() {
                              isLiked = !isLiked;
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            isSaved ? Icons.bookmark : Icons.bookmark_border,
                            color: isSaved ? Colors.blue : Color(0xFFFFBA76),
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
                              await userSavesRef.child(postKey).remove();
                            } else {
                              await postRef.child('saves').runTransaction((value) {
                                final current = (value ?? 0) as int;
                                return Transaction.success(current + 1);
                              });
                              await postRef.child('savedBy/$_currentUsername').set(true);
                              await userSavesRef.child(postKey).set({'url': imageUrl, 'timestamp': DateTime.now().toIso8601String()});
                            }

                            setState(() {
                              isSaved = !isSaved;
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.share, color: Color(0xFFFFBA76)),
                          onPressed: () => shareImageFromUrl(imageUrl),
                        ),
                        IconButton(
                          icon: const Icon(Icons.comment, color: Color(0xFFFFBA76)),
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
                            style: const TextStyle(color: Color(0xFFFFBA76), fontWeight: FontWeight.bold),
                          ),
                          const TextSpan(
                            text: ' likes',
                            style: TextStyle(color: Color(0xFFFFBA76)),
                          ),
                        ],
                      ),
                    ),
                    if (showComments) ...[
                      const Divider(color: Color(0xFFFFBA76)),
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
                                    
                                    '$user: $text\n${_getTimeAgo(ts.toLocal())}',
                                    style: const TextStyle(color: Color(0xFFFFBA76), fontSize: 13),
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
      ],
 ),
 ],
        ),
      ),
    ],
  ),
),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() => currentIndex = index);
          _onTabTapped(index);
        },
        selectedItemColor: Color.fromARGB(255, 250, 144, 39),
        unselectedItemColor: Color(0xFFFFBA76),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.bone),
            label: 'Feed',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.film),
            label: 'Reels',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Camera',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.dog),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.solidMessage),
            label: 'Message',
          ),
        ],
      ),
    );
  }
}
