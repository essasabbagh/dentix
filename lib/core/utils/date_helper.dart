import 'package:intl/intl.dart';

import 'package:template/core/locale/generated/l10n.dart';

class DateHelper {
  /// Formats a [DateTime] object into a string based on the provided [pattern].
  /// Defaults to `'EEE, MMMM - dd/MM/y'` if no pattern is provided.
  /// If [useEnglishNumbers] is `true`, it forces English numerals.
  static String format(
    DateTime? date, {
    String pattern = 'EEE, MMMM - dd/MM/y',
    bool useEnglishNumbers = true,
    String locale = 'ar',
  }) {
    if (date == null) return 'No Date';
    // Replace with S.current.noDate if using localization

    // Syrian month names mapping
    final syrianMonthNames = {
      1: 'كانون الثاني',
      2: 'شباط',
      3: 'آذار',
      4: 'نيسان',
      5: 'أيار',
      6: 'حزيران',
      7: 'تموز',
      8: 'آب',
      9: 'أيلول',
      10: 'تشرين الأول',
      11: 'تشرين الثاني',
      12: 'كانون الأول',
    };

    String formattedDate = DateFormat(pattern, locale).format(date);

    if (pattern.contains('MMMM')) {
      // Replace standard Arabic month with Syrian month name
      final standardMonthName = DateFormat('MMMM', 'ar').format(date);
      final syrianMonthName = syrianMonthNames[date.month] ?? standardMonthName;
      formattedDate = formattedDate.replaceAll(
        standardMonthName,
        syrianMonthName,
      );
    }

    // Replace Arabic numerals with English if needed
    if (useEnglishNumbers) {
      const arabicNumbers = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
      const englishNumbers = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];

      for (int i = 0; i < 10; i++) {
        formattedDate = formattedDate.replaceAll(
          arabicNumbers[i],
          englishNumbers[i],
        );
      }
    }

    return formattedDate;
  }

  static String time(DateTime? date) {
    if (date == null) return '-'; // default to the current time
    return DateFormat('hh:mm a').format(date.toLocal());
  }

  /// Provides a human-readable representation of
  /// the time elapsed since a given DateTime.
  static String timeAgo(DateTime date) {
    final lang = S.current;
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 5) {
      return lang.justNow;
    } else if (difference.inSeconds < 60) {
      return lang.secondsAgo(difference.inSeconds);
    } else if (difference.inMinutes < 60) {
      return lang.minutesAgo(difference.inMinutes);
    } else if (difference.inHours < 24) {
      return lang.hoursAgo(difference.inHours);
    } else if (difference.inDays < 7) {
      return lang.daysAgo(difference.inDays);
    } else if (difference.inDays < 30) {
      final weeks = difference.inDays ~/ 7;
      return lang.weeksAgo(weeks);
    } else if (difference.inDays < 365) {
      final months = difference.inDays ~/ 30;
      return lang.monthsAgo(months);
    } else {
      final years = difference.inDays ~/ 365;
      return lang.yearsAgo(years);
    }
  }
}
