import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_provider/go_provider.dart';
import 'package:go_router/go_router.dart';

import '../../app.dart';
import '../../features/kajian/domain/entities/kajian_schedule.codegen.dart';
import '../../features/kajian/presentation/screens/kajian_detail_screen.dart';
import '../../features/kajian/presentation/screens/kajianhub_screen.dart';
import '../../features/payment/presentation/screens/donation_screen.dart';
import '../../features/qibla/presentation/screens/qibla_compass.dart';
import '../../features/quran/presentation/bloc/shareVerse/share_verse_bloc.dart';
import '../../features/quran/presentation/screens/detail_juz_screen.dart';
import '../../features/quran/presentation/screens/detail_surah_screen.dart';
import '../../features/quran/presentation/screens/history_read_screen.dart';
import '../../features/quran/presentation/screens/share_verse_screen.dart';
import '../../features/setting/presentation/screens/language_setting_screen.dart';
import '../../features/setting/presentation/screens/styling_setting_screen.dart';
import '../../features/shalat/presentation/screens/prayer_schedule_screen.dart';
import '../../features/ustad_ai/presentation/blocs/ustad_ai/ustad_ai_bloc.dart';
import '../../features/ustad_ai/presentation/screens/ustad_ai_screen.dart';
import '../../injection.dart';
import '../components/error_screen.dart';
import 'root_router.dart';

final router = GoRouter(
  navigatorKey: App.navigatorKey,
  initialLocation: RootRouter.rootRoute.path,
  debugLogDiagnostics: kDebugMode,
  routes: [
    GoRoute(
      name: RootRouter.rootRoute.name,
      path: RootRouter.rootRoute.path,
      builder: (context, state) {
        final error = state.uri.queryParameters['error'];
        final errorCode = state.uri.queryParameters['error_code'];
        final errorDescription = state.uri.queryParameters['error_description'];

        if (error != null && errorCode != null && errorDescription != null) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(error),
                ),
              );
            },
          );
        }

        return ScaffoldConnection();
      },
      routes: [
        GoRoute(
          name: RootRouter.dashboard.name,
          path: RootRouter.dashboard.path,
          builder: (_, __) => ScaffoldConnection(),
        ),
        GoRoute(
          name: RootRouter.qiblaRoute.name,
          path: RootRouter.qiblaRoute.path,
          builder: (_, __) => QiblaCompassScreen(),
        ),
        GoRoute(
          name: RootRouter.kajianRoute.name,
          path: RootRouter.kajianRoute.path,
          builder: (_, __) => KajianHubScreen(),
          routes: [
            GoRoute(
              name: RootRouter.kajianDetailRoute.name,
              path: RootRouter.kajianDetailRoute.path,
              builder: (_, state) {
                final kajian = state.extra as DataKajianSchedule;

                return KajianDetailScreen(
                  kajian: kajian,
                );
              },
            ),
          ],
        ),
        GoRoute(
          name: RootRouter.historyRoute.name,
          path: RootRouter.historyRoute.path,
          builder: (_, __) => HistoryReadScreen(),
        ),
        GoRoute(
          name: RootRouter.juzRoute.name,
          path: RootRouter.juzRoute.path,
          builder: (_, state) {
            final juzNumber = state.uri.queryParameters['no'];
            final jumpToVerse = state.uri.queryParameters['jump_to'];

            if (juzNumber == null) {
              return ErrorScreen(
                message: 'Juz number is required',
              );
            }

            return DetailJuzScreen(
              juzNumber: int.tryParse(juzNumber),
              jumpToVerse: int.tryParse(jumpToVerse ?? ''),
            );
          },
        ),
        GoRoute(
          name: RootRouter.surahRoute.name,
          path: RootRouter.surahRoute.path,
          builder: (_, state) {
            final jumpToVerse = state.uri.queryParameters['jump_to'];
            final detailSurahScreenExtra =
                state.extra as DetailSurahScreenExtra;

            if (detailSurahScreenExtra.surah == null) {
              return ErrorScreen(
                message: 'Surah number is required',
              );
            }

            return DetailSurahScreen(
              surah: detailSurahScreenExtra.surah,
              jumpToVerse: int.tryParse(jumpToVerse ?? ''),
            );
          },
        ),
        GoProviderRoute(
          name: RootRouter.shareVerseRoute.name,
          path: RootRouter.shareVerseRoute.path,
          providers: [
            BlocProvider<ShareVerseBloc>(
              create: (context) => sl<ShareVerseBloc>(),
            ),
          ],
          builder: (context, state) {
            final shareVerseScreenExtra = state.extra as ShareVerseScreenExtra;

            return BlocProvider.value(
              value: context.read<ShareVerseBloc>()
                ..add(
                  ShareVerseEvent.onInit(
                    verse: shareVerseScreenExtra.verse,
                    juz: shareVerseScreenExtra.juz,
                    surah: shareVerseScreenExtra.surah,
                  ),
                ),
              child: ShareVerseScreen(),
            );
          },
        ),
        GoRoute(
          name: RootRouter.languageSettingRoute.name,
          path: RootRouter.languageSettingRoute.path,
          builder: (_, __) => LanguageSettingScreen(),
        ),
        GoRoute(
          name: RootRouter.styleSettingRoute.name,
          path: RootRouter.styleSettingRoute.path,
          builder: (_, __) => StylingSettingScreen(),
        ),
        GoRoute(
          name: RootRouter.donationRoute.name,
          path: RootRouter.donationRoute.path,
          builder: (_, __) => DonationPaymentScreen(),
        ),
        GoRoute(
          name: RootRouter.prayerTimeRoute.name,
          path: RootRouter.prayerTimeRoute.path,
          builder: (_, __) => PrayerScheduleScreen(),
        ),
        GoRoute(
          name: RootRouter.ustadAiRoute.name,
          path: RootRouter.ustadAiRoute.path,
          builder: (_, __) => BlocProvider(
            create: (context) => sl<UstadAiBloc>(),
            child: AiScreen(),
          ),
        ),
        GoRoute(
          name: RootRouter.error.name,
          path: RootRouter.error.path,
          builder: (context, state) {
            final desc = state.uri.queryParameters['error_description'];

            return Scaffold(
              body: ErrorScreen(
                message: desc,
              ),
            );
          },
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) {
    return Scaffold(
      body: ErrorScreen(
        message: state.error.toString(),
      ),
    );
  },
);
