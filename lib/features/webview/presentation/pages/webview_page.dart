import 'package:flutter/material.dart';
class WebviewPage extends StatelessWidget {
  final String url;
  final String title;
  const WebviewPage({super.key, required this.url, required this.title});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text(title)), body: Center(child: Text('WebView: $url')));
}
