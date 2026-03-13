import 'package:flutter/material.dart';

import 'package:webview_flutter/webview_flutter.dart';

import 'package:template/core/locale/generated/l10n.dart';
import 'package:template/core/utils/snackbars.dart';

class NavigationControls extends StatelessWidget {
  const NavigationControls({
    super.key,
    required this.webViewController,
  });

  final WebViewController webViewController;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () async {
            if (await webViewController.canGoBack()) {
              await webViewController.goBack();
            } else {
              if (context.mounted) {
                AppSnackBar.info(S.of(context).noBackHistoryItem);
              }
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward_ios),
          onPressed: () async {
            if (await webViewController.canGoForward()) {
              await webViewController.goForward();
            } else {
              if (context.mounted) {
                AppSnackBar.info(S.of(context).noForwardHistoryItem);
              }
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.replay),
          onPressed: webViewController.reload,
        ),
      ],
    );
  }
}
