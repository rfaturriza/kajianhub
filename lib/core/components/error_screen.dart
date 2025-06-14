import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:quranku/generated/locale_keys.g.dart';

import 'spacer.dart';

enum IconType {
  warning(Symbols.warning_rounded),
  error(Symbols.priority_high_rounded),
  info(Symbols.info_i_rounded),
  success(Symbols.check_circle_outline_rounded);

  final IconData icon;
  const IconType(this.icon);
}

class ErrorScreen extends StatelessWidget {
  final IconType iconType;
  final String? message;
  final void Function()? onRefresh;

  const ErrorScreen({
    super.key,
    this.iconType = IconType.error,
    required this.message,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onRefresh,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                iconType.icon,
              ),
              const VSpacer(),
              Text(
                message ?? LocaleKeys.defaultErrorMessage.tr(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              // icon Refresh
              if (onRefresh != null) ...[
                TextButton.icon(
                  onPressed: onRefresh,
                  icon: const Icon(Symbols.refresh_rounded),
                  label: Text(
                    LocaleKeys.tryAgain.tr(),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
