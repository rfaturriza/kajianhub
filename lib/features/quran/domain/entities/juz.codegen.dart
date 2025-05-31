import 'package:easy_localization/easy_localization.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../generated/locale_keys.g.dart';

part 'juz.codegen.freezed.dart';
part 'juz.codegen.g.dart';

@freezed
abstract class JuzConstant with _$JuzConstant {
  const factory JuzConstant({
    required int number,
    required String name,
    required String description,
  }) = _JuzConstant;

  const JuzConstant._();

  factory JuzConstant.fromJson(Map<String, dynamic> json) =>
      _$JuzConstantFromJson(json);

  static List<JuzConstant> juzList = [
    JuzConstant(
        number: 1,
        name: 'Juz 1',
        description: LocaleKeys.juzOneDescription.tr()),
    JuzConstant(
        number: 2,
        name: 'Juz 2',
        description: LocaleKeys.juzTwoDescription.tr()),
    JuzConstant(
        number: 3,
        name: 'Juz 3',
        description: LocaleKeys.juzThreeDescription.tr()),
    JuzConstant(
        number: 4,
        name: 'Juz 4',
        description: LocaleKeys.juzFourDescription.tr()),
    JuzConstant(
        number: 5,
        name: 'Juz 5',
        description: LocaleKeys.juzFiveDescription.tr()),
    JuzConstant(
        number: 6,
        name: 'Juz 6',
        description: LocaleKeys.juzSixDescription.tr()),
    JuzConstant(
        number: 7,
        name: 'Juz 7',
        description: LocaleKeys.juzSevenDescription.tr()),
    JuzConstant(
        number: 8,
        name: 'Juz 8',
        description: LocaleKeys.juzEightDescription.tr()),
    JuzConstant(
        number: 9,
        name: 'Juz 9',
        description: LocaleKeys.juzNineDescription.tr()),
    JuzConstant(
        number: 10,
        name: 'Juz 10',
        description: LocaleKeys.juzTenDescription.tr()),
    JuzConstant(
        number: 11,
        name: 'Juz 11',
        description: LocaleKeys.juzElevenDescription.tr()),
    JuzConstant(
        number: 12,
        name: 'Juz 12',
        description: LocaleKeys.juzTwelveDescription.tr()),
    JuzConstant(
        number: 13,
        name: 'Juz 13',
        description: LocaleKeys.juzThirteenDescription.tr()),
    JuzConstant(
        number: 14,
        name: 'Juz 14',
        description: LocaleKeys.juzFourteenDescription.tr()),
    JuzConstant(
        number: 15,
        name: 'Juz 15',
        description: LocaleKeys.juzFifteenDescription.tr()),
    JuzConstant(
        number: 16,
        name: 'Juz 16',
        description: LocaleKeys.juzSixteenDescription.tr()),
    JuzConstant(
        number: 17,
        name: 'Juz 17',
        description: LocaleKeys.juzSeventeenDescription.tr()),
    JuzConstant(
        number: 18,
        name: 'Juz 18',
        description: LocaleKeys.juzEighteenDescription.tr()),
    JuzConstant(
        number: 19,
        name: 'Juz 19',
        description: LocaleKeys.juzNineteenDescription.tr()),
    JuzConstant(
        number: 20,
        name: 'Juz 20',
        description: LocaleKeys.juzTwentyDescription.tr()),
    JuzConstant(
        number: 21,
        name: 'Juz 21',
        description: LocaleKeys.juzTwentyOneDescription.tr()),
    JuzConstant(
        number: 22,
        name: 'Juz 22',
        description: LocaleKeys.juzTwentyTwoDescription.tr()),
    JuzConstant(
        number: 23,
        name: 'Juz 23',
        description: LocaleKeys.juzTwentyThreeDescription.tr()),
    JuzConstant(
        number: 24,
        name: 'Juz 24',
        description: LocaleKeys.juzTwentyFourDescription.tr()),
    JuzConstant(
        number: 25,
        name: 'Juz 25',
        description: LocaleKeys.juzTwentyFiveDescription.tr()),
    JuzConstant(
        number: 26,
        name: 'Juz 26',
        description: LocaleKeys.juzTwentySixDescription.tr()),
    JuzConstant(
        number: 27,
        name: 'Juz 27',
        description: LocaleKeys.juzTwentySevenDescription.tr()),
    JuzConstant(
        number: 28,
        name: 'Juz 28',
        description: LocaleKeys.juzTwentyEightDescription.tr()),
    JuzConstant(
        number: 29,
        name: 'Juz 29',
        description: LocaleKeys.juzTwentyNineDescription.tr()),
    JuzConstant(
        number: 30,
        name: 'Juz 30',
        description: LocaleKeys.juzThirtyDescription.tr()),
  ];
}
