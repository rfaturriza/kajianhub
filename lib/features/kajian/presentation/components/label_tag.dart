import 'package:flutter/material.dart';
import 'package:quranku/core/utils/extension/context_ext.dart';

class LabelTag extends StatelessWidget {
  final String title;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const LabelTag({
    super.key,
    required this.title,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.all(2),
      decoration: ShapeDecoration(
        color: backgroundColor ?? context.theme.colorScheme.primaryContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3),
        ),
      ),
      child: Text(
        title,
        style: context.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.bold,
          color:
              foregroundColor ?? context.theme.colorScheme.onPrimaryContainer,
        ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis
      ),

    );
  }
}
