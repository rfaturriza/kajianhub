import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:quranku/core/utils/extension/context_ext.dart';
import 'package:quranku/features/buletin/domain/entities/buletin.codegen.dart';
import 'package:quranku/generated/locale_keys.g.dart';

class BuletinTile extends StatelessWidget {
  final Buletin buletin;
  final VoidCallback? onTap;

  const BuletinTile({
    super.key,
    required this.buletin,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image if available
              if (buletin.pictureUrl != null && buletin.pictureUrl!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: buletin.pictureUrl!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 180,
                      color: context.theme.colorScheme.surfaceContainerHighest,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 180,
                      color: context.theme.colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Symbols.image_not_supported_rounded,
                        color: context.theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),

              // Title
              Padding(
                padding: EdgeInsets.only(
                  top: buletin.pictureUrl != null ? 12 : 0,
                  bottom: 8,
                ),
                child: Text(
                  buletin.title,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Content preview
              Text(
                _stripHtmlTags(buletin.content),
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              // Author and date
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Symbols.person_outline,
                          size: 16,
                          color: context.theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            LocaleKeys.readBy.tr(namedArgs: {
                              'name': buletin.createdByUser?.name ?? 'Unknown',
                            }),
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.theme.colorScheme.onSurfaceVariant,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    children: [
                      Icon(
                        Symbols.schedule_rounded,
                        size: 16,
                        color: context.theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(buletin.createdAt),
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _stripHtmlTags(String htmlString) {
    // Remove HTML tags
    final RegExp exp = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: true);
    String result = htmlString.replaceAll(exp, '');

    // Decode common HTML entities
    result = result
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&ldquo;', '"')
        .replaceAll('&rdquo;', '"')
        .replaceAll('&lsquo;', "'")
        .replaceAll('&rsquo;', "'")
        .replaceAll('&ndash;', '–')
        .replaceAll('&mdash;', '—');

    // Clean up extra whitespace
    result = result.replaceAll(RegExp(r'\s+'), ' ');

    return result.trim();
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy', 'id').format(date);
  }
}
