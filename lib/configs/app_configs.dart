import 'package:flutter/foundation.dart';

class AppConfigs {
  static const String appName = 'App Name';
  static const String baseDomin = 'https://jsonplaceholder.typicode.com';
  static const String baseUrl = '$baseDomin/todos';
  static const String topic = kDebugMode ? 'debug' : 'general';
  static const Duration period = Duration(seconds: 1);
  static const int perPage = 10;

  static const int pinDigitLength = 6;
  static const int passwordMinLength = 8;
  static const int veryStrongPasswordLength = 12;

  // Terms of Service link
  static const String termsOfServiceUrl = '$baseUrl/terms-of-service';
  // Privacy Policy link
  static const String privacyPolicyUrl = '$baseUrl/privacy-policy';

  static const googlePlayUrl = 'https://play.google.com/';
  static const appleStoreUrl = 'https://apps.apple.com/';

  // font family
  static const String fontFamily = 'Poppins';
  static const defaultLocale = 'ar';
  static final supportedLocales = [
    {'locale': 'ar', 'name': 'عربي', 'icon': '🇵🇸'},
    {'locale': 'en', 'name': 'English', 'icon': '🇺🇸'},
  ];

  // static List<String> pagesWithoutNavBar = [
  //   // AppRoutes.courses.path,
  //   // AppRoutes.consultations.path,
  //   AppRoutes.courseDetail.name,
  //   AppRoutes.lesson.name,
  // ];

  // Define your Arabic countries
  static const List<String> arabicCountries = [
    'SA', // Saudi Arabia
    'AE', // United Arab Emirates
    'JO', // Jordan
    'KW', // Kuwait
    'OM', // Oman
    'QA', // Qatar
    'BH', // Bahrain
    'LB', // Lebanon
    'EG', // Egypt
    'PS', // Palestine
    'AE', // United Arab Emirates
    'SY', // Syria
    'YE', // Yemen
    // Add more countries as needed
  ];
}
