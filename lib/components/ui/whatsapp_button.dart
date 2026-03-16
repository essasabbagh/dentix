import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';

import 'package:dentix/core/utils/snackbars.dart';

/// A reusable button that opens WhatsApp with a prefilled message.
///
/// Features:
/// - Supports Turkish phone numbers automatically
/// - Cleans phone numbers from spaces and symbols
/// - Opens WhatsApp app directly if installed
/// - Falls back to WhatsApp web if needed
class WhatsAppButton extends StatelessWidget {
  const WhatsAppButton({
    super.key,
    required this.phone,
    required this.message,
    this.label = 'إرسال عبر واتساب',
    this.isIconOnly = true,
  });

  /// Phone number of the receiver
  final String phone;

  /// Message to send
  final String message;

  /// Button label (used when not icon-only)
  final String label;

  /// If true → show only icon button
  final bool isIconOnly;

  /// Normalize phone number to international format
  ///
  /// Examples:
  /// 0505026612  -> 90505026612
  /// 505026612   -> 90505026612
  String _normalizePhone(String phone) {
    // Remove any non-digit characters
    var cleanPhone = phone.replaceAll(RegExp(r'\D'), '');

    // Turkish number starting with 0
    if (cleanPhone.startsWith('0') && cleanPhone.length == 11) {
      return '9$cleanPhone';
    }

    // Turkish number without leading zero
    if (cleanPhone.length == 10) {
      return '90$cleanPhone';
    }

    return cleanPhone;
  }

  /// Build WhatsApp deep link
  Uri _buildWhatsAppUri(String phone, String message) {
    final encodedMessage = Uri.encodeComponent(message);

    return Uri.parse(
      'whatsapp://send?phone=$phone&text=$encodedMessage',
    );
  }

  /// Build WhatsApp universal web link
  Uri _buildWebUri(String phone, String message) {
    final encodedMessage = Uri.encodeComponent(message);

    return Uri.parse(
      'https://wa.me/$phone?text=$encodedMessage',
    );
  }

  /// Launch WhatsApp with fallback strategy
  Future<void> _launchWhatsApp() async {
    final normalizedPhone = _normalizePhone(phone);

    final whatsappUri = _buildWhatsAppUri(normalizedPhone, message);
    final webUri = _buildWebUri(normalizedPhone, message);

    try {
      /// First try opening the WhatsApp app directly
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(
          whatsappUri,
          mode: LaunchMode.externalApplication,
        );
        return;
      }

      /// Fallback: open WhatsApp web
      if (await canLaunchUrl(webUri)) {
        await launchUrl(
          webUri,
          mode: LaunchMode.externalApplication,
        );
        return;
      }

      /// If neither works
      AppSnackBar.error('تعذر فتح واتساب. تأكد من تثبيت التطبيق.');
    } catch (_) {
      /// Last attempt using web link
      try {
        await launchUrl(
          webUri,
          mode: LaunchMode.externalApplication,
        );
      } catch (_) {
        AppSnackBar.error('حدث خطأ أثناء محاولة فتح واتساب');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isIconOnly) {
      return IconButton(
        tooltip: label,
        onPressed: _launchWhatsApp,
        icon: const Icon(
          Icons.chat_outlined,
          size: 20,
          color: Colors.green,
        ),
      );
    }

    return FilledButton.icon(
      onPressed: _launchWhatsApp,
      style: FilledButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      icon: const Icon(Icons.chat_outlined, size: 18),
      label: Text(label),
    );
  }
}
