import 'package:hive_ce/hive.dart';

import 'tajweed_rule.dart';
import 'tajweed_subrule.dart';

part 'tajweed_token.g.dart';

@HiveType(typeId: 1)
class TajweedToken extends HiveObject implements Comparable<TajweedToken> {
  @HiveField(0)
  TajweedRule rule;
  @HiveField(1)
  TajweedSubrule? subrule;
  @HiveField(2)
  int? subruleSubindex;

  @HiveField(3)
  String? matchGroup;
  @HiveField(4)
  String text;

  @HiveField(5)
  int startIx;
  @HiveField(6)
  int endIx;

  TajweedToken(
    this.rule,
    this.subrule,
    this.subruleSubindex,
    this.text,
    this.startIx,
    this.endIx,
    this.matchGroup,
  );

  bool isRule() {
    return rule != TajweedRule.none;
  }

  bool isNotRule() {
    return rule == TajweedRule.none;
  }

  bool get canBreakAfter => text.endsWith(' ');

  @override
  int compareTo(TajweedToken other) {
    if (startIx < other.startIx) {
      return -1;
    } else if (startIx > other.startIx) {
      return 1;
    }

    return 0;
  }

  @override
  String toString() {
    return 'TajweedToken{ from: $startIx to: $endIx group: $rule subrule: $subrule subindex: $subruleSubindex text: \'$text\' matchGroup: $matchGroup }';
  }
}
