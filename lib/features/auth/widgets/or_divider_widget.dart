import 'package:flutter/material.dart';

class OrDivider extends StatelessWidget {
  const OrDivider({
    super.key,
    required this.text,
    this.color = const Color(0xFF3D5670),
  });
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 45,
          child: Divider(thickness: 1, color: color, endIndent: 12),
        ),
        Text(
          text,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
        SizedBox(
          width: 45,
          child: Divider(thickness: 1, color: color, indent: 12),
        ),
      ],
    );
  }
}
