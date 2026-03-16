//
import 'package:flutter/material.dart';

import 'package:share_plus/share_plus.dart';

import 'package:dentix/core/constants/keys.dart';
import 'package:dentix/core/utils/app_log.dart';

Future<void> shareText(String text, {String? title, String? subject}) async {
  try {
    final RenderBox? box =
        rootNavigatorKey.currentContext!.findRenderObject() as RenderBox?;

    final result = await SharePlus.instance.share(
      ShareParams(
        title: title,
        subject: subject,
        text: text,

        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
      ),
    );

    if (result.status == ShareResultStatus.success) {
      AppLog.success('Share successful');
    }
  } catch (e) {
    AppLog.error('Error sharing text: $e');
  }
}

Future<void> shareFile(
  String? text, {
  String? title,
  String? subject,
  required XFile xfile,
}) async {
  try {
    final RenderBox? box =
        rootNavigatorKey.currentContext!.findRenderObject() as RenderBox?;

    final params = ShareParams(
      text: text,
      title: title,
      subject: subject,
      files: [xfile],
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );

    final result = await SharePlus.instance.share(params);

    if (result.status == ShareResultStatus.success) {
      AppLog.success('Share successful');
    }
  } catch (e) {
    AppLog.error('Error sharing file: $e');
  }
}
