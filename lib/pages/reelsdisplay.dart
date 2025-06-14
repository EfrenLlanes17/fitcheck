
 import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fitcheck/pages/profile_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';




class VideoPostWidget extends StatefulWidget {
  final String url;
  final String username;
  final String caption;
  final String postKey;
  final DateTime postDate;
  final Function(String imageUrl) onShare;
  final Function(BuildContext context, String postKey) onReport;

  const VideoPostWidget({
    super.key,
    required this.url,
    required this.username,
    required this.caption,
    required this.postDate,
    required this.postKey,
    required this.onShare,
    required this.onReport,
  });

  @override
  State<VideoPostWidget> createState() => _VideoPostWidgetState();
}

class _VideoPostWidgetState extends State<VideoPostWidget> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
void initState() {
  super.initState();
  _controller = VideoPlayerController.contentUri(Uri.parse(widget.url));
  
  _initializeVideoPlayerFuture = _controller.initialize().then((_) {
    // Play video automatically after initialization
    _controller.play();
    setState(() {}); // Refresh UI so the play button disappears
  });

  _controller.setLooping(true);
}


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getTimeAgo(DateTime postDate) {
    final now = DateTime.now();
    final difference = now.difference(postDate);

    if (difference.inSeconds < 60) return '${difference.inSeconds}s ago';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    if (difference.inDays < 30) return '${(difference.inDays / 7).floor()}w ago';
    if (difference.inDays < 365) return '${(difference.inDays / 30).floor()}mo ago';
    return '${(difference.inDays / 365).floor()}y ago';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: FutureBuilder(
            future: _initializeVideoPlayerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    GestureDetector(
                    onTap: () {
                      setState(() {
                        if (_controller.value.isPlaying) {
                          _controller.pause();
                        } else {
                          _controller.play();
                        }
                      });
                    },
                    child: VideoPlayer(_controller),
                  ),
                    if (!_controller.value.isPlaying)
                      IconButton(
                        iconSize: 64,
                        icon: const Icon(Icons.play_circle_fill, color: Colors.white),
                        onPressed: () => setState(() => _controller.play()),
                      ),
                  ],
                );
              } else {
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
            },
          ),
        ),
        Positioned(
  right: 16,
  bottom: 20,
  child: Column(
    children: const [
      FaIcon(FontAwesomeIcons.heart, color: Colors.white, size: 36),
      SizedBox(height: 75),
      FaIcon(FontAwesomeIcons.comment, color: Colors.white, size: 36),
      SizedBox(height: 75),
      Icon(Icons.share, color: Colors.white, size: 36),
      SizedBox(height: 75),
      FaIcon(
        FontAwesomeIcons.ellipsisV,
        color: Colors.white,
        size: 32,
      ),
    ],
  ),
),

        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('@${widget.username}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              Text(widget.caption, style: const TextStyle(color: Colors.white, fontSize: 14)),
              Text(_getTimeAgo(widget.postDate), style: const TextStyle(color: Colors.white70, fontSize: 12)),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.share, color: Colors.white),
                    onPressed: () => widget.onShare(widget.url),
                  ),
                  IconButton(
                    icon: const Icon(Icons.flag, color: Colors.white),
                    onPressed: () => widget.onReport(context, widget.postKey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
