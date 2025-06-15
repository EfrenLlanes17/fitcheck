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
import 'package:fitcheck/pages/home_page.dart';
import 'package:fitcheck/pages/fullscreenimage.dart';
import 'package:fitcheck/pages/reelsdisplay.dart';
import 'package:video_player/video_player.dart';
import 'package:lottie/lottie.dart';







void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: const FreindsPage(),
    );
  }
}

class FreindsPage extends StatefulWidget {
  const FreindsPage({super.key});

  @override
  State<FreindsPage> createState() => _FreindsPageState();
}

class _FreindsPageState extends State<FreindsPage> {
  int currentIndex = 1;
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
    
    _loadUserData();
  }

  String _getTimeAgo(DateTime postDate) {
  final now = DateTime.now();
  final difference = now.difference(postDate);

  if (difference.inSeconds < 60) {
    return '${difference.inSeconds} secs ago';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes} mins ago';
  } else if (difference.inHours < 24) {
    return '${difference.inHours} hours ago';
  } else if (difference.inDays < 7) {
    return '${difference.inDays} days ago';
  } else if (difference.inDays < 30) {
    return '${(difference.inDays / 7).floor()} weeks ago';
  } else if (difference.inDays < 365) {
    return '${(difference.inDays / 30).floor()} months ago';
  } else {
    return '${(difference.inDays / 365).floor()} years ago';
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
  title: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24.0),
    child: Row(
      children: [
        
        Expanded(
          child: Center(
            child: Text(
              'PAWPRINT',
              style: TextStyle(
              fontFamily: 'Roboto', // Or any built-in font
              color: Color(0xFFFFBA76),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),

            ),
          ),
        ),
        
      ],
    ),
  ),
),


 body: Stack(
  children: [
    Positioned.fill(
      child: Image.asset(
        'assets/images/background.png',
        fit: BoxFit.cover,
      ),
    ),
    FutureBuilder<DataSnapshot>(
      future: FirebaseDatabase.instance.ref().child('videos').get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: SizedBox(
  width: 450,
  height: 450,
  child: Transform.scale(
    scale: 0.5, // adjust scale factor as needed
    child: Lottie.asset(
      'assets/animations/dogloader.json',
      repeat: true,
      fit: BoxFit.contain,
    ),
  ),
));
        }

        if (!snapshot.hasData || snapshot.data!.value == null) {
          return const Center(
            child: Text(
              'No Videos yet.',
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
                return DateTime.fromMillisecondsSinceEpoch(value);
              }
              if (value is String) {
                try {
                  return DateTime.parse(value);
                } catch (_) {
                  return DateTime.fromMillisecondsSinceEpoch(int.tryParse(value) ?? 0);
                }
              }
              return DateTime.fromMillisecondsSinceEpoch(0);
            }

            final aTimestamp = parseTimestamp(aData['timestamp']);
            final bTimestamp = parseTimestamp(bData['timestamp']);
            return bTimestamp.compareTo(aTimestamp);
          });

       final videoWidgets = sortedEntries.map((entry) {
  final postKey = entry.key;
  final data = Map<String, dynamic>.from(entry.value);
  final url = data['url'] ?? '';
  final username = data['username'] ?? '';
  final caption = data['caption'] ?? '';
  final timestamp = data['timestamp'];
  final postDate = timestamp is int
      ? DateTime.fromMillisecondsSinceEpoch(timestamp)
      : DateTime.tryParse(timestamp.toString()) ?? DateTime.now();

  return VideoPostWidget(
    url: url,
    username: username,
    caption: caption,
    postKey: postKey,
    postDate: postDate,
    onShare: shareImageFromUrl,
    onReport: showReportBottomSheet,
  );
}).toList();




        return PageView.builder(
          scrollDirection: Axis.vertical,
          itemCount: videoWidgets.length,
          itemBuilder: (context, index) => videoWidgets[index],
        );
      },
    ),
  ],
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
            icon: Row(
  mainAxisSize: MainAxisSize.min,
  children: const [
    Icon(FontAwesomeIcons.cat),
    SizedBox(width: 4),
   Icon(FontAwesomeIcons.dove),
  ],
)
,
            label: 'Groups',
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
