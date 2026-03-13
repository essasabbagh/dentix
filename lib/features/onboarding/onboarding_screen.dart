import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:template/components/main/main_appbar.dart';
import 'package:template/core/locale/generated/l10n.dart';
import 'package:template/features/settings/widgets/locale_button.dart';

import 'pages.dart';
import 'provider/onboarding_provider.dart';
import 'widgets/onboarding_page_widget.dart';
import 'widgets/page_indicator.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPage = ref.watch(onboardingProvider);
    final onboardingNotifier = ref.read(onboardingProvider.notifier);

    return Scaffold(
      appBar: const PureAppBar(
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: LocaleButton(),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PageIndicator(currentPage: currentPage),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: onboardingNotifier.nextPage,
                    child: Text(
                      onboardingNotifier.isLastPage
                          ? S.of(context).getStarted
                          : S.of(context).next,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: onboardingNotifier.skip,
                    child: Text(S.of(context).skip),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: PageView.builder(
        itemCount: pages(context).length,
        controller: onboardingNotifier.pageController,
        onPageChanged: onboardingNotifier.setPage,
        itemBuilder: (context, index) {
          return OnboardingPage(pageData: pages(context)[index]);
        },
      ),
    );
  }
}
