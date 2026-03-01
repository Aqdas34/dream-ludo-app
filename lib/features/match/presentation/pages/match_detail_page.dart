import 'package:flutter/material.dart';
class MatchDetailPage extends StatelessWidget {
  final String matchId;
  const MatchDetailPage({super.key, required this.matchId});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text('Match #$matchId')), body: const Center(child: Text('Match Detail – Implement fully')));
}
