import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';


class UserMessagePage extends StatefulWidget {
  final String username;
  final String chatId;
  const UserMessagePage({super.key, required this.username, required this.chatId});

  @override
  State<UserMessagePage> createState() => _UserMessagePageState();
}

class _UserMessagePageState extends State<UserMessagePage> {
  final TextEditingController _controller = TextEditingController();
  late final DatabaseReference _chatRef;
  late final DatabaseReference _messagesRef;
  String _currentUsername = '';


 @override
  void initState() {
    super.initState();
    if(widget.chatId.isEmpty){
     _chatRef = FirebaseDatabase.instance.ref().child('chats').push();
    }
    else{
      _chatRef = FirebaseDatabase.instance.ref().child('chats').child(widget.chatId);
    }
    
    _messagesRef = _chatRef.child('messages');
    _loadUserData();
    
    
  }

  void createchat() async{
    await _chatRef.child('participants').update({
    widget.username: true,
    _currentUsername: true,
  });
  }

  void _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUsername = prefs.getString('username');
    
    if (savedUsername != null) {
      setState(() {
        _currentUsername = savedUsername;
  
      });

      createchat();
      
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() async {
  final text = _controller.text.trim();
  if (text.isEmpty) return;

  final timestamp = DateTime.now().millisecondsSinceEpoch;

  // Ensure participants are written once (optional: move to chat creation logic)
  

  // Add new message under messages/
  await _messagesRef.push().set({
    'sender': _currentUsername,
    'text': text,
    'timestamp': timestamp,
  });

  _controller.clear();
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            widget.username,
            style: const TextStyle(color: Color(0xFFFFBA76)),
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFFFFBA76)),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream: _messagesRef.orderByChild('timestamp').onValue,
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                  return const Center(child: Text("No messages yet."));
                }

                Map data = snapshot.data!.snapshot.value as Map;
                final messages = data.entries.toList()
                  ..sort((a, b) =>
                      (a.value['timestamp'] as int).compareTo(b.value['timestamp'] as int));

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index].value;
                    final isCurrentUser = msg['sender'] == _currentUsername;

                    return Align(
                      alignment:
                          isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isCurrentUser
                              ? Colors.deepPurple[100]
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(msg['text'] ?? ''),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration.collapsed(
                      hintText: "Type a message...",
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.deepPurple),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
