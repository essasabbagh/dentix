import 'package:flutter/material.dart';

import 'package:template/core/locale/generated/l10n.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).termsAndConditions),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            'Your terms and conditions content goes here. '
            'This is a placeholder text for the terms and conditions of app. '
            'Please replace it with your actual terms and conditions.',
            style: TextStyle(fontSize: 16.0),
          ),
        ),
      ),
    );
  }
}
