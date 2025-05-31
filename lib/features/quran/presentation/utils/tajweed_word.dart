import 'package:hive_ce/hive.dart';

import 'tajweed_token.dart';

part 'tajweed_word.g.dart';

@HiveType(typeId: 4)
class TajweedWord extends HiveObject {
  @HiveField(0)
  final List<TajweedToken> tokens;

  TajweedWord({this.tokens = const []});
}

@HiveType(typeId: 5)
class TajweedWordList extends HiveObject {
  @HiveField(0)
  final List<TajweedWord> words;

  TajweedWordList({this.words = const []});
}
