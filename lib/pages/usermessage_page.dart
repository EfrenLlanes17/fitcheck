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
    final ScrollController _scrollController = ScrollController();

  late final DatabaseReference _chatRef;
  late final DatabaseReference _messagesRef;
  String _currentUsername = '';
  String _otheranimal= '';


void _setCurrentAnimal() async {
  
    final snapshot = await FirebaseDatabase.instance
        .ref('users/${widget.username}/pets')
        .get();

    if (snapshot.exists) {
      final petsMap = Map<String, dynamic>.from(snapshot.value as Map);
      final firstPetName = petsMap.keys.first;
      setState(() {
        _otheranimal = firstPetName;
      });
    }
  
}

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
    _setCurrentAnimal();
    
  }

  void createchat() async{
    await _chatRef.child('participants').update({
    widget.username: true,
    _currentUsername: true,
  });
  String pushKey = _chatRef.key.toString();
  FirebaseDatabase.instance.ref().child('users/$_currentUsername/chats/$pushKey/participants').set({
  widget.username: true,
  });

  String otheruser = widget.username;
  FirebaseDatabase.instance.ref().child('users/$otheruser/chats/$pushKey/participants').set({
  _currentUsername: true,
  });

  DatabaseReference ref = FirebaseDatabase.instance.ref().child('users/$otheruser/pets/$_otheranimal/profilepicture');
DataSnapshot snapshot = await ref.get();

String? profileUrl = snapshot.value as String?;


  FirebaseDatabase.instance.ref().child('users/$_currentUsername/chats/$pushKey').update({
  'profilepicture': profileUrl,
  });

   DatabaseReference ref2 = FirebaseDatabase.instance.ref().child('users/$_currentUsername/profilepicture');
    DataSnapshot snapshot2 = await ref2.get();

  String? profileUrl2 = snapshot2.value as String?;


  FirebaseDatabase.instance.ref().child('users/$otheruser/chats/$pushKey').update({
  'profilepicture': profileUrl2,
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
    _scrollController.dispose();

    super.dispose();
  }

  void _sendMessage() async {
  final text = _controller.text.trim();
  if (text.isEmpty) return;
  String otheruser = widget.username;
  String pushKey = _chatRef.key.toString();
  final timestamp = DateTime.now().millisecondsSinceEpoch;

  // Ensure participants are written once (optional: move to chat creation logic)
  

  // Add new message under messages/
  await _messagesRef.push().set({
    'sender': _currentUsername,
    'text': text,
    'timestamp': timestamp,
  });

  


  FirebaseDatabase.instance.ref().child('users/$_currentUsername/chats/$pushKey').update({
  'lastmessage': text,
  'sender': _currentUsername,
  'timestamp': timestamp,

  });


  FirebaseDatabase.instance.ref().child('users/$otheruser/chats/$pushKey').update({
  'lastmessage': text,
  'timestamp': timestamp,
  'sender': _currentUsername

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

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                  }
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index].value;
                    final isCurrentUser = msg['sender'] == _currentUsername;

                    return Align(
                      alignment:
                          isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        decoration: BoxDecoration(
                          color: isCurrentUser
                              ? const Color(0xFFFFBA76)
                              : Colors.grey[200],
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(isCurrentUser ? 16 : 0),
                            bottomRight: Radius.circular(isCurrentUser ? 0 : 16),
                          ),
                        ),
                        child: Text(
                          msg['text'] ?? '',
                          style: TextStyle(
                            color: isCurrentUser ? Colors.white : Colors.black87,
                            fontSize: 16,
                          ),
                        ),
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
    hintStyle: TextStyle(
      color: Color(0xFFFFBA76),
      fontWeight: FontWeight.w500,
    ),
  ),
  style: const TextStyle(
    color: Color(0xFFFFBA76),
    fontWeight: FontWeight.w600,
  ),
  cursorColor: Color(0xFFFFBA76),
  onSubmitted: (_) => _sendMessage(),
),

                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFFFFBA76)),
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
