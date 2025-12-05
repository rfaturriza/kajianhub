import 'package:freezed_annotation/freezed_annotation.dart';

part 'tasbih_counter.codegen.freezed.dart';
part 'tasbih_counter.codegen.g.dart';

@freezed
abstract class TasbihCounter with _$TasbihCounter {
  const factory TasbihCounter({
    required String id,
    required String name,
    required String arabicText,
    required String transliteration,
    required String translation,
    @Default(0) int count,
    @Default(33) int target,
    @Default(false) bool isCompleted,
    DateTime? lastUsed,
  }) = _TasbihCounter;

  factory TasbihCounter.fromJson(Map<String, dynamic> json) =>
      _$TasbihCounterFromJson(json);

  const TasbihCounter._();

  static List<TasbihCounter> get defaultTasbihList => [
        const TasbihCounter(
          id: 'subhanallah',
          name: 'Subhan Allah',
          arabicText: 'سُبْحَانَ اللَّهِ',
          transliteration: 'Subhaan Allah',
          translation: 'Glory be to Allah',
          target: 33,
        ),
        const TasbihCounter(
          id: 'alhamdulillah',
          name: 'Alhamdulillah',
          arabicText: 'الْحَمْدُ لِلَّهِ',
          transliteration: 'Alhamdulillah',
          translation: 'All praise is due to Allah',
          target: 33,
        ),
        const TasbihCounter(
          id: 'allahu_akbar',
          name: 'Allahu Akbar',
          arabicText: 'اللَّهُ أَكْبَرُ',
          transliteration: 'Allahu Akbar',
          translation: 'Allah is the Greatest',
          target: 34,
        ),
        const TasbihCounter(
          id: 'la_ilaha_illallah',
          name: 'La ilaha illallah',
          arabicText: 'لَا إِلَهَ إِلَّا اللَّهُ',
          transliteration: 'La ilaha illa Allah',
          translation: 'There is no god but Allah',
          target: 100,
        ),
        const TasbihCounter(
          id: 'astaghfirullah',
          name: 'Astaghfirullah',
          arabicText: 'أَسْتَغْفِرُ اللَّهَ',
          transliteration: 'Astaghfirullah',
          translation: 'I seek forgiveness from Allah',
          target: 100,
        ),
        const TasbihCounter(
          id: 'la_hawla_wala_quwwata',
          name: 'La hawla wa la quwwata illa billah',
          arabicText: 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
          transliteration: 'La hawla wa la quwwata illa billah',
          translation: 'There is no power except with Allah',
          target: 100,
        ),
      ];

  double get progress => target > 0 ? (count / target).clamp(0.0, 1.0) : 0.0;
  bool get isTargetReached => count >= target;
}

@freezed
abstract class TasbihSession with _$TasbihSession {
  const factory TasbihSession({
    required String id,
    required List<TasbihCounter> counters,
    required DateTime startTime,
    DateTime? endTime,
    @Default(0) int totalCount,
    @Default(false) bool isCompleted,
  }) = _TasbihSession;

  factory TasbihSession.fromJson(Map<String, dynamic> json) =>
      _$TasbihSessionFromJson(json);

  const TasbihSession._();

  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  int get completedCounters =>
      counters.where((counter) => counter.isTargetReached).length;

  double get overallProgress =>
      counters.isNotEmpty ? completedCounters / counters.length : 0.0;
}
