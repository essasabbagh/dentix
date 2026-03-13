import 'package:flutter/material.dart';

import '../constants/onboarding_constants.dart';
import '../pages.dart';

class PageIndicator extends StatelessWidget {
  const PageIndicator({super.key, required this.currentPage});

  final int currentPage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(pages(context).length, (index) {
        return AnimatedContainer(
          curve: onboardingCurves,
          duration: onboardingDuration,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: currentPage == index ? maxSize : minSize,
          height: currentPage == index ? maxSize : minSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: currentPage == index
                ? theme.primaryColor
                : theme.disabledColor,
          ),
        );
      }),
    );
  }
}
