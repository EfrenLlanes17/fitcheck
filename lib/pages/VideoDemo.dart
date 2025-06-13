import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

class VideoDemo extends StatefulWidget {
  final String videoPath;

  const VideoDemo({super.key, required this.videoPath});

  @override
  VideoDemoState createState() => VideoDemoState();
}

class VideoDemoState extends State<VideoDemo> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.file(File(widget.videoPath));
    _initializeVideoPlayerFuture = _controller.initialize();
    _controller.setLooping(true);
    _controller.setVolume(1.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Color(0xFFFFBA76)),
        title: const Text(
          'Retake',
          style: TextStyle(color: Color(0xFFFFBA76)),
        ),
        backgroundColor: Colors.white,
      ),
      body: FutureBuilder(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                 child: Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [
    // VIDEO PREVIEW
    SizedBox(
      height: MediaQuery.of(context).size.height * 0.65, // shorter video
      child: Stack(
        alignment: Alignment.center,
        children: [
          VideoPlayer(_controller),
          if (!_controller.value.isPlaying)
            IconButton(
              iconSize: 64,
              icon: const Icon(Icons.play_circle_fill, color: Colors.white),
              onPressed: () => setState(() => _controller.play()),
            ),
        ],
      ),
    ),

    const SizedBox(height: 24), // spacing between video and caption

    // CAPTION TEXTFIELD
    TextField(
      controller: _descriptionController,
      decoration: const InputDecoration(
        labelText: 'Add a caption...',
        labelStyle: TextStyle(
          color: Color(0xFFFFBA76),
          fontSize: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFFFBA76)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFFFBA76), width: 2.0),
        ),
      ),
      style: const TextStyle(
        color: Color(0xFFFFBA76),
        fontSize: 18,
      ),
      maxLines: null,
      cursorColor: Color(0xFFFFBA76),
    ),

    const SizedBox(height: 24), // spacing between caption and button

    // POST BUTTON
    ElevatedButton.icon(
      label: const Text(
        'Post',
        style: TextStyle(color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFFBA76),
        padding: const EdgeInsets.symmetric(vertical: 20),
        textStyle: const TextStyle(fontSize: 22),
      ),
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Video posted!")),
        );
        Navigator.pop(context);
      },
    ),

    const SizedBox(height: 12), // optional spacing after button
  ],
),

              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
