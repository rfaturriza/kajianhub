import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_localization/src/localization.dart';
import 'package:easy_localization/src/translations.dart';
import 'package:get_it/get_it.dart';
import 'package:quranku/core/components/search_box.dart';
import 'package:quranku/features/buletin/data/datasources/buletin_remote_data_source.dart';
import 'package:quranku/features/buletin/data/repositories/buletin_repository_impl.dart';
import 'package:quranku/features/buletin/domain/repositories/buletin_repository.dart';
import 'package:quranku/features/buletin/domain/usecases/get_buletins_usecase.dart';
import 'package:quranku/features/buletin/presentation/blocs/buletin_bloc.dart';
import 'package:quranku/features/buletin/presentation/screens/buletin_screen.dart';

void main() {
  setUpAll(() async {
    // Load localization before all tests
    final content = await File(
      'assets/translations/en.json',
    ).readAsString();
    final data = jsonDecode(content) as Map<String, dynamic>;

    Localization.load(
      const Locale('en'),
      translations: Translations(data),
    );
    GetIt.instance.registerSingleton<BuletinRemoteDataSource>(
      BuletinRemoteDataSourceImpl(),
    );
    GetIt.instance.registerSingleton<BuletinRepository>(
      BuletinRepositoryImpl(GetIt.instance<BuletinRemoteDataSource>()),
    );
    GetIt.instance.registerSingleton<GetBuletinsUsecase>(GetBuletinsUsecase(
      GetIt.instance<BuletinRepository>(),
    ));
    GetIt.instance.registerSingleton<BuletinBloc>(BuletinBloc(
      GetIt.instance<GetBuletinsUsecase>(),
    ));
  });

  group('BuletinScreen Basic UI Tests', () {
    testWidgets('should display basic MaterialApp without errors',
        (WidgetTester tester) async {
      // Test that a basic MaterialApp renders without errors
      await tester.pumpWidget(
        MaterialApp(
          home: BuletinScreen(),
        ),
      );

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Bulletin'), findsOneWidget);
      // Should display search box widget
      expect(find.byType(SearchBox), findsOneWidget);
    });
  });
}
