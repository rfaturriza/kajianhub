import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quranku/core/constants/font_constants.dart';
import 'package:quranku/core/utils/themes/color_schemes_material.dart';

import 'text.dart';

ThemeData themeData({
  required bool isDarkMode,
  required ColorScheme? colorScheme,
}) {
  final lightColorScheme = MaterialTheme.lightScheme().toColorScheme();
  final darkColorScheme = MaterialTheme.darkScheme().toColorScheme();
  final defaultColor =
      isDarkMode ? darkColorScheme.onPrimary : lightColorScheme.onPrimary;
  final primaryColor =
      isDarkMode ? darkColorScheme.primary : lightColorScheme.primary;
  final secondaryColor =
      isDarkMode ? darkColorScheme.secondary : lightColorScheme.secondary;
  final textTheme = textThemeStyle(isDarkMode: isDarkMode);
  return ThemeData(
    useMaterial3: true,
    colorScheme:
        colorScheme ?? (isDarkMode ? darkColorScheme : lightColorScheme),
    iconTheme: IconThemeData(color: primaryColor),
    scaffoldBackgroundColor:
        isDarkMode ? darkColorScheme.surface : lightColorScheme.surface,
    dividerColor: isDarkMode
        ? darkColorScheme.onSurface.withValues(alpha: 0.12)
        : lightColorScheme.onSurface.withValues(alpha: 0.12),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    fontFamily: FontConst.lato,
    textTheme: textTheme,
    tabBarTheme: TabBarThemeData(
      labelColor: primaryColor,
      labelStyle: textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelColor:
          textTheme.titleMedium?.color?.withValues(alpha: 0.5),
      dividerColor: Colors.transparent,
      indicatorColor: primaryColor,
      indicatorSize: TabBarIndicatorSize.label,
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      iconTheme: IconThemeData(
        color:
            isDarkMode ? darkColorScheme.onSurface : lightColorScheme.onSurface,
      ),
      actionsIconTheme: IconThemeData(
        color:
            isDarkMode ? darkColorScheme.onSurface : lightColorScheme.onSurface,
      ),
      titleTextStyle: textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color:
            isDarkMode ? darkColorScheme.onSurface : lightColorScheme.onSurface,
      ),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            isDarkMode ? Brightness.light : Brightness.dark,
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      showDragHandle: true,
      dragHandleColor: isDarkMode
          ? darkColorScheme.onSurface.withValues(alpha: 0.5)
          : lightColorScheme.onSurface.withValues(alpha: 0.5),
      dragHandleSize: const Size(32, 4),
      modalElevation: 0,
      backgroundColor: isDarkMode
          ? darkColorScheme.surfaceContainer
          : lightColorScheme.surfaceContainer,
      modalBarrierColor: isDarkMode
          ? darkColorScheme.surfaceContainer.withValues(alpha: 0.5)
          : lightColorScheme.surfaceContainer.withValues(alpha: 0.5),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
    ),
    listTileTheme: ListTileThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      dense: true,
      visualDensity: VisualDensity.compact,
      titleTextStyle: textTheme.titleMedium,
      subtitleTextStyle: textTheme.titleSmall,
    ),
    iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(
        padding: WidgetStateProperty.all(
          const EdgeInsets.all(8),
        ),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return primaryColor.withValues(alpha: 0.5);
          }
          return primaryColor;
        }),
      ),
    ),
    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      titleTextStyle: textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w500,
      ),
      contentTextStyle: textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w500,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        foregroundColor: primaryColor,
        disabledForegroundColor: isDarkMode
            ? darkColorScheme.onSurface.withValues(alpha: 0.5)
            : lightColorScheme.onSurface.withValues(alpha: 0.5),
        textStyle: textTheme.titleSmall,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: textTheme.titleSmall,
        foregroundColor:
            isDarkMode ? darkColorScheme.onPrimary : lightColorScheme.onPrimary,
        backgroundColor: primaryColor,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: textTheme.titleSmall,
        foregroundColor:
            isDarkMode ? darkColorScheme.onPrimary : lightColorScheme.onPrimary,
        backgroundColor: primaryColor,
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return isDarkMode
              ? darkColorScheme.primary
              : lightColorScheme.primary;
        }
        return Colors.transparent;
      }),
      overlayColor:
          WidgetStateProperty.all(defaultColor.withValues(alpha: 0.1)),
      checkColor: WidgetStateProperty.all(
        isDarkMode ? darkColorScheme.onPrimary : lightColorScheme.onPrimary,
      ),
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: primaryColor,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(2),
      ),
      side: BorderSide(
        color: primaryColor,
        width: 2,
      ),
    ),
    sliderTheme: SliderThemeData(
      overlayShape: SliderComponentShape.noOverlay,
      thumbShape: const RoundSliderThumbShape(
        enabledThumbRadius: 8,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      backgroundColor: secondaryColor,
      contentTextStyle: textTheme.titleSmall?.copyWith(
        color: isDarkMode
            ? darkColorScheme.onSecondary
            : lightColorScheme.onSecondary,
      ),
    ),
    chipTheme: ChipThemeData(
      deleteIconColor:
          isDarkMode ? darkColorScheme.onPrimary : lightColorScheme.onPrimary,
      labelStyle: textTheme.bodySmall,
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
      side: BorderSide(
        color: secondaryColor,
        width: 1,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      backgroundColor: Colors.transparent,
    ),
    inputDecorationTheme: InputDecorationTheme(
      labelStyle: textTheme.titleSmall,
      border: const UnderlineInputBorder(),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: primaryColor,
          width: 2,
        ),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor:
          isDarkMode ? darkColorScheme.onPrimary : lightColorScheme.onPrimary,
    ),
  );
}
