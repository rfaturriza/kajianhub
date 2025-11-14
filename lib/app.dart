import 'package:dynamic_color/dynamic_color.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:go_router/go_router.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:quranku/core/network/networkInfo/network_info_bloc.dart';
import 'package:quranku/core/utils/extension/context_ext.dart';
import 'package:quranku/core/utils/themes/theme.dart';
import 'package:quranku/features/quran/presentation/bloc/juz/juz_cubit.dart';
import 'package:quranku/features/quran/presentation/bloc/lastRead/last_read_cubit.dart';
import 'package:quranku/features/quran/presentation/screens/quran_screen.dart';
import 'package:quranku/features/shalat/presentation/bloc/shalat/shalat_bloc.dart';
import 'package:quranku/generated/locale_keys.g.dart';
import 'package:quranku/injection.dart';
import 'package:quranku/theme_provider.dart';
import 'package:overlay_support/overlay_support.dart';

import 'core/route/router.dart';
import 'features/quran/presentation/bloc/surah/surah_bloc.dart';
import 'features/setting/presentation/bloc/language_setting/language_setting_bloc.dart';
import 'features/setting/presentation/bloc/styling_setting/styling_setting_bloc.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';

class App extends StatefulWidget {
  const App({super.key});

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Initialize router once to prevent recreation on hot reload
    _router = router(sl<AuthBloc>());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // When app is resumed, check for location changes and update notifications
      final context = App.navigatorKey.currentContext;
      if (context != null) {
        context
            .read<ShalatBloc>()
            .add(const ShalatEvent.checkAndUpdateNotificationsEvent());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.locale;
    return MultiBlocProvider(
      providers: [
        BlocProvider<NetworkInfoBloc>(
          create: (context) => sl<NetworkInfoBloc>(),
        ),
        BlocProvider<SurahBloc>(
          create: (context) => sl<SurahBloc>(),
        ),
        BlocProvider<JuzBloc>(
          create: (context) => sl<JuzBloc>(),
        ),
        BlocProvider<ShalatBloc>(
          create: (context) => sl<ShalatBloc>()..add(ShalatEvent.init(locale)),
        ),
        BlocProvider<LastReadCubit>(
          create: (context) => sl<LastReadCubit>()
            ..getLastReadJuz()
            ..getLastReadSurah(),
        ),
        BlocProvider<LanguageSettingBloc>(
          create: (context) => sl<LanguageSettingBloc>()
            ..add(const LanguageSettingEvent.getLatinLanguage())
            ..add(const LanguageSettingEvent.getPrayerLanguage())
            ..add(const LanguageSettingEvent.getQuranLanguage()),
        ),
        BlocProvider<StylingSettingBloc>(
          create: (context) =>
              sl<StylingSettingBloc>()..add(const StylingSettingEvent.init()),
        ),
        BlocProvider<AuthBloc>(
          create: (context) => sl<AuthBloc>()..add(AuthCheckRequested()),
        ),
      ],
      child: OKToast(
        textAlign: TextAlign.center,
        textPadding: const EdgeInsets.all(10),
        radius: 5,
        position: ToastPosition.bottom,
        child: ChangeNotifierProvider(
          create: (context) => sl<ThemeProvider>()..init(),
          child: Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              final isDynamicColor = themeProvider.dynamicColor;
              return DynamicColorBuilder(
                builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
                  return OverlaySupport(
                    child: BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return MaterialApp.router(
                          routerConfig: _router,
                          title: LocaleKeys.appName.tr(),
                          debugShowCheckedModeBanner: false,
                          theme: themeData(
                            isDarkMode: false,
                            colorScheme: isDynamicColor ? lightDynamic : null,
                          ),
                          darkTheme: themeData(
                            isDarkMode: true,
                            colorScheme: isDynamicColor ? darkDynamic : null,
                          ),
                          themeMode: themeProvider.themeMode,
                          localizationsDelegates: [
                            for (var delegate in context.localizationDelegates)
                              delegate,
                            const LocaleNamesLocalizationsDelegate(),
                          ],
                          supportedLocales: context.supportedLocales,
                          locale: context.locale,
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class ScaffoldConnection extends StatelessWidget {
  const ScaffoldConnection({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: BlocBuilder<NetworkInfoBloc, NetworkInfoState>(
        builder: (context, state) {
          if (state is NetworkInfoDisconnectedState) {
            return FloatingActionButton(
              onPressed: () {
                context.showErrorToast(
                  LocaleKeys.noInternetConnection.tr(),
                );
              },
              child: const Icon(Icons.signal_wifi_off_outlined),
            );
          }
          return const SizedBox();
        },
      ),
      body: const QuranScreen(),
    );
  }
}
