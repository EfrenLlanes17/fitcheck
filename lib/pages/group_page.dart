import 'package:flutter/material.dart';
import 'package:fitcheck/pages/home_page.dart';
import 'package:fitcheck/pages/search_page.dart';
import 'package:fitcheck/pages/creategroup.dart';


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

  @override
  void initState() {
    super.initState();
   
    textController = TextEditingController();
    textFieldFocusNode = FocusNode();
  }

  @override
  void dispose() {
    textController.dispose();
    textFieldFocusNode.dispose();
    super.dispose();
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
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: white,
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage('assets/images/background.png'),
            ),
          ),
          child: SingleChildScrollView(
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
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: List.generate(5, (index) {
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
                      'https://images.unsplash.com/photo-1622861431942-b45f2b5b6564?...',
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Dogs with\ndown syndrome', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFFFFBA76))),
                        SizedBox(height: 4),
                        Text('2,6058 Members', style: TextStyle(color: Colors.grey)),
                        
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
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
      ListView.builder(
        itemCount: 10,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          return Container(
  margin: const EdgeInsets.only(bottom: 15),
  padding: const EdgeInsets.all(16), // Adds padding inside the container
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16), // Rounded corners
    
  ),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              'https://picsum.photos/seed/$index/600',
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
                'Dog Pack #$index',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFFBA76),
                ),
              ),
              const Text('113 Members', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ],
      ),
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFFFBA76),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onPressed: () {},
        child: const Text('Join', style: TextStyle(color: Colors.white)),
      ),
    ],
  ),
);

        },
      ),
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
