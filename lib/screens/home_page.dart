import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final List<String> _channels = ['Sports', 'News', 'Technology'];
  final Set<String> _subscribedChannels = {};
  @override
  void initState() {
    super.initState();
    setUpPushNotifications();
  }

  void _subscribeToChannel(String channel) async {
    await _fcm.subscribeToTopic(channel);
    setState(() {
      _subscribedChannels.add(channel); // will update the UI
    });
    print('Subscribed to $channel');
  }

  void _unsubscribeFromChannel(String channel) async {
    await _fcm.unsubscribeFromTopic(channel);
    setState(() {
      _subscribedChannels.remove(channel);
    });
    print('Unsubscribed from $channel');
  }

  void setUpPushNotifications() async {
    await _fcm.requestPermission();

    // Retrieve the token
    final token = await _fcm.getToken();
    print("FCM Token: $token");

    // Handle foreground notifications
    FirebaseMessaging.onMessage.listen((message) {
      print("Foreground Notification: ${message.notification?.title}");
      showDialog(
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

    // Handle background notifications
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  // Background message handler
  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    print("Background Notification: ${message.notification?.title}");
    // this will be called when the app is in the background, just like a push notification
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FlutterChat'),
        backgroundColor: Colors.cyan[800],
      ),
      backgroundColor: Colors.cyan[50],
      body: ListView.builder(
        itemCount: _channels.length,
        itemBuilder: (context, index) {
          final channel = _channels[index];
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
          );
        },
      ),
    );
  }
}
