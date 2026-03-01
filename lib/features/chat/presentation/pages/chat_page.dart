import 'package:flutter/material.dart';
class ChatPage extends StatelessWidget {
  final String matchId;
  const ChatPage({super.key, required this.matchId});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text('Chat – Match $matchId')), body: const Center(child: Text('Chat Page – Implement with WebSocket')));
}
