import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dream_ludo/core/theme/app_theme.dart';

class UpdateAppPage extends StatelessWidget {
  final Map<String, String>? updateData;
  const UpdateAppPage({super.key, this.updateData});

  @override
  Widget build(BuildContext context) {
    final isForced = (updateData?['forceUpdate'] ?? '0') == '1';
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.system_update, size: 80, color: AppColors.primary),
              const SizedBox(height: 24),
              Text('Update Available', style: AppTextStyles.heading1),
              const SizedBox(height: 12),
              Text(updateData?['whatsNew'] ?? '', style: AppTextStyles.body, textAlign: TextAlign.center),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () async {
                  final url = updateData?['updateUrl'] ?? '';
                  if (url.isNotEmpty) launchUrl(Uri.parse(url));
                },
                child: const Text('Update Now'),
              ),
              if (!isForced) ...[
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Skip'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
