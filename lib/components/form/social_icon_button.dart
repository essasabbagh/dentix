import 'package:flutter/material.dart';

class SocialIconButton extends StatelessWidget {
  const SocialIconButton({
    super.key,
    required this.iconPath,
    required this.onPressed,
    this.iconSize = 30,
    this.containerSize = 55,
  });

  final String iconPath;
  final VoidCallback onPressed;
  final double iconSize;
  final double containerSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: containerSize,
      height: containerSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor,
            offset: const Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        splashRadius: 20,
        icon: Image.asset(
          iconPath,
          width: iconSize,
          height: iconSize,
        ),
      ),
    );
  }
}
