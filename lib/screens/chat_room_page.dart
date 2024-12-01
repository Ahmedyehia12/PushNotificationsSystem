import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ChatRoomPage extends StatefulWidget {
  final String channelName;
  final String userId;
  const ChatRoomPage(
      {super.key, required this.channelName, required this.userId});
  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final TextEditingController _messageController = TextEditingController();
  final DatabaseReference _messagesRef =
      FirebaseDatabase.instance.ref().child('messages');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.channelName),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder(
              stream: _messagesRef.child(widget.channelName).onValue,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                final messages = <String>[];
                final data = snapshot.data?.snapshot.value as Map<dynamic, dynamic>?;
                if (data != null) {
                  data.forEach((key, value) {
                    messages.add(value['message'] as String);
                  });
                }
                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(messages[index]),
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
                    _messagesRef.child(widget.channelName).push().set({
                      'message': _messageController.text,
                      'userId': widget.userId,
                    });
                    _messageController.clear();
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