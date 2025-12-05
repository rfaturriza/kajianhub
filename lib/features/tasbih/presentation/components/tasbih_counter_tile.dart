import 'package:flutter/material.dart';
import 'package:quranku/core/utils/extension/context_ext.dart';
import '../../../../core/components/spacer.dart';
import '../../domain/entities/tasbih_counter.codegen.dart';

class TasbihCounterTile extends StatelessWidget {
  final TasbihCounter counter;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const TasbihCounterTile({
    super.key,
    required this.counter,
    this.isSelected = false,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? context.theme.colorScheme.primaryContainer
              : context.theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? context.theme.colorScheme.primary
                : context.theme.colorScheme.outline.withAlpha(100),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Counter Name
            Text(
              counter.name,
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? context.theme.colorScheme.primary
                    : context.theme.colorScheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const VSpacer(height: 8),

            // Arabic Text (smaller)
            Text(
              counter.arabicText,
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? context.theme.colorScheme.onPrimaryContainer
                    : context.theme.colorScheme.onSurface,
              ),
              textDirection: TextDirection.rtl,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const VSpacer(height: 12),

            // Progress and Count
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Progress indicator
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LinearProgressIndicator(
                        value: counter.progress,
                        backgroundColor:
                            context.theme.colorScheme.surfaceContainer,
                        valueColor: AlwaysStoppedAnimation(
                          counter.isTargetReached
                              ? context.theme.colorScheme.primary
                              : context.theme.colorScheme.secondary,
                        ),
                      ),
                      const VSpacer(height: 4),
                      Text(
                        '${counter.count}/${counter.target}',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: isSelected
                              ? context.theme.colorScheme.onPrimaryContainer
                              : context.theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                // Completion check
                if (counter.isTargetReached)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: context.theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      size: 16,
                      color: context.theme.colorScheme.onPrimary,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
