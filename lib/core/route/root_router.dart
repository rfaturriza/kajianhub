import 'models/route_model.dart';

class RootRouter {
  static const RouteModel notFound = RouteModel(
    name: 'notFound',
    path: '/not-found',
  );

  static const RouteModel error = RouteModel(
    name: 'error',
    path: '/error',
  );

  static const RouteModel rootRoute = RouteModel(
    name: 'root',
    path: '/',
  );

  static const RouteModel dashboard = RouteModel(
    name: 'dashboard',
    path: '/dashboard',
    parent: rootRoute,
  );

  static const RouteModel qiblaRoute = RouteModel(
    name: 'qibla',
    path: '/qibla',
    parent: rootRoute,
  );

  static const RouteModel kajianRoute = RouteModel(
    name: 'kajian',
    path: '/kajian',
    parent: rootRoute,
  );

  static const RouteModel kajianDetailRoute = RouteModel(
    name: 'kajianDetail',
    path: '/:id',
    parent: kajianRoute,
  );

  static const RouteModel historyRoute = RouteModel(
    name: 'history',
    path: '/history',
    parent: rootRoute,
  );

  static const RouteModel juzRoute = RouteModel(
    name: 'juz',
    path: '/juz',
    parent: rootRoute,
  );

  static const RouteModel surahRoute = RouteModel(
    name: 'surah',
    path: 'surah',
    parent: rootRoute,
  );

  static const RouteModel shareVerseRoute = RouteModel(
    name: 'shareVerse',
    path: '/share-verse',
    parent: rootRoute,
  );

  static const RouteModel languageSettingRoute = RouteModel(
    name: 'languageSetting',
    path: '/language-setting',
    parent: rootRoute,
  );

  static const RouteModel styleSettingRoute = RouteModel(
    name: 'styleSetting',
    path: '/style-setting',
    parent: rootRoute,
  );

  static const RouteModel donationRoute = RouteModel(
    name: 'donation',
    path: '/donation',
    parent: rootRoute,
  );

  static const RouteModel prayerTimeRoute = RouteModel(
    name: 'prayerTime',
    path: '/prayer-time',
    parent: rootRoute,
  );

  static const RouteModel ustadAiRoute = RouteModel(
    name: 'ustadAi',
    path: '/ustad-ai',
    parent: rootRoute,
  );
}
