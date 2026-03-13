import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:go_transitions/go_transitions.dart';

import 'app_colors.dart';
import 'app_fonts.dart';

const double inputBorderRadius = 12.0;
const double elevatedButtonBorderRadius = 32.0;
const double dialogBorderRadius = 12.0;
const double bottomSheetBorderRadius = 12.0;

class AppThemes {
  static ThemeData lightTheme = ThemeData(
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primaryColor,
      onPrimary: AppColors.primary500,
      secondary: AppColors.secondaryColor,
      onSecondary: AppColors.secondaryColor,
      error: AppColors.error600,
      onError: AppColors.error600,
      surface: AppColors.white,
      onSurface: AppColors.gray700,
    ),

    buttonTheme: ButtonThemeData(
      buttonColor: AppColors.primaryColor,
      textTheme: ButtonTextTheme.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(elevatedButtonBorderRadius),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 8.0,
        shadowColor: AppColors.shadowColor,
        backgroundColor: AppColors.primary50,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(elevatedButtonBorderRadius),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontFamily: AppFont.fontFamily,
          color: AppColors.primary700,
          // fontWeight: FontWeight.bold,
        ),
      ),
    ),

    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: GoTransitions.fadeUpwards,
        TargetPlatform.iOS: GoTransitions.cupertino,
      },
    ),
    fontFamily: AppFont.fontFamily,
    primaryColor: AppColors.primaryColor,
    primaryColorLight: AppColors.primary200,
    primaryColorDark: AppColors.primary700,
    secondaryHeaderColor: AppColors.secondaryColor,
    scaffoldBackgroundColor: AppColors.white,
    shadowColor: AppColors.shadowColor,
    canvasColor: AppColors.surfaceColor,
    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(dialogBorderRadius),
      ),
    ),

    bottomSheetTheme: const BottomSheetThemeData(
      showDragHandle: true,
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(bottomSheetBorderRadius),
        ),
      ),
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primary50,
      surfaceTintColor: AppColors.backgroundColor,
      titleTextStyle: const TextStyle(
        color: AppColors.gray900,
        fontSize: 16,
        fontFamily: AppFont.fontFamily,
        fontWeight: FontWeight.bold,
      ),
      shape: const ContinuousRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.elliptical(48, 64),
          bottomRight: Radius.elliptical(48, 64),
        ),
      ),
      iconTheme: const IconThemeData(color: AppColors.gray700),
      systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.dark,
        systemStatusBarContrastEnforced: false,

        systemNavigationBarColor: AppColors.primary50,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarContrastEnforced: true,
      ),
    ),

    dropdownMenuTheme: const DropdownMenuThemeData(
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(inputBorderRadius)),
          borderSide: BorderSide(color: AppColors.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(inputBorderRadius)),
          borderSide: BorderSide(color: AppColors.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(inputBorderRadius)),
          borderSide: BorderSide(color: AppColors.primary700, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(inputBorderRadius)),
          borderSide: BorderSide(color: AppColors.error600, width: 2),
        ),
      ),
    ),

    inputDecorationTheme: const InputDecorationTheme(
      contentPadding: EdgeInsets.symmetric(horizontal: 14),
      filled: true,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(inputBorderRadius)),
        borderSide: BorderSide(color: AppColors.borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(inputBorderRadius)),
        borderSide: BorderSide(color: AppColors.primary700, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(inputBorderRadius)),
        borderSide: BorderSide(color: AppColors.error600, width: 2),
      ),
      hintStyle: TextStyle(
        color: AppColors.hintColor,
        fontSize: 14,
        fontWeight: FontWeight.w300,
      ),
      prefixIconColor: AppColors.gray300,
    ),

    expansionTileTheme: const ExpansionTileThemeData(
      collapsedShape: RoundedRectangleBorder(side: BorderSide.none),
      shape: RoundedRectangleBorder(side: BorderSide.none),
    ),

    sliderTheme: SliderThemeData(
      trackHeight: 4.0,
      thumbColor: AppColors.secondary500,
      activeTrackColor: AppColors.secondary500,
      inactiveTrackColor: AppColors.secondary50,
      disabledActiveTrackColor: Colors.grey.shade300,
      trackShape: const RoundedRectSliderTrackShape(),
      thumbShape: const RoundSliderThumbShape(
        pressedElevation: 8.0,
        enabledThumbRadius: 12.0,
      ),
      showValueIndicator: ShowValueIndicator.onDrag,
      overlayShape: const RoundSliderOverlayShape(overlayRadius: 24.0),
      tickMarkShape: const RoundSliderTickMarkShape(),
      inactiveTickMarkColor: AppColors.white,
      valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
      valueIndicatorTextStyle: const TextStyle(
        color: AppColors.white,
        fontSize: 20.0,
      ),
    ),

    tabBarTheme: const TabBarThemeData(dividerColor: AppColors.gray100),

    cardTheme: const CardThemeData(
      color: AppColors.gray50,
      shadowColor: AppColors.shadowColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.primaryColor,
      onPrimary: AppColors.primary500,
      secondary: AppColors.secondaryColor,
      onSecondary: AppColors.secondaryColor,
      error: AppColors.error600,
      onError: AppColors.error600,
      surface: AppColors.gray900,
      onSurface: AppColors.gray200,
    ),
    fontFamily: AppFont.fontFamily,
    primaryColor: AppColors.primaryColor,
    primaryColorLight: AppColors.primary300,
    primaryColorDark: AppColors.primary800,
    secondaryHeaderColor: AppColors.secondaryColor,
    scaffoldBackgroundColor: AppColors.gray900,

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: AppColors.primary900,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(elevatedButtonBorderRadius),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontFamily: AppFont.fontFamily,
          color: AppColors.primary50,
          // fontWeight: FontWeight.bold,
        ),
      ),
    ),

    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: GoTransitions.fadeUpwards,
        TargetPlatform.iOS: GoTransitions.cupertino,
      },
    ),
    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(dialogBorderRadius),
      ),
      backgroundColor: AppColors.gray800,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      showDragHandle: true,
      backgroundColor: AppColors.gray900,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(bottomSheetBorderRadius),
        ),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primary900,
      surfaceTintColor: AppColors.gray900,
      systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
        systemStatusBarContrastEnforced: false,

        systemNavigationBarColor: AppColors.primary900,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarContrastEnforced: true,
      ),
      iconTheme: const IconThemeData(color: AppColors.gray50),
      titleTextStyle: const TextStyle(
        fontSize: 16,
        fontFamily: AppFont.fontFamily,
        fontWeight: FontWeight.bold,
        color: AppColors.backgroundColor,
      ),
      shape: const ContinuousRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.elliptical(48, 64),
          bottomRight: Radius.elliptical(48, 64),
        ),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      contentPadding: EdgeInsets.symmetric(horizontal: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(inputBorderRadius)),
        borderSide: BorderSide(color: AppColors.borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(inputBorderRadius)),
        borderSide: BorderSide(color: AppColors.borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(inputBorderRadius)),
        borderSide: BorderSide(color: AppColors.primary700, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(inputBorderRadius)),
        borderSide: BorderSide(color: AppColors.error600, width: 2),
      ),
    ),
    expansionTileTheme: const ExpansionTileThemeData(
      collapsedShape: RoundedRectangleBorder(side: BorderSide.none),
      shape: RoundedRectangleBorder(side: BorderSide.none),
    ),
    sliderTheme: const SliderThemeData(
      trackHeight: 4.0,
      thumbColor: AppColors.secondary500,
      activeTrackColor: AppColors.secondary500,
      inactiveTrackColor: AppColors.secondary50,
      disabledActiveTrackColor: AppColors.gray700,
      trackShape: RoundedRectSliderTrackShape(),
      thumbShape: RoundSliderThumbShape(
        pressedElevation: 8.0,
        enabledThumbRadius: 12.0,
      ),
      showValueIndicator: ShowValueIndicator.onDrag,
      overlayShape: RoundSliderOverlayShape(overlayRadius: 24.0),
      tickMarkShape: RoundSliderTickMarkShape(),
      inactiveTickMarkColor: AppColors.white,
      valueIndicatorShape: PaddleSliderValueIndicatorShape(),
      valueIndicatorTextStyle: TextStyle(
        color: AppColors.white,
        fontSize: 20.0,
      ),
    ),
    tabBarTheme: const TabBarThemeData(dividerColor: AppColors.gray100),
    cardTheme: const CardThemeData(
      color: AppColors.gray800,
      shadowColor: AppColors.shadowColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      menuStyle: MenuStyle(
        backgroundColor: WidgetStateProperty.all(Colors.white),
        elevation: WidgetStateProperty.all(4),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    ),
  );
}
