import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fitcheck/pages/group_page.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart';



class PETspeciicGroupPage extends StatefulWidget {
  final String groupname;
  const PETspeciicGroupPage({super.key, required this.groupname});

  @override
  State<PETspeciicGroupPage> createState() => _PETspeciicGroupPageState();
}

class _PETspeciicGroupPageState extends State<PETspeciicGroupPage> {
String groupname = "";
String _currentUsername = "";
String _currentanimal = "";
  final DatabaseReference databaseRef = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
   groupname = widget.groupname;
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFFFEFE7),
        body: SafeArea(
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage(
                  'assets/images/background.png',
                ),
              ),
            ),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildHeaderSection()),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildPost(imageOnly: true),
                    childCount: 4, // Adjust as needed
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showReportBottomSheet(BuildContext context) {
  final TextEditingController reportController = TextEditingController();


  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    builder: (BuildContext context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Report Pack',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFFFBA76)),
            ),
            const SizedBox(height: 10),
            const Text(
              'Please describe the issue:',  style: TextStyle(color: Color(0xFFFFBA76)),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: reportController,
              maxLines: 4,
              style: const TextStyle(color: Color(0xFFFFBA76)),
              decoration: const InputDecoration(
                hintText: 'Enter your report here...',
                hintStyle: TextStyle(color: Color(0xFFFFBA76)),
                border: OutlineInputBorder(),
                
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                 
                  backgroundColor: const Color(0xFFFFBA76), // Button background
                ),
                onPressed: () async {
                  final reportText = reportController.text.trim();
                  if (reportText.isNotEmpty) {
                    await databaseRef.child('packreports').push().set({
      'text': reportText, 'reporter' : _currentUsername, 'groupname' : groupname
      
    });
                    Navigator.pop(context);
                  }
                },
                child: const Text('Send', style: TextStyle(color: Color.fromARGB(255, 255, 255, 255))),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      );
    },
  );
}

Widget _buildHeaderSection() {
  final groupsRef = FirebaseDatabase.instance.ref().child('groups');

  return FutureBuilder<DataSnapshot>(
    future: groupsRef.get(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const SizedBox(
          height: 275,
          child: Center(child: CircularProgressIndicator()),
        );
      }

      if (!snapshot.hasData || snapshot.data!.value == null) {
        return const SizedBox(
          height: 275,
          child: Center(child: Text('No groups found', style: TextStyle(color: Colors.white))),
        );
      }

      final groupsMap = Map<String, dynamic>.from(snapshot.data!.value as Map);
      final matchingEntry = groupsMap.entries.firstWhere(
        (entry) {
          final data = Map<String, dynamic>.from(entry.value);
          return data['groupname'] == groupname;
        },
        orElse: () => MapEntry('', {}),
      );

      if (matchingEntry.value.isEmpty) {
        return const SizedBox(
          height: 275,
          child: Center(child: Text('Group not found', style: TextStyle(color: Colors.white))),
        );
      }

      final groupKey = matchingEntry.key;
      final groupData = Map<String, dynamic>.from(matchingEntry.value);
      final imageUrl = groupData['bannerurl'] ?? '';
      final followerCount = groupData['membercount']?.toString() ?? '0';
      final members = Map<String, dynamic>.from(groupData['members'] ?? {});
      final isMember = members.containsKey(_currentUsername); // Make sure _currentUsername is defined

      return Stack(
        children: [
          Container(
            width: double.infinity,
            height: 275,
            color: const Color(0xFF2F2F2F),
            child: Opacity(
              opacity: 0.6,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 5,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color(0xFFFFBA76)),
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const GroupPage()),
                  ),
                ),
                Row(
                  children:  [
                    Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: FaIcon(
                        FontAwesomeIcons.comment,
                        color: Color(0xFFFFBA76),
                        size: 20,
                      ),
                    ),
                    Padding(
  padding: EdgeInsets.only(left: 12), // ✅ Not const
  child: IconButton(
    icon: Icon(Icons.more_vert, color: Color(0xFFFFBA76)), // ✅ Not const
    onPressed: () async {
      await showModalBottomSheet(
        context: context,
        builder: (_) {
          return SafeArea(
            child: Container(
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: Icon(Icons.flag, color: Color(0xFFFFBA76)),
                    title: Text(
                      'Report Competition',
                      style: TextStyle(color: Color(0xFFFFBA76)),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      showReportBottomSheet(context); // make sure this function exists
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  ),
)

                  ],
                ),
              ],
            ),
          ),
          Positioned.fill(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    groupname,
                    style: const TextStyle(fontSize: 32, color: Colors.white),
                  ),
                  Text(
                    '$followerCount Followers',
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                   onPressed: () async {
  final groupRef = FirebaseDatabase.instance.ref('groups/$groupKey');
  final userRef = groupRef.child('members/$_currentUsername');
  final userGroupRef = FirebaseDatabase.instance
      .ref('users/$_currentUsername/groups/$groupKey');

  // Get current member count (defaults to 0 if null)
  final groupSnapshot = await groupRef.get();
  int currentCount = 0;
  if (groupSnapshot.exists && groupSnapshot.value != null) {
    final data = Map<String, dynamic>.from(groupSnapshot.value as Map);
    currentCount = (data['membercount'] ?? 0) as int;
  }

  if (isMember) {
    // Leave group
    await userRef.remove();
    await userGroupRef.remove();
    await groupRef.update({'membercount': currentCount > 0 ? currentCount - 1 : 0});
  } else {
    // Join group
    final profilePicSnap = await FirebaseDatabase.instance
        .ref('users/$_currentUsername/pets/$_currentanimal/profilepicture')
        .get();
    final profilePic = profilePicSnap.value ?? '';
    await userRef.set({'profilepicture': profilePic});
    await userGroupRef.set({'groupname': groupname, 'url': imageUrl});
    await groupRef.update({'membercount': currentCount + 1});
  }

  setState(() {}); // Refresh button state and UI
},

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFBA76),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      isMember ? 'Following' : 'Join the Pack',
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    },
  );
}





  Widget _buildPost({bool imageOnly = false}) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundImage: NetworkImage(
                  'https://picsum.photos/seed/574/600',
                ),
                radius: 20,
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('huh', style: TextStyle(fontWeight: FontWeight.w600)),
                    Text(
                      '@animal_king · 13h',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFFBA76),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Follow', style: TextStyle(fontSize: 14)),
              ),
              const SizedBox(width: 8),
              const FaIcon(
                FontAwesomeIcons.ellipsisH,
                color: Color(0xFFFFBA76),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              'https://picsum.photos/id/219/5000/3333',
              height: 400,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              FaIcon(FontAwesomeIcons.heart, color: Color(0xFFFFBA76)),
              FaIcon(FontAwesomeIcons.comment, color: Color(0xFFFFBA76)),
              Icon(Icons.share, color: Color(0xFFFFBA76)),
              FaIcon(FontAwesomeIcons.bookmark, color: Color(0xFFFFBA76)),
            ],
          ),
        ],
      ),
    );
  }
}