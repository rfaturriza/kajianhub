import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:quranku/features/quran/presentation/utils/tajweed_word.dart';

import '../../../../quran/presentation/utils/tajweed.dart';
import '../../../../quran/presentation/utils/tajweed_rule.dart';

class TajweedExampleCache {
  final _cacheKey = 'exampleTajweedAyah';
  Future<Box> _getBox() async {
    if (!Hive.isBoxOpen('cacheBox')) {
      return await Hive.openBox('cacheBox');
    }
    return Hive.box('cacheBox');
  }

  // ignore: strict_top_level_inference
  List<TajweedWord> _generateExampleAyah(_) {
    return TajweedRule.values.map((rule) {
      return TajweedWord(
        tokens: Tajweed.tokenize(
          TajweedRule.getExample(rule),
          -999,
          rule.index,
        ),
      );
    }).toList();
  }

  Future<List<TajweedWord>> _computeGenerateExampleAyah() async {
    return compute(_generateExampleAyah, null);
  }

  Future<List<TajweedWord>> getExampleAyah() async {
    // Ensure the box is open
    final box = await _getBox();

    // Check if the result is already cached
    if (box.containsKey(_cacheKey)) {
      return (box.get(_cacheKey) as List).cast<TajweedWord>();
    }

    // Otherwise, compute and cache the result
    List<TajweedWord> exampleAyah = await _computeGenerateExampleAyah();

    // Cache the result
    box.put(_cacheKey, exampleAyah);

    return exampleAyah;
  }

  void clearCache() async {
    final box = await _getBox();
    box.delete(_cacheKey);
  }
}
