import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/services.dart';
import 'package:fitcheck/pages/home_page.dart';
import 'package:firebase_database/firebase_database.dart';

class CompetitionPage extends StatefulWidget {
  const CompetitionPage({super.key});

  @override
  State<CompetitionPage> createState() => _CompetitionPageState();
}

class _CompetitionPageState extends State<CompetitionPage> {
  String description = "";
  String enddate = "";
  double prize = 0.0;
  String theme = "";
  int entrycount = 0;

  @override
  void initState() {
    super.initState();
    getCompDetails();
  }

  Future<void> getCompDetails() async {
    try {
      final databaseRef = FirebaseDatabase.instance.ref();
      final snapshot = await databaseRef.child('comp').get();

      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);

        setState(() {
          description = data['description'] ?? "";
          enddate = data['enddate'] ?? "";
          entrycount = data['entrycount'] ?? 0;
          prize = (data['prize'] ?? 0).toDouble();
          theme = data['theme'] ?? "";
        });
      } else {
        print('No data found at comp/');
      }
    } catch (e) {
      print('Error fetching comp details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: const Color(0xFFFFEFE7),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Color(0xFFFFBA76)),
                        onPressed: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const HomePage()),
                        ),
                      ),
                      const Text(
                        'COMPETITION',
                        style: TextStyle(
                          color: Color(0xFFFFBA76),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const FaIcon(FontAwesomeIcons.ellipsisH, color: Color(0xFFFFBA76)),
                    ],
                  ),
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 275,
                      decoration: const BoxDecoration(color: Color(0xFF2F2F2F)),
                      child: Opacity(
                        opacity: 0.5,
                        child: Image.network(
                          'https://images.unsplash.com/photo-1615751072497-5f5169febe17?auto=format&fit=crop&w=1080&q=80',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        const Text('01:12:34:32', style: TextStyle(color: Colors.white)),
                        Text(
                          theme,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '$entrycount  ',
                                style: const TextStyle(color: Colors.white),
                              ),
                              const TextSpan(
                                text: 'Entries',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '\$$prize  ',
                                style: const TextStyle(
                                  color: Color(0xFFFFBA76),
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const TextSpan(
                                text: 'Prize!',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFBA76),
                            foregroundColor: Colors.white,
                            textStyle: const TextStyle(fontSize: 24),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {},
                          child: const Text('Enter'),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        maxLines: 10,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            'Entries',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          FaIcon(FontAwesomeIcons.arrowsAltV),
                        ],
                      ),
                      const SizedBox(height: 10),
                      GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: 12,
                        itemBuilder: (context, index) => ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            'https://images.unsplash.com/photo-1615789591457-74a63395c990?auto=format&fit=crop&w=1080&q=80',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
