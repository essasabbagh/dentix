import 'package:flutter/material.dart';

import 'package:template/core/constants/images.dart';
import 'package:template/core/locale/generated/l10n.dart';

import 'models/onboarding_model.dart';

List<OnboardingPageData> pages(BuildContext context) {
  return [
    OnboardingPageData(
      title: S.current.onboardingTitle1,
      description: S.current.onboardingDescription1,
      imagePath: AppImages.imagesOnboardingOnboarding,
    ),
    OnboardingPageData(
      title: S.current.onboardingTitle2,
      description: S.current.onboardingDescription2,
      imagePath: AppImages.imagesOnboardingOnboarding1,
    ),
    OnboardingPageData(
      title: S.current.onboardingTitle3,
      description: S.current.onboardingDescription3,
      imagePath: AppImages.imagesOnboardingOnboarding2,
    ),
  ];
}
