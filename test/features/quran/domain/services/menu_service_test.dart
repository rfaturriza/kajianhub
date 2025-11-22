import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quranku/features/quran/domain/entities/menu_item.codegen.dart';
import 'package:quranku/features/quran/domain/services/menu_service.dart';

// Mock classes
class MockFirebaseRemoteConfig extends Mock implements FirebaseRemoteConfig {}

void main() {
  group('MenuService', () {
    late MenuService menuService;
    late MockFirebaseRemoteConfig mockRemoteConfig;

    setUp(() {
      mockRemoteConfig = MockFirebaseRemoteConfig();
      menuService = MenuService(mockRemoteConfig);
    });

    group('getPrimaryMenuItems', () {
      test('returns parsed items when remote config has valid data', () async {
        // Arrange
        const mockJson = '''
        [
          {
            "id": "quran",
            "label": "Al-Qur'an",
            "iconName": "menu_book_rounded",
            "colorHex": "#2D5016",
            "route": "/quran",
            "order": 1,
            "isEnabled": true,
            "isPrimary": true
          },
          {
            "id": "kajian",
            "label": "Kajian",
            "iconName": "play_circle",
            "colorHex": "#D4AF37",
            "route": "/kajian",
            "order": 2,
            "isEnabled": true,
            "isPrimary": true
          }
        ]
        ''';

        when(() => mockRemoteConfig.fetchAndActivate())
            .thenAnswer((_) async => true);
        when(() => mockRemoteConfig.getString('primary_menu_items'))
            .thenReturn(mockJson);

        // Act
        final result = await menuService.getPrimaryMenuItems();

        // Assert
        expect(result, hasLength(2));
        expect(result[0].id, equals('quran'));
        expect(result[0].label, equals('Al-Qur\'an'));
        expect(result[0].route, equals('/quran'));
        expect(result[1].id, equals('kajian'));
        expect(result[1].label, equals('Kajian'));
        expect(result[1].route, equals('/kajian'));
      });

      test('filters out disabled items', () async {
        // Arrange
        const mockJson = '''
        [
          {
            "id": "quran",
            "label": "Al-Qur'an",
            "iconName": "menu_book_rounded",
            "colorHex": "#2D5016",
            "route": "/quran",
            "order": 1,
            "isEnabled": true,
            "isPrimary": true
          },
          {
            "id": "disabled",
            "label": "Disabled",
            "iconName": "block",
            "colorHex": "#FF0000",
            "route": "/disabled",
            "order": 2,
            "isEnabled": false,
            "isPrimary": true
          }
        ]
        ''';

        when(() => mockRemoteConfig.fetchAndActivate())
            .thenAnswer((_) async => true);
        when(() => mockRemoteConfig.getString('primary_menu_items'))
            .thenReturn(mockJson);

        // Act
        final result = await menuService.getPrimaryMenuItems();

        // Assert
        expect(result, hasLength(1));
        expect(result[0].id, equals('quran'));
      });

      test('sorts items by order field', () async {
        // Arrange
        const mockJson = '''
        [
          {
            "id": "kajian",
            "label": "Kajian",
            "iconName": "play_circle",
            "colorHex": "#D4AF37",
            "route": "/kajian",
            "order": 2,
            "isEnabled": true,
            "isPrimary": true
          },
          {
            "id": "quran",
            "label": "Al-Qur'an",
            "iconName": "menu_book_rounded",
            "colorHex": "#2D5016",
            "route": "/quran",
            "order": 1,
            "isEnabled": true,
            "isPrimary": true
          }
        ]
        ''';

        when(() => mockRemoteConfig.fetchAndActivate())
            .thenAnswer((_) async => true);
        when(() => mockRemoteConfig.getString('primary_menu_items'))
            .thenReturn(mockJson);

        // Act
        final result = await menuService.getPrimaryMenuItems();

        // Assert
        expect(result, hasLength(2));
        expect(result[0].id, equals('quran')); // order 1 should come first
        expect(result[1].id, equals('kajian')); // order 2 should come second
      });

      test('returns default items when remote config fails', () async {
        // Arrange
        when(() => mockRemoteConfig.fetchAndActivate())
            .thenThrow(Exception('Remote config error'));

        // Act
        final result = await menuService.getPrimaryMenuItems();

        // Assert
        expect(result, isNotEmpty);
        // Should contain default items
        final quranItem = result.firstWhere((item) => item.id == 'quran');
        expect(quranItem.label, equals('Al-Qur\'an'));
      });

      test('returns default items when remote config returns empty string',
          () async {
        // Arrange
        when(() => mockRemoteConfig.fetchAndActivate())
            .thenAnswer((_) async => true);
        when(() => mockRemoteConfig.getString('primary_menu_items'))
            .thenReturn('');

        // Act
        final result = await menuService.getPrimaryMenuItems();

        // Assert
        expect(result, isNotEmpty);
      });
    });

    group('getSecondaryMenuItems', () {
      test('returns parsed items when remote config has valid data', () async {
        // Arrange
        const mockJson = '''
        [
          {
            "id": "ustadz_ai",
            "label": "Ustadz AI",
            "iconName": "smart_toy",
            "colorHex": "#8B4513",
            "route": "/ustadz-ai",
            "order": 1,
            "isEnabled": true,
            "isPrimary": false
          }
        ]
        ''';

        when(() => mockRemoteConfig.fetchAndActivate())
            .thenAnswer((_) async => true);
        when(() => mockRemoteConfig.getString('secondary_menu_items'))
            .thenReturn(mockJson);

        // Act
        final result = await menuService.getSecondaryMenuItems();

        // Assert
        expect(result, hasLength(1));
        expect(result[0].id, equals('ustadz_ai'));
        expect(result[0].label, equals('Ustadz AI'));
        expect(result[0].route, equals('/ustadz-ai'));
      });

      test('returns default items when remote config fails', () async {
        // Arrange
        when(() => mockRemoteConfig.fetchAndActivate())
            .thenThrow(Exception('Remote config error'));

        // Act
        final result = await menuService.getSecondaryMenuItems();

        // Assert
        expect(result, isNotEmpty);
        // Should contain default secondary items
        final aiItem = result.firstWhere((item) => item.id == 'ustadz_ai');
        expect(aiItem.label, equals('Ustadz AI'));
      });
    });

    group('MenuItem', () {
      test('parses icon name correctly', () {
        const menuItem = MenuItem(
          id: 'test',
          label: 'Test',
          iconName: 'menu_book_rounded',
          colorHex: '#2D5016',
          route: '/test',
          order: 1,
          isEnabled: true,
          isPrimary: true,
        );

        expect(
            menuItem.icon.codePoint, equals(Icons.menu_book_rounded.codePoint));
      });

      test('parses color correctly', () {
        const menuItem = MenuItem(
          id: 'test',
          label: 'Test',
          iconName: 'apps',
          colorHex: '#2D5016',
          route: '/test',
          order: 1,
          isEnabled: true,
          isPrimary: true,
        );

        expect(menuItem.color, equals(const Color(0xFF2D5016)));
      });

      test('handles unknown icon name with default', () {
        const menuItem = MenuItem(
          id: 'test',
          label: 'Test',
          iconName: 'unknown_icon',
          colorHex: '#2D5016',
          route: '/test',
          order: 1,
          isEnabled: true,
          isPrimary: true,
        );

        expect(menuItem.icon.codePoint, equals(Icons.apps.codePoint));
      });

      test('handles invalid color with default', () {
        const menuItem = MenuItem(
          id: 'test',
          label: 'Test',
          iconName: 'apps',
          colorHex: 'invalid_color',
          route: '/test',
          order: 1,
          isEnabled: true,
          isPrimary: true,
        );

        expect(menuItem.color, equals(Colors.blue)); // Default fallback color
      });
    });
  });
}
