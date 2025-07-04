import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:quranku/core/utils/extension/context_ext.dart';
import 'package:quranku/features/ustadz/domain/entities/ustadz_entity.codegen.dart';
import 'package:quranku/generated/locale_keys.g.dart';

import '../../../../core/components/spacer.dart';

class UstadzTile extends StatelessWidget {
  final UstadzEntity ustadz;
  final Function(UstadzEntity ustadz)? onTap;

  const UstadzTile({
    super.key,
    required this.ustadz,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = ustadz.pictureUrl ?? '';
    final name = ustadz.name;
    final email = ustadz.email;
    final subscribersCount = ustadz.subscribersCount ?? '0';
    final kajianCount = ustadz.kajianCount ?? '0';
    final placeOfBirth = ustadz.placeOfBirth ?? '';

    return GestureDetector(
      onTap: onTap != null
          ? () {
              onTap!(ustadz);
            }
          : null,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: ShapeDecoration(
          color: context.theme.colorScheme.surfaceContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 80,
              height: 80,
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: context.theme.colorScheme.surface,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.person,
                            size: 40,
                          );
                        },
                      )
                    : const Icon(
                        Icons.person,
                        size: 40,
                      ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: context.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const VSpacer(height: 2),
                          Text(
                            email,
                            style: context.textTheme.bodySmall,
                          ),
                          if (placeOfBirth.isNotEmpty) ...[
                            const VSpacer(height: 2),
                            Text(
                              placeOfBirth,
                              style: context.textTheme.bodySmall,
                            ),
                          ],
                          const VSpacer(height: 4),
                          Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: _InfoWidget(
                                  icon: Icons.menu_book_rounded,
                                  text: kajianCount,
                                  label: LocaleKeys.kajian.tr(),
                                ),
                              ),
                              const HSpacer(width: 5),
                              Expanded(
                                flex: 1,
                                child: _InfoWidget(
                                  icon: Symbols.people_rounded,
                                  text: subscribersCount,
                                  label: LocaleKeys.subscribers.tr(),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.navigate_next,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoWidget extends StatelessWidget {
  final IconData icon;
  final String text;
  final String label;

  const _InfoWidget({
    required this.icon,
    required this.text,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: context.theme.colorScheme.onSurfaceVariant,
        ),
        const HSpacer(width: 4),
        Expanded(
          child: Text(
            '$text $label',
            style: context.textTheme.bodySmall?.copyWith(
              color: context.theme.colorScheme.onSurfaceVariant,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
