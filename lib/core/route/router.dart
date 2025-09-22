import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_provider/go_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:quranku/core/utils/bloc_listenable.dart';
import 'package:quranku/features/kajian/domain/entities/study_location_entity.dart';
import 'package:quranku/features/masjid/presentation/screens/study_location_detail_screen.dart';

import '../../app.dart';
import '../../features/kajian/domain/entities/kajian_schedule.codegen.dart';
import '../../features/kajian/presentation/screens/kajian_detail_screen.dart';
import '../../features/kajian/presentation/screens/kajianhub_screen.dart';
import '../../features/masjid/presentation/blocs/study_location_detail/study_location_detail_bloc.dart';
import '../../features/masjid/presentation/blocs/study_location_list/study_location_list_bloc.dart';
import '../../features/masjid/presentation/screens/study_location_list_screen.dart';
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
import '../../features/ustadz/domain/entities/ustadz_entity.codegen.dart';
import '../../features/ustadz/presentation/blocs/ustadz_detail/ustadz_detail_bloc.dart';
import '../../features/ustadz/presentation/blocs/ustadz_list/ustadz_list_bloc.dart';
import '../../features/ustadz/presentation/screens/ustadz_detail_screen.dart';
import '../../features/ustadz/presentation/screens/ustadz_list_screen.dart';
import '../../features/ustad_ai/presentation/blocs/ustad_ai/ustad_ai_bloc.dart';
import '../../features/ustad_ai/presentation/screens/ustad_ai_screen.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/profile_screen.dart';
import '../../features/auth/presentation/widgets/auth_wrapper.dart';
import '../../injection.dart';
import '../components/error_screen.dart';
import 'root_router.dart';

// Custom extra Codec to retain complex objects passed via 'extra'
class AppExtraCodec extends Codec<Object?, Object?> {
  @override
  Converter<Object?, Object?> get encoder => const _AppExtraConverter();

  @override
  Converter<Object?, Object?> get decoder => const _AppExtraConverter();
}

// Converter that returns the object unchanged
class _AppExtraConverter extends Converter<Object?, Object?> {
  const _AppExtraConverter();

  @override
  Object? convert(Object? input) => input;
}

GoRouter router(AuthBloc authBloc) => GoRouter(
      // provide custom codec so complex 'extra' values are not dropped
      extraCodec: AppExtraCodec(),
      navigatorKey: App.navigatorKey,
      initialLocation: RootRouter.rootRoute.path,
      debugLogDiagnostics: kDebugMode,
      refreshListenable: BlocListenable<AuthBloc, AuthState>(
        authBloc,
        whenListen: (previous, current) {
          return (previous is AuthAuthenticated ? previous.token : null) !=
              (current is AuthAuthenticated ? current.token : null);
        },
      ),
      redirect: (context, state) {
        // Check if user is authenticated for protected routes
        final isAuthenticated = authBloc.state is AuthAuthenticated;
        final protectedRoutes = [RootRouter.profileRoute.path];

        if (!isAuthenticated &&
            protectedRoutes.contains(state.matchedLocation)) {
          return RootRouter.loginRoute.path;
        }

        // If user is authenticated and trying to access login, redirect to dashboard
        if (isAuthenticated &&
            state.matchedLocation == RootRouter.loginRoute.path) {
          return RootRouter.rootRoute.path;
        }

        return null;
      },
      routes: [
        GoRoute(
          name: RootRouter.rootRoute.name,
          path: RootRouter.rootRoute.path,
          builder: (context, state) {
            final error = state.uri.queryParameters['error'];
            final errorCode = state.uri.queryParameters['error_code'];
            final errorDescription =
                state.uri.queryParameters['error_description'];

            if (error != null &&
                errorCode != null &&
                errorDescription != null) {
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
                final shareVerseScreenExtra =
                    state.extra as ShareVerseScreenExtra;

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
              name: RootRouter.studyLocationRoute.name,
              path: RootRouter.studyLocationRoute.path,
              builder: (_, __) => BlocProvider(
                create: (context) => sl<StudyLocationListBloc>(),
                child: StudyLocationListScreen(),
              ),
              routes: [
                GoRoute(
                  name: RootRouter.studyLocationDetailRoute.name,
                  path: RootRouter.studyLocationDetailRoute.path,
                  builder: (_, state) => BlocProvider(
                    create: (_) => sl<StudyLocationDetailBloc>()
                      ..add(
                        StudyLocationDetailEvent.loadStudies(
                          studyLocationId: state.pathParameters['id']!,
                          page: 1,
                        ),
                      ),
                    child: StudyLocationDetailScreen(
                      masjid: state.extra as StudyLocationEntity,
                    ),
                  ),
                ),
              ],
            ),
            GoRoute(
              name: RootRouter.ustadzRoute.name,
              path: RootRouter.ustadzRoute.path,
              builder: (_, __) => BlocProvider(
                create: (context) => sl<UstadzListBloc>(),
                child: UstadzListScreen(),
              ),
              routes: [
                GoRoute(
                  name: RootRouter.ustadzDetailRoute.name,
                  path: RootRouter.ustadzDetailRoute.path,
                  builder: (_, state) => BlocProvider(
                    create: (_) => sl<UstadzDetailBloc>(),
                    child: UstadzDetailScreen(
                      ustadz: state.extra as UstadzEntity,
                    ),
                  ),
                ),
              ],
            ),
            GoRoute(
                name: RootRouter.loginRoute.name,
                path: RootRouter.loginRoute.path,
                builder: (_, state) {
                  final redirectTo = state.pathParameters["redirectTo"];
                  return LoginScreen(
                    redirectTo: redirectTo,
                  );
                }),
            GoRoute(
              name: RootRouter.profileRoute.name,
              path: RootRouter.profileRoute.path,
              builder: (_, __) => AuthWrapper(
                authenticatedWidget: const ProfileScreen(),
                unauthenticatedWidget: const LoginScreen(),
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
