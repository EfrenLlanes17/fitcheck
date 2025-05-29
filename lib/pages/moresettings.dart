import 'package:flutter/material.dart';

class MoreSettingsPage extends StatelessWidget {
  const MoreSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('More Settings'),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        children: [
          const Divider(color: Colors.white12),
          
          // 🔧 Example: Terms of Service
          ListTile(
            leading: const Icon(Icons.article, color: Colors.white),
            title: const Text('Terms of Service', style: TextStyle(color: Colors.white)),
            onTap: () {
             
            },
          ),

          const Divider(color: Colors.white12),

          // 🔐 Example: Privacy Policy
          ListTile(
            leading: const Icon(Icons.privacy_tip, color: Colors.white),
            title: const Text('Privacy Policy', style: TextStyle(color: Colors.white)),
            onTap: () {
              
            },
          ),

          const Divider(color: Colors.white12),

          // ⚙️ Example: Notifications
          ListTile(
            leading: const Icon(Icons.notifications, color: Colors.white),
            title: const Text('Notifications', style: TextStyle(color: Colors.white)),
            onTap: () {
              
            },
          ),

          const Divider(color: Colors.white12),

          // 💬 Example: Help & Feedback
          ListTile(
            leading: const Icon(Icons.help_outline, color: Colors.white),
            title: const Text('Help & Feedback', style: TextStyle(color: Colors.white)),
            onTap: () {
              // Add navigation or logic here
            },
          ),

          const Divider(color: Colors.white12),
        ],
      ),
    );
  }
}
