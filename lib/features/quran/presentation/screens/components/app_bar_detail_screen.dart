import 'package:flutter/material.dart';
import 'package:quranku/core/utils/extension/context_ext.dart';

class AppBarDetailScreen extends StatelessWidget
    implements PreferredSizeWidget {
  const AppBarDetailScreen({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text(title),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class SliverAppBarDetailScreen extends StatelessWidget
    implements PreferredSizeWidget {
  const SliverAppBarDetailScreen({
    super.key,
    this.isBookmarked = false,
    required this.title,
    required this.onPressedBookmark,
  });

  final bool isBookmarked;
  final String title;
  final Function()? onPressedBookmark;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: false,
      floating: true,
      elevation: 0,
      title: Text(
        title,
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: IconButton(
            onPressed: onPressedBookmark,
            icon: () {
              if (isBookmarked) {
                return const Icon(Icons.bookmark);
              }
              return const Icon(Icons.bookmark_border);
            }(),
            color: context.theme.colorScheme.tertiary,
            disabledColor:
                context.theme.colorScheme.tertiary.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
