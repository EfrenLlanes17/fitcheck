import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';



class MoreSettingsPage extends StatefulWidget {
  const MoreSettingsPage({super.key});

  @override
  State<MoreSettingsPage> createState() => _MoreSettingsPageState();
}

class _MoreSettingsPageState extends State<MoreSettingsPage> {
String _currentUsername = '';
final databaseRef = FirebaseDatabase.instance.ref();




@override
void initState() {
  super.initState();
  _loadUserData();
}

 

  void _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUsername = prefs.getString('username');
    
    if (savedUsername != null) {
      setState(() {
        _currentUsername = savedUsername;
  
      });
      
    }
  }



  void showReportBugBottomSheet(BuildContext context) {
  final TextEditingController reportController = TextEditingController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
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
              'Report Error',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Please describe the error:",
            ),
            const SizedBox(height: 10),
            TextField(
              controller: reportController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Enter your report here...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () async {
                  final reportText = reportController.text.trim();
                  if (reportText.isNotEmpty) {
                    await databaseRef.child('bugreports').push().set({
      'text': reportText, 'reporter' : _currentUsername
      
    });
                    Navigator.pop(context);
                  }
                },
                child: const Text('Send'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      );
    },
  );
}

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
          
           ListTile(
            leading: const Icon(Icons.info, color: Colors.white),
            title: const Text('My Info', style: TextStyle(color: Colors.white)),
            onTap: () {
              // Add navigation or logic here
            },
          ),
          

          const Divider(color: Colors.white12),

           ListTile(
            leading: const Icon(Icons.bug_report, color: Colors.white),
            title: const Text('Report A Error', style: TextStyle(color: Colors.white)),
            onTap: () {
              showReportBugBottomSheet(context);
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
