import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:quranku/features/quran/presentation/utils/tajweed_word.dart';
import 'package:hive_ce/hive.dart';
import 'package:quranku/core/constants/hive_constants.dart';
import 'package:quranku/features/quran/domain/entities/verses.codegen.dart';
import 'package:quranku/features/quran/presentation/screens/components/verses_list.dart';
import 'package:quranku/core/utils/helper.dart';

import 'tajweed.dart';

class HelperTajweed {
  static Future<List<TajweedWord>> _generateAyasWithTajweed(
    List<String?>? ayas,
  ) async {
    if (ayas == null) {
      return [];
    }
    final result = <TajweedWord>[];
    for (var index = 0; index < ayas.length; index++) {
      final line = ayas[index] ?? '';
      final tajweedWord = TajweedWord(tokens: Tajweed.tokenize(line, 2, index));
      result.add(tajweedWord);
    }
    return result;
  }

  static Future<List<TajweedWord>?> _checkCacheTajweed(
    ViewMode viewMode,

    /// Juz Number or Surah Number
    String number,
  ) async {
    final settingBox = await Hive.openBox(HiveConst.settingBox);
    final tajweedCacheBox = await Hive.openBox<TajweedWordList>(
      HiveConst.tajweedCacheBox,
    );

    // Check if Tajweed is enabled
    final isTajweedEnabled = settingBox.get(HiveConst.tajweedStatusKey) ?? true;
    if (!isTajweedEnabled) {
      return null;
    }

    // Get app version info
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;

    // Define the specific version for which you want to clear the cache
    const versionToClear = '1.10.3';

    // Check if cache clear has already been performed for the specific version
    final cacheClearedForVersion = settingBox.get(
          HiveConst.tajweedCacheClearedVersionKey,
        ) ==
        versionToClear;

    // If the app is at the specific version and the cache has not been cleared yet, clear it
    if (isVersionGreater(currentVersion, versionToClear) &&
        !cacheClearedForVersion) {
      await tajweedCacheBox.clear();
      await settingBox.put(
        HiveConst.tajweedCacheClearedVersionKey,
        versionToClear,
      );
    }

    final key = () {
      switch (viewMode) {
        case ViewMode.juz:
          return 'juz_$number';
        case ViewMode.surah:
          return 'surah_$number';
        case ViewMode.setting:
          return 'setting';
      }
    }();
    final cached = tajweedCacheBox.get(key);
    if (cached != null) {
      return cached.words;
    }
    return null;
  }

  static Future<void> _saveCacheTajweed(
    List<TajweedWord> tajweedWords,
    ViewMode viewMode,

    /// Juz Number or Surah Number
    String number,
  ) async {
    final tajweedCacheBox = await Hive.openBox<TajweedWordList>(
      HiveConst.tajweedCacheBox,
    );
    final key = () {
      switch (viewMode) {
        case ViewMode.juz:
          return 'juz_$number';
        case ViewMode.surah:
          return 'surah_$number';
        case ViewMode.setting:
          return 'setting';
      }
    }();
    await tajweedCacheBox.put(key, TajweedWordList(words: tajweedWords));
  }

  static Future<List<TajweedWord>?> loadAyas(
    List<Verses> listVerses,
    ViewMode viewMode,
    String juzNumberOrSurahNumber,
  ) async {
    try {
      final cached = await _checkCacheTajweed(
        viewMode,
        juzNumberOrSurahNumber,
      );
      if (cached != null) {
        return cached;
      }
      final result = await compute(
        _generateAyasWithTajweed,
        listVerses.map((e) => e.text?.arab).toList(),
      );
      await _saveCacheTajweed(
        result,
        viewMode,
        juzNumberOrSurahNumber,
      );
      return result;
    } catch (e) {
      return null;
    }
  }
}
