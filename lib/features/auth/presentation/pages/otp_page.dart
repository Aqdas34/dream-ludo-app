import 'package:flutter/material.dart';

class OtpPage extends StatelessWidget {
  final String mobile;
  final String pageKey;
  const OtpPage({super.key, required this.mobile, required this.pageKey});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('OTP Verification')),
        body: Center(child: Text('OTP Page for $mobile – Implement fully')),
      );
}
