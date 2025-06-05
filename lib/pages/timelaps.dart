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
  Timer? _slideshowTimer;
  int _currentIndex = 0;
  Map<String, dynamic>? _currentData;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _loadUserData();
    _fetchData().then((_) => _startSlideshow());
  }

  @override
  void dispose() {
    _slideshowTimer?.cancel();
    super.dispose();
  }

  Future<void> _startSlideshow() async {
    _slideshowTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (!mounted) return;
      final nextIndex = (_currentIndex + 1) % widget.postDataList.length;
      await _precacheNextImage(nextIndex);

      setState(() {
        _currentIndex = nextIndex;
      });

      _fetchData();
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

  Future<void> _fetchData() async {
    final postKey = widget.postDataList[_currentIndex]['postKey'];
    final snapshot = await FirebaseDatabase.instance.ref('pictures/$postKey').get();
    if (snapshot.exists) {
      setState(() {
        _currentData = Map<String, dynamic>.from(snapshot.value as Map);
      });
    }
  }

  Future<void> _precacheNextImage(int index) async {
    final postKey = widget.postDataList[index]['postKey'];
    final snapshot = await FirebaseDatabase.instance.ref('pictures/$postKey').get();
    if (!snapshot.exists || !mounted) return;

    final nextData = Map<String, dynamic>.from(snapshot.value as Map);
    final nextUrl = nextData['url'];
    if (nextUrl != null && nextUrl is String && nextUrl.isNotEmpty) {
      await precacheImage(NetworkImage(nextUrl), context);
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
    systemNavigationBarColor: Colors.black,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  return Scaffold(
    backgroundColor: Colors.black,
    body: Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/images/background.png',
            fit: BoxFit.cover,
            color: Colors.black.withOpacity(0.6),
            colorBlendMode: BlendMode.darken,
          ),
        ),
        if (_currentData != null) ...[
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            right: 16,
            child: LinearProgressIndicator(
  value: (_currentIndex + 1) / widget.postDataList.length,
  minHeight: 4,
  color: const Color(0xFFFFBA76),
  backgroundColor: Colors.white12,
),

          ),
                  Positioned(
          top: MediaQuery.of(context).padding.top + 40,
          left: 0,
          right: 0,
          child: Center(
            child: Text(
              'PAWPRINT',
              style: const TextStyle(
                fontFamily: 'Roboto',
                color: Color(0xFFFFBA76),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        ],
        Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 600),
            switchInCurve: Curves.easeIn,
            switchOutCurve: Curves.easeOut,
            child: _currentData == null
                ? const CircularProgressIndicator(color: Color(0xFFFFBA76))
                : Column(
                    key: ValueKey(_currentIndex),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${_getTimeAgo(DateTime.parse(_currentData!['timestamp'].toString()))}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w300,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      AnimatedOpacity(
                        opacity: 1.0,
                        duration: const Duration(milliseconds: 400),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            _currentData!['url'] ?? '',
                            width: MediaQuery.of(context).size.width * 0.96,
                            height: 550,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _currentData!['caption'] ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 12,
          left: 8,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFFFFBA76)),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ],
    ),
  );
}

}
