import 'package:flutter/material.dart';
export 'forgot_page.dart';
class ForgotPage extends StatelessWidget {
  const ForgotPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Forgot Password')), body: const Center(child: Text('Forgot Page')));
}
