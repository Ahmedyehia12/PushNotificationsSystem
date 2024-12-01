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
      FirebaseDatabase.instance.ref().child('messages');   // this is the reference to the Firebase Realtime Database instance in the messages node
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.channelName),  // this is the name of the channel
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder( // streamBuilder widget listens to the stream of messages in the channel
              stream: _messagesRef.child(widget.channelName).onValue, // the value to be updated in the stream
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                final messages = <String>[];
                final data = snapshot.data?.snapshot.value as Map<dynamic, dynamic>?; // snapshot: the data that is being streamed from the database
                if (data != null) {
                  data.forEach((key, value) {
                    messages.add(value['message'] as String); // here we are adding the message to the list of messages
                  });
                }
                return ListView.builder(  // this is the list of messages
                  itemCount: messages.length, // the number of messages
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(messages[index]), // the message
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
                    _messagesRef.child(widget.channelName).push().set({ // this is the message that is being sent to the database, to the /messages/channelName node, this will rebuild the streamBuilder widget
                      'message': _messageController.text, // the message
                      'userId': widget.userId, // the user id
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