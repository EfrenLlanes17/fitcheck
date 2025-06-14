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
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';






class PostViewerPage  extends StatefulWidget {
  final List<Map<String, dynamic>> postDataList;
  final int initialIndex;

  const PostViewerPage({required this.postDataList,
    required this.initialIndex,
    super.key,});

  @override
  State<PostViewerPage> createState() => _PostViewerPageState();
}

class _PostViewerPageState extends State<PostViewerPage> {
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
  final animal = data['animal'] ?? '';

  final profilePicUrl = data['profilepicture'] ?? '';

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
        username,
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
                            future: FirebaseDatabase.instance.ref('users/$_currentUsername/following/$username').get(),
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
                            text: '$likes ',
                            style: const TextStyle(
                              color: Color(0xFFFFBA76),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const TextSpan(
                            text: 'likes',
                            style: TextStyle(
                              color: Color(0xFFFFBA76),
                              fontSize: 14,
                            ),
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


      


          
        },
      );
      }
    )
      ],
 ),

    );
  }
}
