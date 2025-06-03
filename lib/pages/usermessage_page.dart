import 'package:flutter/material.dart';
import 'package:fitcheck/pages/groups_page.dart';
import 'package:fitcheck/pages/picture_page.dart';
import 'package:fitcheck/pages/profile_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fitcheck/main.dart'; // For `cameras`
import 'package:fitcheck/pages/home_page.dart';


class UserMessagePage extends StatefulWidget {
  final String username;
  const UserMessagePage({super.key, required this.username});

  @override
  State<UserMessagePage> createState() => UserMessagePageState();
}

class UserMessagePageState extends State<UserMessagePage> {
  final List<String> _messages = [];
  final TextEditingController _controller = TextEditingController();
  int currentIndex = 4;

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      _messages.add(_controller.text.trim());
      _controller.clear();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: Center(
    child: Text(
      widget.username,
      style: const TextStyle(color: Color(0xFFFFBA76)),
    ),
  ),
  backgroundColor: Colors.white,
  iconTheme: const IconThemeData(color: Color(0xFFFFBA76)),
),

      
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple[100],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(_messages[index]),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration.collapsed(
                      hintText: "Type a message...",
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.deepPurple),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
      
    );
  }
}
