import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:quranku/core/utils/extension/context_ext.dart';

class CategoryMenuItem extends StatelessWidget {
  final double? width;
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isShimmer;
  final String? badgeText;
  final Color? badgeColor;
  final bool labelInside;
  const CategoryMenuItem({
    super.key,
    this.width,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.isShimmer = false,
    this.badgeText,
    this.badgeColor,
    this.labelInside = false,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            children: [
              if (isShimmer) ...[
                Shimmer.fromColors(
                  baseColor: color.withAlpha(100),
                  highlightColor: color,
                  enabled: isShimmer,
                  child: _buildContent(context),
                ),
              ],
              if (!isShimmer) ...[
                _buildContent(context),
              ],
              // Badge
              if (badgeText != null && badgeText!.isNotEmpty) ...[
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: badgeColor ?? Colors.red,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: context.theme.colorScheme.surface,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      badgeText!,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color:
                            (badgeColor ?? Colors.red).computeLuminance() > 0.5
                                ? Colors.black
                                : Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (!labelInside) ...[
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: context.theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withAlpha(51),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: labelInside
            ? MainAxisAlignment.spaceBetween
            : MainAxisAlignment.center,
        children: [
          if (labelInside) ...[
            Text(
              label,
              style: context.textTheme.titleSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          Icon(
            icon,
            color: color,
          ),
        ],
      ),
    );
  }
}
