import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:firebase_database/firebase_database.dart';
import 'package:uuid/uuid.dart';

class ChatPage extends StatefulWidget {
  final String tripId;
  final String currentUserId;
  final String otherUserId;

  const ChatPage({
    super.key,
    required this.tripId,
    required this.currentUserId,
    required this.otherUserId,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _messages = <types.Message>[];
  final _dbRef = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    _listenToMessages();
  }

  void _listenToMessages() {
    _dbRef.child('chats/${widget.tripId}').onChildAdded.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      final message = types.TextMessage(
        id: const Uuid().v4(),
        author: types.User(id: data['senderId']),
        createdAt: DateTime.parse(data['timestamp']).millisecondsSinceEpoch,
        text: data['message'],
      );
      setState(() {
        _messages.insert(0, message);
      });
    });
  }

  void _handleSendPressed(types.PartialText message) {
    final msgData = {
      'senderId': widget.currentUserId,
      'receiverId': widget.otherUserId,
      'message': message.text,
      'timestamp': DateTime.now().toIso8601String(),
    };

    print('Sending: $msgData');

    _dbRef.child('chats/${widget.tripId}').push().set(msgData).then((_) {
      print("Message sent!");
    }).catchError((error) {
      print("Error sending message: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Chat(
        messages: _messages,
        onSendPressed: _handleSendPressed,
        user: types.User(id: widget.currentUserId),
      ),
    );
  }
}
