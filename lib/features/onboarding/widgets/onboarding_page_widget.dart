import 'package:flutter/material.dart';

import 'package:template/core/extensions/extensions.dart';

import '../models/onboarding_model.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key, required this.pageData});

  final OnboardingPageData pageData;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  // Image animations
  late Animation<double> _imageOpacity;
  late Animation<Offset> _imageSlide;
  late Animation<double> _imageScale;

  // Title animations
  late Animation<double> _titleOpacity;
  late Animation<Offset> _titleSlide;

  // Description animations
  late Animation<double> _descriptionOpacity;
  late Animation<Offset> _descriptionSlide;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller with 1.5 second total duration
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Image animations (starts first - 0 to 0.5)
    _imageOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _imageSlide =
        Tween<Offset>(
          begin: const Offset(0.0, 0.25),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
          ),
        );

    _imageScale = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    // Title animations (0.3 to 0.7 - overlapping with image)
    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
      ),
    );

    _titleSlide =
        Tween<Offset>(
          begin: const Offset(0.0, 0.3),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
          ),
        );

    // Description animations (0.6 to 1.0 - starts as title is almost finished)
    _descriptionOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );

    _descriptionSlide =
        Tween<Offset>(
          begin: const Offset(0.0, 0.3),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
          ),
        );

    // Start the animation automatically when page is shown
    _animationController.forward();
  }

  @override
  void didUpdateWidget(OnboardingPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Restart animation when page data changes (user swipes to new page)
    if (widget.pageData != oldWidget.pageData) {
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated Image
          FadeTransition(
            opacity: _imageOpacity,
            child: SlideTransition(
              position: _imageSlide,
              child: ScaleTransition(
                scale: _imageScale,
                child: widget.pageData.imagePath.isNotEmpty
                    ? Image.asset(
                        widget.pageData.imagePath,
                        height: context.width / 2,
                      )
                    : const SizedBox(height: 250, child: Placeholder()),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Animated Title
          FadeTransition(
            opacity: _titleOpacity,
            child: SlideTransition(
              position: _titleSlide,
              child: Text(
                widget.pageData.title,
                style: textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Animated Description
          FadeTransition(
            opacity: _descriptionOpacity,
            child: SlideTransition(
              position: _descriptionSlide,
              child: Text(
                widget.pageData.description,
                style: textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
