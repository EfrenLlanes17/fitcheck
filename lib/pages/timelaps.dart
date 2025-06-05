import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

class TimelapsPage extends StatefulWidget {
  final List<Map<String, dynamic>> postDataList;
  final int initialIndex;

  const TimelapsPage({
    required this.postDataList,
    required this.initialIndex,
    super.key,
  });

  @override
  State<TimelapsPage> createState() => _TimelapsPageState();
}

class _TimelapsPageState extends State<TimelapsPage> {
  String _currentUsername = '';
  late PageController _pageController;
  Timer? _slideshowTimer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    _currentPage = widget.initialIndex;
    _loadUserData();
    _startSlideshow();
  }

  @override
  void dispose() {
    _slideshowTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startSlideshow() {
    _slideshowTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) return;

      setState(() {
        _currentPage = (_currentPage + 1) % widget.postDataList.length;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      });
    });
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

  String _getTimeAgo(DateTime postDate) {
    final now = DateTime.now();
    final difference = now.difference(postDate);
    if (difference.inSeconds < 60) return '${difference.inSeconds} secs ago';
    if (difference.inMinutes < 60) return '${difference.inMinutes} mins ago';
    if (difference.inHours < 24) return '${difference.inHours} hours ago';
    if (difference.inDays < 7) return '${difference.inDays} days ago';
    if (difference.inDays < 30) return '${(difference.inDays / 7).floor()} weeks ago';
    if (difference.inDays < 365) return '${(difference.inDays / 30).floor()} months ago';
    return '${(difference.inDays / 365).floor()} years ago';
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Timelapse',
          style: TextStyle(color: Color(0xFFFFBA76)),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFFFFBA76)),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.horizontal,
            itemCount: widget.postDataList.length,
            onPageChanged: (index) => _currentPage = index,
            itemBuilder: (context, index) {
              final postKey = widget.postDataList[index]['postKey'];
              return FutureBuilder<DataSnapshot>(
                future: FirebaseDatabase.instance.ref('pictures/$postKey').get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.value == null) {
                    return const Center(
                      child: Text('Post not found', style: TextStyle(color: Colors.white70)),
                    );
                  }

                  final data = Map<String, dynamic>.from(snapshot.data!.value as Map);
                  final imageUrl = data['url'] ?? '';
                  final timestamp = data['timestamp'].toString();
                  final caption = data['caption'] ?? '';

                  return Padding(
                    padding: const EdgeInsets.all(5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '• ${_getTimeAgo(DateTime.parse(timestamp))}',
                          style: const TextStyle(
                            color: Color(0xFFFFBA76),
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(
                            imageUrl,
                            width: double.infinity,
                            height: 600,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          caption,
                          style: const TextStyle(color: Color(0xFFFFBA76), fontSize: 14),
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
    );
  }
}
