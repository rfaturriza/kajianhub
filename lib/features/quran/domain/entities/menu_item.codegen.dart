import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../generated/locale_keys.g.dart';

part 'menu_item.codegen.freezed.dart';
part 'menu_item.codegen.g.dart';

@freezed
abstract class MenuItem with _$MenuItem {
  const factory MenuItem({
    required String id,
    required String label, // Fallback label if labelKey is not found
    String? labelKey, // Locale key for localization (optional)
    required String iconName,
    required String colorHex,
    required String route,
    required int order,
    String? badge, // Optional badge text
    String? badgeColorHex, // Optional badge color in hex
    @Default(true) bool isEnabled,
    @Default(false) bool isPrimary,
  }) = _MenuItem;

  factory MenuItem.fromJson(Map<String, dynamic> json) =>
      _$MenuItemFromJson(json);

  const MenuItem._();

  IconData get icon {
    // Map icon names to actual IconData
    switch (iconName.toLowerCase()) {
      case 'menu_book_rounded':
      case 'quran':
      case 'book':
        return Symbols.menu_book_rounded;
      case 'play_circle':
      case 'kajian':
      case 'video':
        return Symbols.play_circle;
      case 'person':
      case 'ustadz':
      case 'teacher':
        return Symbols.person;
      case 'live_tv':
      case 'live':
      case 'streaming':
        return Symbols.live_tv;
      case 'school':
      case 'belajar':
      case 'education':
        return Symbols.school;
      case 'mosque':
      case 'masjid':
        return Symbols.location_on;
      case 'prayer':
      case 'shalat':
        return Symbols.access_time;
      case 'favorite':
      case 'doa':
      case 'heart':
        return Symbols.favorite;
      case 'article':
      case 'buletin':
      case 'news':
        return Symbols.article;
      case 'smart_toy':
      case 'ai':
      case 'robot':
        return Symbols.smart_toy;
      default:
        return Symbols.apps;
    }
  }

  Color get color {
    try {
      return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.blue; // fallback color
    }
  }

  /// Get localized label using labelKey if available, fallback to label
  String get localizedLabel {
    if (labelKey != null && labelKey!.isNotEmpty) {
      try {
        // Use reflection-like approach to get the locale key
        return _getLocalizedText(labelKey!);
      } catch (e) {
        // Fallback to original label if locale key not found
        return label;
      }
    }
    return label;
  }

  /// Map locale keys to actual localized text
  String _getLocalizedText(String localeKey) {
    switch (localeKey) {
      case 'quran':
        return 'Al-Qur\'an'; // Static as it's Arabic
      case 'kajian':
        return LocaleKeys.kajian.tr();
      case 'ustadz':
        return LocaleKeys.ustadz.tr();
      case 'shalat':
      case 'prayer':
        return 'Shalat'; // Religious term, same in both languages
      case 'masjid':
      case 'mosque':
        return 'Masjid'; // Religious term, same in both languages
      case 'doa':
      case 'pray':
        return 'Doa'; // Religious term, same in both languages
      case 'buletin':
      case 'news':
        return LocaleKeys.buletin.tr();
      case 'ustadz_ai':
      case 'ai_assistant':
        return LocaleKeys.ustadzAiButtonLabel.tr();
      case 'qibla':
        return 'Qibla'; // Religious term, same in both languages
      default:
        return label; // Fallback to original label
    }
  }
}
