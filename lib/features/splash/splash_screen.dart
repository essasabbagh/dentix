import 'package:flutter/material.dart';

import 'package:template/components/loading/loading_widget.dart';
import 'package:template/components/main/logo.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Logo(),
            SizedBox(height: 32),
            LoadingWidget(),
          ],
        ),
      ),
    );
  }
}
