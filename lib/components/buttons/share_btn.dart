import 'package:flutter/material.dart';

import 'package:template/configs/app_configs.dart';
import 'package:template/core/utils/share_utils.dart';

class ShareBtn extends StatelessWidget {
  const ShareBtn({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor,
            offset: const Offset(1, 1),
            blurRadius: 10,
          ),
        ],
      ),
      child: IconButton(
        onPressed: () {
          shareText(
            text,
            title: AppConfigs.appName,
            subject: 'Check this out!',
          );
        },
        icon: Icon(Icons.ios_share_rounded, color: theme.iconTheme.color),
      ),
    );
  }
}
