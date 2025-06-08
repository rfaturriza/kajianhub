import 'package:flutter/material.dart';
import 'package:quranku/core/utils/extension/context_ext.dart';

import '../../../../core/components/spacer.dart';

class ScheduleIconText extends StatelessWidget {
  final IconData icon;
  final String text;

  const ScheduleIconText({
    super.key,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: context.theme.colorScheme.onSurfaceVariant,
        ),
        const HSpacer(width: 5),
        Expanded(
          child: Text(
            text,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
