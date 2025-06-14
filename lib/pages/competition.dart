import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/services.dart';
import 'package:fitcheck/pages/home_page.dart';



class CompetitionPage extends StatelessWidget {
  const CompetitionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
    value: SystemUiOverlayStyle(
      statusBarColor: Colors.white, // Makes the status bar background white
      statusBarIconBrightness: Brightness.dark, // Makes icons dark (for white background)
      statusBarBrightness: Brightness.light, // iOS brightness setting
    ),
    child:SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFFFEFE7),
        body: Container(
          decoration: const BoxDecoration(
           
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children:  [
                      IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFFFFBA76)),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          ),
        ),
                      Text(
                        'COMPETITIONS',
                        style: TextStyle(
                          color: Color(0xFFFFBA76),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      FaIcon(
                        FontAwesomeIcons.ellipsisH,
                        color: Color(0xFFFFBA76),
                      ),
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
                          width: double.infinity,
                          height: 275,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        const Text(
                          '01:12:34:32',
                          style: TextStyle(color: Colors.white),
                        ),
                        const Text(
                          'Cutest Pet!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '477  ',
                                style: TextStyle(color: Colors.white),
                              ),
                              TextSpan(
                                text: 'Entries',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        const Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '\$250  ',
                                style: TextStyle(
                                  color: Color(0xFFFFBA76),
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
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
                            backgroundColor: Color(0xFFFFBA76),
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
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Get ready for the ultimate dose of adorableness at our Cute Pet Competition! Whether they bark, purr, chirp, or hop, pets of all kinds are welcome to strut their stuff and charm the crowd. From fluffiest fur to funniest tricks, each furry (or feathery!) friend will compete for the title of Cutest Pet. Join us for a day full of smiles, tail wags, and heart-melting moments — it\'s the perfect event for animal lovers of all ages!',
                        maxLines: 10,
                        overflow: TextOverflow.ellipsis,
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
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
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
    ),
    );
  }
}