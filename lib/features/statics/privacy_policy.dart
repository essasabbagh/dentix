import 'package:flutter/material.dart';

import 'package:template/core/locale/generated/l10n.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).privacyPolicy),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            'Your privacy policy content goes here. '
            'This is a placeholder text for the privacy policy of your app. '
            'Please replace it with your actual privacy policy.',
            style: TextStyle(fontSize: 16.0),
          ),
        ),
      ),
    );
  }
}
