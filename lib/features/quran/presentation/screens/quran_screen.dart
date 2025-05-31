import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quranku/core/route/root_router.dart';
import 'package:quranku/core/utils/extension/context_ext.dart';
import 'package:quranku/core/utils/extension/extension.dart';
import 'package:quranku/features/bookmark/presentation/screen/bookmark_screen.dart';
import 'package:quranku/features/quran/presentation/screens/components/juz_list.dart';
import 'package:quranku/features/quran/presentation/screens/components/main_app_bar.dart';
import 'package:quranku/features/shalat/presentation/components/shalat_info_card.dart';

import '../../../../generated/locale_keys.g.dart';
import '../../../kajian/presentation/components/kajianhub_card.dart';
import '../../../shalat/presentation/bloc/shalat/shalat_bloc.dart';
import '../bloc/lastRead/last_read_cubit.dart';
import 'components/surah_list.dart';
import 'drawer_quran_screen.dart';

class QuranScreen extends StatelessWidget {
  const QuranScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appBar = MainAppBar(
      onPressedMenu: () {},
      onPressedQibla: () {
        context.pushNamed(RootRouter.qiblaRoute.name);
      },
    );
    final controller = ScrollController();

    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: const DrawerQuranScreen(),
      appBar: appBar,
      body: SafeArea(
        child: DefaultTabController(
          length: 3,
          child: NestedScrollView(
            scrollBehavior: const ScrollBehavior().copyWith(
              physics: const BouncingScrollPhysics(),
            ),
            controller: controller,
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return [
                BlocBuilder<LastReadCubit, LastReadState>(
                    builder: (context, state) {
                  final height = () {
                    if (state.lastReadSurah.isNotEmpty ||
                        state.lastReadJuz.isNotEmpty) {
                      return 170.0;
                    } else {
                      return 111.0;
                    }
                  }();
                  return SliverAppBar(
                    leading: const SizedBox(),
                    backgroundColor: Colors.transparent,
                    expandedHeight: height,
                    pinned: false,
                    flexibleSpace: const ShalatInfoCard(),
                    collapsedHeight: height,
                  );
                }),
                BlocBuilder<ShalatBloc, ShalatState>(
                    buildWhen: (previous, current) {
                  return previous.geoLocation != current.geoLocation;
                }, builder: (context, state) {
                  final isLocationGrant =
                      state.locationStatus?.status.isGranted;
                  final isNotIndonesia =
                      state.geoLocation?.country?.toLowerCase() != 'indonesia';
                  final isNotAvailable =
                      isNotIndonesia && isLocationGrant == true;
                  if (isNotAvailable) {
                    return const SliverToBoxAdapter(
                      child: SizedBox(),
                    );
                  }
                  return SliverAppBar(
                    leading: const SizedBox(),
                    backgroundColor: Colors.transparent,
                    expandedHeight: 150.0,
                    pinned: false,
                    flexibleSpace: FlexibleSpaceBar(
                      background: KajianHubCard(
                        isNotAvailable: isNotAvailable,
                      ),
                    ),
                  );
                }),
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
            body: const TabBarView(
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
