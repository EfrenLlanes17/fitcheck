import 'package:flutter/material.dart';
import 'package:fitcheck/pages/freinds_page.dart';
import 'package:fitcheck/pages/picture_page.dart';
import 'package:fitcheck/pages/profile_page.dart';
import 'package:fitcheck/pages/home_page.dart';
import 'package:fitcheck/main.dart';
import 'package:fitcheck/pages/message_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';



class FreindsPage extends StatefulWidget {
  const FreindsPage({super.key});

  @override
  State<FreindsPage> createState() => _FreindsPageState();
}

class _FreindsPageState extends State<FreindsPage> {
  int currentIndex = 1; // Friends tab index

  void _onTabTapped(int index) {
    if (index == currentIndex) return;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: const Center(
        child: Text(
          "Hello from Friends Page",
          style: TextStyle(color: Colors.white),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        currentIndex: currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: Color.fromARGB(255, 250, 144, 39),
        unselectedItemColor: Color(0xFFFFBA76),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
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
            label: 'Friends',
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
            icon: Icon(Icons.chat),
            label: 'Message',
          ),
        ],
      ),
    );
  }
}
