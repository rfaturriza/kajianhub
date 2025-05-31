import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:quranku/generated/locale_keys.g.dart';

part 'tajweed_rule.g.dart';

@HiveType(typeId: 2)
enum TajweedRule {
  @HiveField(0)
  LAFZATULLAH(
    1,
    color: Colors.green,
    darkThemeColor: Color.fromRGBO(129, 199, 132, 1),
  ),
  @HiveField(1)
  izhar(
    2,
    color: Color.fromARGB(255, 6, 176, 182),
    darkThemeColor: Color.fromARGB(255, 111, 240, 245),
  ),
  @HiveField(2)
  ikhfaa(
    3,
    color: Color(0xFFB71C1C),
    darkThemeColor: Color.fromARGB(255, 250, 68, 68),
  ),
  @HiveField(3)
  idghamWithGhunna(
    4,
    color: Color(0xFFF06292),
  ),
  @HiveField(4)
  iqlab(
    5,
    color: Colors.blue,
  ),
  @HiveField(5)
  qalqala(
    6,
    color: Color.fromARGB(255, 123, 143, 10),
    darkThemeColor: Color.fromARGB(255, 214, 240, 70),
  ),
  @HiveField(6)
  idghamWithoutGhunna(
    7,
    color: Colors.grey,
  ),
  @HiveField(7)
  ghunna(
    8,
    color: Colors.orange,
  ),
  @HiveField(8)
  prolonging(
    9,
    color: Color.fromARGB(
      255,
      142,
      100,
      214,
    ),
    darkThemeColor: Color.fromARGB(255, 191, 165, 236),
  ),
  @HiveField(9)
  alefTafreeq(
    10,
    color: Colors.grey,
  ),
  @HiveField(10)
  hamzatulWasli(
    11,
    color: Colors.grey,
  ),
  @HiveField(11)
  none(100, color: null);

  const TajweedRule(
    this.priority, {
    required Color? color,
    Color? darkThemeColor,
  })  : _color = color,
        _darkThemeColor = darkThemeColor;

  final int priority;
  final Color? _color;
  final Color? _darkThemeColor;

  Color? color(BuildContext context) {
    if (_darkThemeColor == null) {
      return _color;
    }

    bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return isDarkTheme ? _darkThemeColor : _color;
  }

  static String getTitle(TajweedRule rule) {
    switch (rule) {
      case TajweedRule.LAFZATULLAH:
        return "LAFZATULLAH";
      case TajweedRule.izhar:
        return "Izhar";
      case TajweedRule.ikhfaa:
        return "Ikhfaa";
      case TajweedRule.idghamWithGhunna:
        return "Idgham Bighunnah";
      case TajweedRule.iqlab:
        return "Iqlab";
      case TajweedRule.qalqala:
        return "Qalqalah";
      case TajweedRule.idghamWithoutGhunna:
        return "Idgham Bilaghunnah";
      case TajweedRule.ghunna:
        return "Ghunnah";
      case TajweedRule.prolonging:
        return "";
      case TajweedRule.alefTafreeq:
        return "";
      case TajweedRule.hamzatulWasli:
        return "";
      case TajweedRule.none:
        return "";
    }
  }

  static String _getTranslation(String key) {
    return key.tr();
  }

  static String getExplanation(TajweedRule rule) {
    switch (rule) {
      case TajweedRule.LAFZATULLAH:
        return _getTranslation(LocaleKeys.lafazdAllahExplanation_content);
      case TajweedRule.izhar:
        return _getTranslation(LocaleKeys.izharExplanation_content);
      case TajweedRule.ikhfaa:
        return _getTranslation(LocaleKeys.ikhfaExplanation_content);
      case TajweedRule.idghamWithGhunna:
        return _getTranslation(LocaleKeys.idghamBighunnahExplanation_content);
      case TajweedRule.iqlab:
        return _getTranslation(LocaleKeys.iqlabExplanation_content);
      case TajweedRule.qalqala:
        return _getTranslation(LocaleKeys.qalqalahExplanation_content);
      case TajweedRule.idghamWithoutGhunna:
        return _getTranslation(LocaleKeys.idghamBilaGhunnahExplanation_content);
      case TajweedRule.ghunna:
        return _getTranslation(LocaleKeys.ghunnahExplanation_content);
      case TajweedRule.prolonging:
        return "";
      case TajweedRule.alefTafreeq:
        return "";
      case TajweedRule.hamzatulWasli:
        return "";
      case TajweedRule.none:
        return "";
    }
  }

  static String getExample(TajweedRule rule) {
    switch (rule) {
      case TajweedRule.LAFZATULLAH:
        return "يَدْعُو مِنْ دُونِ اللَّهِ";
      case TajweedRule.izhar:
        return "مِنْ غَفُورٍ رَحِيمَ";
      case TajweedRule.ikhfaa:
        return "رِيحًا صَرْصَرًا";
      case TajweedRule.idghamWithGhunna:
        return "مِنْ قَبْلِ أَنْ يَتَمَاسَّا";
      case TajweedRule.iqlab:
        return "كَلَّا\u200C لَيُنۡۢبَذَنَّ فِى الۡحُطَمَةِ";
      case TajweedRule.qalqala:
        return "لَمْ يَلِدْ وَلَمْ يُولَدْ";
      case TajweedRule.idghamWithoutGhunna:
        return "فَضْلًا مِنْ رَبِّكَ";
      case TajweedRule.ghunna:
        return "إِنَّ الَّذِينَ كَفَرُوا";
      case TajweedRule.prolonging:
        return "";
      case TajweedRule.alefTafreeq:
        return "";
      case TajweedRule.hamzatulWasli:
        return "";
      case TajweedRule.none:
        return "";
    }
  }
}
