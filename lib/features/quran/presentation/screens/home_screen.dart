import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quranku/core/route/root_router.dart';
import 'package:quranku/core/utils/extension/context_ext.dart';
import 'package:quranku/features/quran/presentation/screens/components/main_app_bar.dart';
import 'package:quranku/features/quran/presentation/screens/components/carousel_slider_section.dart';

import 'components/category_menu_items_section.dart';
import 'drawer_quran_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appBar = MainAppBar(
      onPressedMenu: () {},
      onPressedQibla: () {
        context.pushNamed(RootRouter.qiblaRoute.name);
      },
      onPressedAuth: () {
        context.pushNamed(RootRouter.profileRoute.name);
      },
    );
    final controller = ScrollController();

    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: const DrawerQuranScreen(),
      appBar: appBar,
      body: ListView(
        controller: controller,
        children: [
          const CarouselSliderSection(),
          const CategoryMenuItemsSection(),
        ],
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
