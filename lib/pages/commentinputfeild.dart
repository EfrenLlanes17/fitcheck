import 'package:flutter/material.dart';
import 'package:fitcheck/pages/freinds_page.dart';
import 'package:fitcheck/pages/picture_page.dart';
import 'package:fitcheck/pages/profile_page.dart';
import 'package:fitcheck/pages/home_page.dart';
import 'package:fitcheck/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_database/firebase_database.dart';




class CommentInputField extends StatefulWidget {
  final String postKey;
  final String currentUser;

  const CommentInputField({
    super.key,
    required this.postKey,
    required this.currentUser,
  });

  @override
  State<CommentInputField> createState() => _CommentInputFieldState();
}

class _CommentInputFieldState extends State<CommentInputField> {
  final TextEditingController _controller = TextEditingController();
  bool _isSending = false;

  Future<void> _submitComment() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSending = true);

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final commentRef = FirebaseDatabase.instance
        .ref('pictures/${widget.postKey}/comments')
        .push();

    await commentRef.set({
      'user': widget.currentUser,
      'text': text,
      'timestamp': timestamp,
    });

    _controller.clear();
    setState(() => _isSending = false);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            style: const TextStyle(color: Color(0xFFFFBA76)),
            decoration: const InputDecoration(
              hintText: 'Add a comment...',
              hintStyle: TextStyle(color: Color(0xFFFFBA76)),
              border: InputBorder.none,
            ),
          ),
        ),
        IconButton(
          icon: _isSending
              ? const CircularProgressIndicator()
              : const Icon(Icons.send, color: Color(0xFFFFBA76)),
          onPressed: _isSending ? null : _submitComment,
        ),
      ],
    );
  }
}
