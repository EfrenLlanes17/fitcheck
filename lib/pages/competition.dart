import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/services.dart';
import 'package:fitcheck/pages/home_page.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';


class CompetitionPage extends StatefulWidget {
  const CompetitionPage({super.key});

  @override
  State<CompetitionPage> createState() => _CompetitionPageState();
}

class _CompetitionPageState extends State<CompetitionPage> {
DateTime? endDateTime;
Duration remainingTime = Duration.zero;
Timer? countdownTimer;
String countdownText = '';
 String _currentUsername = '';
   String _currentanimal = '';
  String description = "";
  String enddate = "";
  double prize = 0.0;
  String theme = "";
  String banner = "";
  int entrycount = 0;
      final databaseRef = FirebaseDatabase.instance.ref();


  @override
  void initState() {
    super.initState();
    countdownText = "Loading...";
    _loadUserData();
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
          if (enddate.isNotEmpty) {
           try {
  endDateTime = DateTime.parse(enddate);
  startCountdown();
} catch (e) {
  print('Invalid end date format: $e');
}

          }

          entrycount = data['entrycount'] ?? 0;
          prize = (data['prize'] ?? 0).toDouble();
          theme = data['theme'] ?? "";
          banner = data['banner'] ?? "";
        });
      } else {
        print('No data found at comp/');
      }
    } catch (e) {
      print('Error fetching comp details: $e');
    }
  }

void startCountdown() {
  countdownTimer?.cancel();
  countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
    final now = DateTime.now();

    if (endDateTime == null) {
      countdownTimer?.cancel(); // Optional: stop the timer if null
      return;
    }

    final remaining = endDateTime!.difference(now);

    setState(() {
      if (remaining.isNegative) {
        countdownText = "00:00:00:00";
        countdownTimer?.cancel();
      } else {
        final days = remaining.inDays;
        final hours = remaining.inHours % 24;
        final minutes = remaining.inMinutes % 60;
        final seconds = remaining.inSeconds % 60;
        countdownText =
  "${days}d ${hours}h ${minutes}m ${seconds}s";

      }
    });
  });
}


@override
void dispose() {
  countdownTimer?.cancel();
  super.dispose();
}

Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUsername = prefs.getString('username');
    
    if (savedUsername != null) {
      setState(() {
        _currentUsername = savedUsername;
  
      });
      
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

Future<void> addUsertoComp() async {
  try {


    DatabaseReference newPicRef = databaseRef.child('comp/entries').push();
    String pushedKey = newPicRef.key!;

    // Step 2: Set full picture data under /pictures/{pushedKey}
    await newPicRef.set({
      'user': _currentUsername,
      'animal': _currentanimal,
      'profilepicture' : 'https://firebasestorage.googleapis.com/v0/b/fitcheck-e648e.firebasestorage.app/o/profile_pictures%2F${_currentUsername}_$_currentanimal.jpg?alt=media'
      
    });



    await databaseRef.child('comp/entrycount').runTransaction((currentData) {
  final current = currentData as int? ?? 0;
  return Transaction.success(current + 1);
});


    print('Image uploaded and URL saved!');
  } catch (e) {
    print('Error uploading image: $e');
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
                          banner,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Column(
                      children: [
Text(
  countdownText.isEmpty ? 'Loading...' : countdownText,
  style: const TextStyle(color: Colors.white),
),

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
                          onPressed: () {addUsertoComp();},
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
