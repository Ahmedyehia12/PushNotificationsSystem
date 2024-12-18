import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ChatRoomPage extends StatefulWidget {
  final String channelName;
  final String userId;
  //aaaaaa
  const ChatRoomPage(
      {super.key, required this.channelName, required this.userId});

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final TextEditingController _messageController = TextEditingController();
  final DatabaseReference _messagesRef = FirebaseDatabase.instance
      .ref()
      .child('messages'); // Firebase Realtime Database reference

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.channelName), // Chatroom channel name
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder(
              stream: _messagesRef.child(widget.channelName).onValue,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return const Center(
                    child: Text('An error occurred. Please try again.'),
                  );
                }

                final data = snapshot.data?.snapshot.value
                    as Map<dynamic, dynamic>?; // Data from Firebase

                if (data == null) {
                  // Handle case where there are no messages
                  return const Center(
                    child: Text('No messages yet. Start the conversation!'),
                  );
                }

                final messages = <Map<String, dynamic>>[];

                // Extract messages from the Firebase data
                data.forEach((key, value) {
                  messages.add({
                    'message': value['message'] as String,
                    'userId': value['userId'] as String,
                  });
                });

                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return ListTile(
                      leading: Text(message['userId']), // Display userId
                      title: Text(message['message']), // Display message text
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Enter a message',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    final message = _messageController.text.trim();

                    if (message.isNotEmpty) {
                      _messagesRef.child(widget.channelName).push().set({
                        'message': message, // Message text
                        'userId': widget.userId, // User ID
                      });
                      _messageController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
