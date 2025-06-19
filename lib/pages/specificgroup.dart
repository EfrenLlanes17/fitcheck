import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PET Group Page',
      theme: ThemeData(primarySwatch: Colors.orange),
      home: const PETspeciicGroupPage(),
    );
  }
}

class PETspeciicGroupPage extends StatefulWidget {
  const PETspeciicGroupPage({super.key});

  @override
  State<PETspeciicGroupPage> createState() => _PETspeciicGroupPageState();
}

class _PETspeciicGroupPageState extends State<PETspeciicGroupPage> {
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
                SliverToBoxAdapter(child: _buildTopBar()),
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

  Widget _buildTopBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(Icons.arrow_back_ios, color: Color(0xFFFFBA76), size: 24),
          const Text(
            'GROUPS',
            style: TextStyle(
              color: Color(0xFFFFBA76),
              fontSize: 24,
              fontFamily: 'Oswald',
            ),
          ),
          Row(
            children: const [
              Padding(
                padding: EdgeInsets.only(right: 12),
                child: FaIcon(
                  FontAwesomeIcons.comment,
                  color: Color(0xFFFFBA76),
                  size: 24,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 12),
                child: FaIcon(
                  FontAwesomeIcons.ellipsisH,
                  color: Color(0xFFFFBA76),
                  size: 24,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: double.infinity,
          height: 275,
          color: const Color(0xFF2F2F2F),
          child: Opacity(
            opacity: 0.5,
            child: Image.network(
              'https://images.unsplash.com/photo-1615751072497-5f5169febe17?ixlib=rb-4.1.0&auto=format&fit=crop&w=1080&q=80',
              fit: BoxFit.cover,
            ),
          ),
        ),
        Column(
          children: [
            const Text(
              'Puppy Gang',
              style: TextStyle(fontSize: 32, color: Colors.white),
            ),
            const Text(
              '2,758 Followers',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFBA76),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Join the Pack',
                style: TextStyle(fontSize: 24),
              ),
            ),
          ],
        ),
      ],
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