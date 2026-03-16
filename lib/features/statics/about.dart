import 'package:flutter/material.dart';

import 'package:dentix/core/locale/generated/l10n.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          S.of(context).aboutApp,
        ),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            'This is the about page of your application. '
            'Here you can provide information about the app, its features, '
            'and any other relevant details.',
            style: TextStyle(fontSize: 16.0),
          ),
        ),
      ),
    );
  }
}
