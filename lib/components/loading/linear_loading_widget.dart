import 'package:flutter/material.dart';

class LinearLoadingWidget extends StatelessWidget {
  const LinearLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LinearProgressIndicator(
      color: theme.scaffoldBackgroundColor,
      backgroundColor: theme.scaffoldBackgroundColor,
      valueColor: AlwaysStoppedAnimation(theme.primaryColor),
    );
  }
}
