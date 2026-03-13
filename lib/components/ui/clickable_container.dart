import 'package:flutter/material.dart';

class ClickableContainer extends StatelessWidget {
  const ClickableContainer({
    super.key,
    required this.child,
    this.onTap,
    this.color = Colors.white,
    this.radius = 12,
    this.width,
    this.height,
    this.shadow = const [
      BoxShadow(
        color: Color(0x14000000),
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
    ],
    this.padding,
    this.margin,
  });

  final Widget child;
  final VoidCallback? onTap;
  final Color color;
  final double radius;
  final double? width;
  final double? height;
  final List<BoxShadow> shadow;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: shadow,
      ),
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        child: InkWell(
          borderRadius: BorderRadius.circular(radius),
          onTap: onTap,
          child: Padding(
            padding: padding ?? EdgeInsets.zero,
            child: child,
          ),
        ),
      ),
    );
  }
}
