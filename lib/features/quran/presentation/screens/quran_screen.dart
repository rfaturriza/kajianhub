import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:quranku/core/utils/extension/context_ext.dart';
import 'package:quranku/features/bookmark/presentation/screen/bookmark_screen.dart';
import 'package:quranku/features/quran/presentation/screens/components/juz_list.dart';

import '../../../../generated/locale_keys.g.dart';
import 'components/surah_list.dart';

class QuranScreen extends StatelessWidget {
  final int? initialTab;
  const QuranScreen({
    super.key,
    this.initialTab,
  });

  @override
  Widget build(BuildContext context) {
    final controller = ScrollController();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text("Al-Qur'an"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: DefaultTabController(
          length: 3,
          initialIndex: initialTab ?? 0,
          child: NestedScrollView(
            scrollBehavior: const ScrollBehavior().copyWith(
              physics: const BouncingScrollPhysics(),
            ),
            controller: controller,
            headerSliverBuilder: (
              BuildContext context,
              bool innerBoxIsScrolled,
            ) {
              return [
                SliverPersistentHeader(
                  key: const ValueKey('tabbar'),
                  pinned: true,
                  delegate: BarHeaderPersistentDelegate(
                    TabBar(
                      tabs: [
                        Tab(text: LocaleKeys.surah.tr()),
                        Tab(text: LocaleKeys.juz.tr()),
                        Tab(text: LocaleKeys.bookmark.tr()),
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              children: [
                SurahList(),
                JuzList(),
                BookmarkScreen(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BarHeaderPersistentDelegate extends SliverPersistentHeaderDelegate {
  BarHeaderPersistentDelegate(this._bar);

  final dynamic _bar;

  @override
  double get minExtent {
    if (_bar is PreferredSizeWidget) {
      return (_bar).preferredSize.height;
    } else {
      return 0;
    }
  }

  @override
  double get maxExtent => minExtent;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    Color animatedColor({double? offset}) {
      if (shrinkOffset > 0 && shrinkOffset < maxExtent) {
        // Calculate opacity based on the shrinkOffset
        double opacity = 1 - (shrinkOffset / maxExtent);
        return context.theme.colorScheme.surface.withValues(alpha: opacity);
      } else if (shrinkOffset >= maxExtent) {
        // When fully scrolled, return the background color without any opacity
        return context.theme.colorScheme.surface;
      } else {
        // When at the top, make the background transparent
        return Colors.transparent;
      }
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            animatedColor(),
            animatedColor(offset: 0.5),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: _bar,
    );
  }

  @override
  bool shouldRebuild(BarHeaderPersistentDelegate oldDelegate) {
    return false;
  }
}
