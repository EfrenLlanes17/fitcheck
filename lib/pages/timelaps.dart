import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fitcheck/pages/groups_page.dart';
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
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';






class TimelapsPage  extends StatefulWidget {
  final List<Map<String, dynamic>> postDataList;
  final int initialIndex;

  const TimelapsPage({required this.postDataList,
    required this.initialIndex,
    super.key,});

  @override
  State<TimelapsPage> createState() => _TimelapsPageState();
}

class _TimelapsPageState extends State<TimelapsPage> {
  int currentIndex = 0;
  String _currentUsername = '';
  final DatabaseReference databaseRef = FirebaseDatabase.instance.ref();
  late PageController _pageController;
final ItemScrollController _itemScrollController = ItemScrollController();





   void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    
    _loadUserData();
   WidgetsBinding.instance.addPostFrameCallback((_) {
  _itemScrollController.scrollTo(
    index: widget.initialIndex,
    duration: Duration(milliseconds: 0),
  );
});


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




  @override
  Widget build(BuildContext context) {


    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: Color.fromARGB(255, 255, 255, 255), // your desired color
    systemNavigationBarIconBrightness: Brightness.dark, // or Brightness.light depending on contrast
  ));


    return Scaffold(

      appBar: AppBar(
  title: const Text(
    '',
    style: TextStyle(color: Color(0xFFFFBA76)), // Change text color here
  ),
  backgroundColor: Colors.white,
  iconTheme: const IconThemeData(color: Color(0xFFFFBA76)), // Also changes back button/icon color
),


 body: Stack(
      children: [

        Positioned.fill(
      child: Image.asset(
        'assets/images/background.png', // ✅ Make sure it's declared in pubspec.yaml
        fit: BoxFit.cover,
      ),
    ),

    ScrollablePositionedList.builder(
      itemScrollController: _itemScrollController,
      initialScrollIndex: widget.initialIndex, // ✅ Set here instead of manually scrolling later

      itemCount: widget.postDataList.length,
      itemBuilder: (context, index) {
        final postKey = widget.postDataList[index]['postKey'];

        
        

         return FutureBuilder<DataSnapshot>(
          future: FirebaseDatabase.instance.ref('pictures/$postKey').get(),
          builder: (context, snapshot) {
            

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.value == null) {
              return const Center(
                child: Text(
                  'Post not found',
                  style: TextStyle(color: Colors.white70),
                ),
              );
              
            }

            

          final picturesMap = Map<String, dynamic>.from(snapshot.data!.value as Map);




final data = Map<String, dynamic>.from(snapshot.data!.value as Map);
  final imageUrl = data['url'] ?? '';
  final timestamp = data['timestamp'].toString();
  final caption = data['caption'] ?? '';
  final username = data['user'] ?? '';
  final profilePicUrl = data['profilepicture'] ?? '';

  int likes = int.tryParse(data['likes'].toString()) ?? 0;
  


  return FutureBuilder<DataSnapshot>(
    future: FirebaseDatabase.instance.ref('pictures/$postKey/likedBy/$_currentUsername').get(),
    builder: (context, likeSnapshot) {

      return FutureBuilder<DataSnapshot>(
        future: FirebaseDatabase.instance.ref('pictures/$postKey/savedBy/$_currentUsername').get(),
        builder: (context, saveSnapshot) {
          
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

                          
                        
                        
                        
                      ],
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                    onTap: () {
                      
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
      }
    )
      ],
 ),

    );
  }
}
