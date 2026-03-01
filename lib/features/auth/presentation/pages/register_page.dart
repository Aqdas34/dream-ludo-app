import 'package:flutter/material.dart';
import 'package:dream_ludo/core/theme/app_theme.dart';

class RegisterPage extends StatelessWidget {
  final Map<String, String>? prefillData;
  const RegisterPage({super.key, this.prefillData});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Create Account')),
        body: const Center(child: Text('Register Page – Implement fully')),
      );
}
