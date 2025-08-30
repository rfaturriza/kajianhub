import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:quranku/core/components/loading_dialog.dart';

import '../themes/color_schemes_material.dart';

extension ContextExt on BuildContext {
  ThemeData get theme => Theme.of(this);

  TextTheme get textTheme => Theme.of(this).textTheme;

  Size get size => MediaQuery.of(this).size;

  double get height => size.height;

  double get width => size.width;

  EdgeInsets get padding => MediaQuery.of(this).padding;

  double get topPadding => padding.top;

  double get bottomPadding => padding.bottom;

  bool get isLandscape =>
      MediaQuery.of(this).orientation == Orientation.landscape;

  bool get isPortrait =>
      MediaQuery.of(this).orientation == Orientation.portrait;

  void dismissKeyboard() {
    FocusScope.of(this).requestFocus(FocusNode());
  }

  ToastFuture showErrorToast(String message) {
    return showToast(
      message,
      context: this,
      backgroundColor: theme.colorScheme.errorContainer,
      textStyle: textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onErrorContainer,
      ),
    );
  }

  ToastFuture showInfoToast(String message) {
    return showToast(
      message,
      context: this,
      textStyle: textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onTertiaryContainer,
      ),
      backgroundColor: theme.colorScheme.tertiaryContainer,
    );
  }

  void showLoadingDialog() {
    showDialog(
      context: this,
      barrierDismissible: false,
      builder: (context) {
        return const LoadingDialog();
      },
    );
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> appSnackBar(
    String message, {
    SnackBarAction? action,
  }) {
    return ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: theme.colorScheme.secondary,
        content: Text(message),
        action: action,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  bool get isDarkMode {
    return theme.brightness == Brightness.dark;
  }
}

extension ColorSchemeExt on ColorScheme {
  Color get surfaceContainer {
    return brightness == Brightness.dark
        ? MaterialTheme.darkScheme().surfaceContainer
        : MaterialTheme.lightScheme().surfaceContainer;
  }
}
