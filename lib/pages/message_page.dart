import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitcheck/pages/usermessage_page.dart';
import 'package:fitcheck/pages/groups_page.dart';
import 'package:fitcheck/pages/picture_page.dart';
import 'package:fitcheck/pages/profile_page.dart';
import 'package:fitcheck/main.dart';
import 'package:fitcheck/pages/home_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  int currentIndex = 4;
  String _currentUsername = '';
  Map<String, String> _userChats = {}; // chatId -> otherUsername

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUsername = prefs.getString('username');
    if (savedUsername != null) {
      setState(() => _currentUsername = savedUsername);
      _fetchChats();
    }
  }

  void _fetchChats() {
    final userChatsRef = FirebaseDatabase.instance
        .ref()
        .child('users/$_currentUsername/chats');

    userChatsRef.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data is Map) {
        final Map<String, String> tempChats = {};
        data.forEach((chatId, value) {
          final participants = Map<String, dynamic>.from(value['participants'] ?? {});
          participants.remove(_currentUsername);
          if (participants.isNotEmpty) {
            final otherUsername = participants.keys.first;
            tempChats[chatId] = otherUsername;
          }
        });
        setState(() {
          _userChats = tempChats;
        });
      }
    });
  }

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
      default:
        page = const MessagePage();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text("Messages", style: TextStyle(color: Color(0xFFFFBA76))),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFFFFBA76)),
      ),
      body: _userChats.isEmpty
          ? const Center(child: Text("No chats yet."))
          : ListView.builder(
              itemCount: _userChats.length,
              itemBuilder: (context, index) {
                final chatId = _userChats.keys.elementAt(index);
                final otherUser = _userChats[chatId]!;
                return ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFFFBA76),
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(
                    otherUser,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserMessagePage(
                          username: otherUser,
                          chatId: chatId,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() => currentIndex = index);
          _onTabTapped(index);
        },
        selectedItemColor: const Color.fromARGB(255, 250, 144, 39),
        unselectedItemColor: const Color(0xFFFFBA76),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(FontAwesomeIcons.bone), label: 'Feed'),
          BottomNavigationBarItem(
            icon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(FontAwesomeIcons.cat),
                SizedBox(width: 4),
                Icon(FontAwesomeIcons.dove),
              ],
            ),
            label: 'Groups',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'Camera'),
          BottomNavigationBarItem(icon: Icon(FontAwesomeIcons.dog), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(FontAwesomeIcons.solidMessage), label: 'Message'),
        ],
      ),
    );
  }
}
