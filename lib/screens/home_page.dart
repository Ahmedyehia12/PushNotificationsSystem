import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_room_page.dart';

class HomePage extends StatefulWidget {
 const  HomePage({super.key, required this.userId});
  final String userId;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final Set<String> _subscribedChannels = {};

  @override
  void initState(){
    super.initState();
    setUpPushNotifications();
    loadUserSubscriptions();
  }

  Future<List<String>> getChannels() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('channels').get();
    return snapshot.docs.map((doc) => doc.data()['name'] as String).toList();
  }

  Future<List<String>> getUserSubscriptions(String userId) async {
    final snapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return snapshot.data()?['channels']?.cast<String>() ?? [];
  }

  Future<void> updateUserSubscriptions(
      String userId, List<String> channels) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).set({
      'channels': channels,
    });
  }

  Future<void> loadUserSubscriptions() async {
    final subscriptions = await getUserSubscriptions(widget.userId);
    setState(() {
      _subscribedChannels.addAll(subscriptions);
    });
  }

  void _subscribeToChannel(String channel) async {
    await _fcm.subscribeToTopic(channel);
    setState(() {
      _subscribedChannels.add(channel);
    });
    await updateUserSubscriptions(widget.userId, _subscribedChannels.toList());
  }

  void _unsubscribeFromChannel(String channel) async {
    await _fcm.unsubscribeFromTopic(channel);
    setState(() {
      _subscribedChannels.remove(channel);
    });
    await updateUserSubscriptions(widget.userId, _subscribedChannels.toList());
  }

  void setUpPushNotifications() async {
    await _fcm.requestPermission(); //request permissions to send notifications
    final token = await _fcm.getToken();
    print("FCM Token: $token"); // get the token for the device to test notifications

    FirebaseMessaging.onMessage.listen((message) { // listen to the messages that are being sent
      print("Foreground Notification: ${message.notification?.title}"); 
      showDialog( // show a dialog with the notification title and body
        context: context, 
        builder: (context) => AlertDialog(
          title: Text(message.notification?.title ?? 'Notification'),
          content: Text(message.notification?.body ?? 'No body'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler); 
  }

  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    print("Background Notification: ${message.notification?.title}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FlutterChat'),
        backgroundColor: Colors.cyan[800],
      ),
      backgroundColor: Colors.cyan[50],
      body: FutureBuilder<List<String>>(
        future: getChannels(), // when this function is done, the futureBuilder will rebuild
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No channels available.'));
          } else {
            final channels = snapshot.data!;
            return ListView.builder(
              itemCount: channels.length,
              itemBuilder: (context, index) {
                final channel = channels[index];
                final isSubscribed = _subscribedChannels.contains(channel);
                return ListTile(
                  title: Text(channel),
                  trailing: ElevatedButton(
                    onPressed: () {
                      if (isSubscribed) {
                        _unsubscribeFromChannel(channel);
                      } else {
                        _subscribeToChannel(channel);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSubscribed ? Colors.red : Colors.green,
                    ),
                    child: Text(isSubscribed ? 'Unsubscribe' : 'Subscribe'),
                  ),
                  onTap: () {
                    // Navigate to the chat room when tapping the channel
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatRoomPage(
                          channelName: channel,
                          userId: widget.userId,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
