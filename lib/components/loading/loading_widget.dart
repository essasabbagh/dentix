import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key, this.color});

  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator.adaptive(
        strokeWidth: 2,
        strokeCap: StrokeCap.round,
        valueColor: AlwaysStoppedAnimation<Color?>(color),
      ),
    );
  }
}
