import 'package:flutter/material.dart';
import 'package:fitcheck/pages/home_page.dart';
import 'package:fitcheck/pages/search_page.dart';
import 'package:fitcheck/pages/creategroup.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart';


import 'package:flutter/services.dart';

class GroupPage extends StatefulWidget {
  const GroupPage({super.key});

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late TextEditingController textController;
  late FocusNode textFieldFocusNode;
  final DatabaseReference databaseRef = FirebaseDatabase.instance.ref();
  String _currentUsername = '';
  String _currentanimal = '';

  @override
  void initState() {
    super.initState();
   
    textController = TextEditingController();
    textFieldFocusNode = FocusNode();
    _loadUserData();
  }

  @override
  void dispose() {
    textController.dispose();
    textFieldFocusNode.dispose();
    super.dispose();
  }

  void _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUsername = prefs.getString('username');

    if (savedUsername != null) {
      final snapshot = await databaseRef.child('users/$savedUsername').get();
      if (snapshot.exists) {
        final userData = snapshot.value as Map;
        setState(() {
          _currentUsername = savedUsername;
        });
      }
    }

    final savedAnimal = prefs.getString('animal');

    if (savedAnimal != null) {
      final snapshot = await databaseRef.child('users/$savedUsername/pets/$savedAnimal').get();
      if (snapshot.exists) {
        final userData = snapshot.value as Map;
        setState(() {
          _currentanimal = savedAnimal;
        });
      }
    }
  }

  Widget buildAllGroupsListView() {
  final databaseRef = FirebaseDatabase.instance.ref();

  return FutureBuilder<DataSnapshot>(
    future: databaseRef.child('groups').get(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      if (!snapshot.hasData || snapshot.data!.value == null) {
        return const Center(child: Text('No groups available.'));
      }

      final Map<String, dynamic> groupsMap =
          Map<String, dynamic>.from(snapshot.data!.value as Map);

      final groupEntries = groupsMap.entries.toList();

      return ListView.builder(
        itemCount: groupEntries.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final entry = groupEntries[index];
          final groupData = Map<String, dynamic>.from(entry.value);

          final groupName = groupData['groupname'] ?? 'Unknown Pack';
          final imageUrl = groupData['bannerurl'] ?? '';
          final memberCount = groupData['membercount']?.toString() ?? '0';

          return Container(
            margin: const EdgeInsets.only(bottom: 15),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imageUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          groupName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFFFBA76),
                          ),
                        ),
                        Text('$memberCount Members',
                            style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFBA76),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    // TODO: Add join group logic
                  },
                  child: const Text('Join', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}


  Widget buildUserGroupsScrollView() {
  final databaseRef = FirebaseDatabase.instance.ref();

  return FutureBuilder<DataSnapshot>(
    future: databaseRef.child('users/$_currentUsername/groups').get(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      if (!snapshot.hasData || snapshot.data!.value == null) {
        return const Center(child: Text('No packs found.'));
      }

      final Map<String, dynamic> groupsMap =
          Map<String, dynamic>.from(snapshot.data!.value as Map);

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: groupsMap.entries.map((entry) {
            final groupData = Map<String, dynamic>.from(entry.value);

            return Container(
              width: 160,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                    child: Image.network(
                      groupData['url'] ?? '',
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          groupData['groupname'] ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFFFBA76),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    const appOrange = Color(0xFFFFBA76);
    const white = Colors.white;
return AnnotatedRegion<SystemUiOverlayStyle>(
    value: SystemUiOverlayStyle(
      statusBarColor: Colors.white, // Makes the status bar background white
      statusBarIconBrightness: Brightness.dark, // Makes icons dark (for white background)
      statusBarBrightness: Brightness.light, // iOS brightness setting
    ),
    child: SafeArea(
      child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage('assets/images/background.png'),
            ),
          ),
           child: Scaffold(
        backgroundColor: Colors.transparent, // Important: Make scaffold transparent
        key: scaffoldKey,
        body: SingleChildScrollView(
            child: Column(
              children: [
                Container(
  color: white,
  child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    child: Stack(
  alignment: Alignment.center,
  children: [
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: appOrange),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.add, color: appOrange, size: 28),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const PETEditGroupWidget()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.search, color: appOrange, size: 28),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchPage()),
                );
              },
            ),
          ],
        ),
      ],
    ),
    const Text(
      'Packs',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: appOrange,
      ),
    ),
  ],
),

  ),
),

                // Popular Pack Section - Scrollable Horizontally
Container(
  color: Colors.transparent,
  padding: const EdgeInsets.only(top: 12),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Center(
  child: Text(
    'My Packs',
    style: TextStyle(
      fontSize: 25,
      fontWeight: FontWeight.bold,
      color: Color.fromARGB(255, 255, 255, 255),
    ),
  ),
),
      ),
      const SizedBox(height: 8),
      buildUserGroupsScrollView(),
    ],
  ),
),

// Packs You Might Like - Scrollable Vertically
SizedBox(height: 30,),
Container(
  color: Colors.transparent,
  padding: const EdgeInsets.symmetric(vertical: 12),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Center(
  child: Text(
    'Packs You May Like',
    style: TextStyle(
      fontSize: 25,
      fontWeight: FontWeight.bold,
      color: Color.fromARGB(255, 255, 255, 255),
    ),
  ),
),

      ),
      const SizedBox(height: 8),
      buildAllGroupsListView(),
    ],
  ),
),
              ],
            ),
          ),
        
      ),
      ),
    ),
    );
  }
}
