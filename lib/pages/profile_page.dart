import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fitcheck/pages/freinds_page.dart';
import 'package:fitcheck/pages/picture_page.dart';
import 'package:fitcheck/pages/home_page.dart';
import 'package:fitcheck/main.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  int currentIndex = 3;
  bool _isLoggedIn = false;
  String _currentUsername = '';
  late TabController _tabController;

  final TextEditingController _signInUsernameController = TextEditingController();
  final TextEditingController _signInPasswordController = TextEditingController();
  final TextEditingController _createUsernameController = TextEditingController();
  final TextEditingController _createPasswordController = TextEditingController();

  final DatabaseReference databaseRef = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserData();
  }

  void _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUsername = prefs.getString('username');

    if (savedUsername != null) {
      final snapshot = await databaseRef.child('users/$savedUsername').get();
      if (snapshot.exists) {
        final userData = snapshot.value as Map;
        setState(() {
          _isLoggedIn = true;
          _currentUsername = savedUsername;
        });
      }
    }
  }

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
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  void _signIn() async {
    final username = _signInUsernameController.text.trim();
    final password = _signInPasswordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter username and password')),
      );
      return;
    }

    try {
      final snapshot = await databaseRef.child('users/$username').get();
      if (snapshot.exists) {
        final userData = snapshot.value as Map;
        final storedPassword = userData['password'];

        if (storedPassword == password) {
          await databaseRef.child('users/$username').update({
            'lastLogin': DateTime.now().toIso8601String(),
          });

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('username', username);

          setState(() {
            _isLoggedIn = true;
            _currentUsername = username;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Signed in successfully')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Incorrect password')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Username does not exist')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing in: $e')),
      );
    }
  }

  void _createAccount() async {
    final username = _createUsernameController.text.trim();
    final password = _createPasswordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter username and password')),
      );
      return;
    }

    final snapshot = await databaseRef.child('users/$username').get();
    if (snapshot.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username already exists')),
      );
      return;
    }

    await databaseRef.child('users/$username').set({
      'password': password,
      'createdAt': DateTime.now().toIso8601String(),
      'lastLogin': DateTime.now().toIso8601String(),
      'email': '',
      'phone': '',
      'profilepicture': '',
      'bio': '',
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);

    setState(() {
      _isLoggedIn = true;
      _currentUsername = username;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Account created successfully')),
    );
  }

  void _signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');

    setState(() {
      _isLoggedIn = false;
      _currentUsername = '';
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _signInUsernameController.dispose();
    _signInPasswordController.dispose();
    _createUsernameController.dispose();
    _createPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        bottom: !_isLoggedIn
            ? TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Sign In'),
                  Tab(text: 'Create Account'),
                ],
              )
            : null,
      ),
      body: _isLoggedIn
          ? FutureBuilder<DataSnapshot>(
              future: databaseRef.child('users/$_currentUsername/profilepicture').get(),
              builder: (context, profileSnapshot) {
                String profileUrl = 'https://th.bing.com/th/id/OIP.VvvX4Ug_y6j3qz2l5aJIMAAAAA?w=169&h=169&c=7&r=0&o=5&cb=iwc2&dpr=1.3&pid=1.7';
                if (profileSnapshot.hasData &&
                    profileSnapshot.data!.value != null &&
                    profileSnapshot.data!.value.toString().isNotEmpty) {
                  profileUrl = profileSnapshot.data!.value.toString();
                }

                return FutureBuilder<DataSnapshot>(
                  future: databaseRef.child('users/$_currentUsername/pictures').get(),
                  builder: (context, pictureSnapshot) {
                    if (pictureSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    List<Widget> imageWidgets = [];

                    if (pictureSnapshot.hasData && pictureSnapshot.data!.value != null) {
                      final picturesMap = Map<String, dynamic>.from(pictureSnapshot.data!.value as Map);
                      imageWidgets = picturesMap.entries.map((entry) {
                        final imageUrl = entry.value['url'] as String?;
                        

                        if (imageUrl == null || imageUrl.isEmpty) return const SizedBox();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 12),
                            Image.network(imageUrl, height: 200, fit: BoxFit.cover),
                            

                            
                          ],
                        );
                      }).toList();
                    }


                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundImage: NetworkImage(profileUrl),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Welcome, $_currentUsername!',
                            style: const TextStyle(color: Colors.white, fontSize: 24),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _signOut,
                            child: const Text('Sign Out'),
                          ),
                          const SizedBox(height: 30),
                          ...imageWidgets.isNotEmpty
                              ? imageWidgets
                              : [
                                  const Text(
                                    'No pictures uploaded yet.',
                                    style: TextStyle(color: Colors.white70),
                                  )
                                ],
                        ],
                      ),
                    );
                  },
                );
              },
            )
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Sign In Tab
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _signInUsernameController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Username',
                            labelStyle: TextStyle(color: Colors.white70),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white54),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _signInPasswordController,
                          obscureText: true,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            labelStyle: TextStyle(color: Colors.white70),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white54),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _signIn,
                          child: const Text('Sign In'),
                        ),
                      ],
                    ),
                  ),
                  // Create Account Tab
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _createUsernameController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Username',
                            labelStyle: TextStyle(color: Colors.white70),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white54),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _createPasswordController,
                          obscureText: true,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            labelStyle: TextStyle(color: Colors.white70),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white54),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _createAccount,
                          child: const Text('Create Account'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        currentIndex: currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.people_alt_outlined), label: 'Friends'),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt_outlined), label: 'FitCheck'),
          BottomNavigationBarItem(icon: Icon(Icons.person_2_outlined), label: 'Profile'),
        ],
      ),
    );
  }
}
