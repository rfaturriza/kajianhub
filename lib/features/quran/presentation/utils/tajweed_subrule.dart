import 'package:hive_ce/hive.dart';

part 'tajweed_subrule.g.dart';

@HiveType(typeId: 3)
enum TajweedSubrule {
  @HiveField(0)
  noonSakinAndTanweens,
  @HiveField(1)
  meemSakin,
  @HiveField(2)
  misleyn,
  @HiveField(3)
  mutajaniseyn,
  @HiveField(4)
  mutagaribeyn,
  @HiveField(5)
  shamsiyya,
  @HiveField(6)
  gamariyya,

  //prolonging
  @HiveField(7)
  byTwo,
  @HiveField(8)
  muttasil(1),
  @HiveField(9)
  munfasil(2),
  @HiveField(10)
  lazim,
  @HiveField(11)
  lin,
  @HiveField(12)
  ivad;

  const TajweedSubrule([this.priority = 100]);

  final int priority;
}
