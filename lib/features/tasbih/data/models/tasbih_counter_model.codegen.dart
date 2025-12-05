import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/tasbih_counter.codegen.dart';

part 'tasbih_counter_model.codegen.freezed.dart';
part 'tasbih_counter_model.codegen.g.dart';

@freezed
abstract class TasbihCounterModel with _$TasbihCounterModel {
  const factory TasbihCounterModel({
    required String id,
    required String name,
    required String arabicText,
    required String transliteration,
    required String translation,
    @Default(0) int count,
    @Default(33) int target,
    @Default(false) bool isCompleted,
    DateTime? lastUsed,
  }) = _TasbihCounterModel;

  factory TasbihCounterModel.fromJson(Map<String, dynamic> json) =>
      _$TasbihCounterModelFromJson(json);

  const TasbihCounterModel._();

  TasbihCounter toEntity() => TasbihCounter(
        id: id,
        name: name,
        arabicText: arabicText,
        transliteration: transliteration,
        translation: translation,
        count: count,
        target: target,
        isCompleted: isCompleted,
        lastUsed: lastUsed,
      );

  factory TasbihCounterModel.fromEntity(TasbihCounter entity) =>
      TasbihCounterModel(
        id: entity.id,
        name: entity.name,
        arabicText: entity.arabicText,
        transliteration: entity.transliteration,
        translation: entity.translation,
        count: entity.count,
        target: entity.target,
        isCompleted: entity.isCompleted,
        lastUsed: entity.lastUsed,
      );
}

@freezed
abstract class TasbihSessionModel with _$TasbihSessionModel {
  const factory TasbihSessionModel({
    required String id,
    required List<TasbihCounterModel> counters,
    required DateTime startTime,
    DateTime? endTime,
    @Default(0) int totalCount,
    @Default(false) bool isCompleted,
  }) = _TasbihSessionModel;

  factory TasbihSessionModel.fromJson(Map<String, dynamic> json) =>
      _$TasbihSessionModelFromJson(json);

  const TasbihSessionModel._();

  TasbihSession toEntity() => TasbihSession(
        id: id,
        counters: counters.map((model) => model.toEntity()).toList(),
        startTime: startTime,
        endTime: endTime,
        totalCount: totalCount,
        isCompleted: isCompleted,
      );

  factory TasbihSessionModel.fromEntity(TasbihSession entity) =>
      TasbihSessionModel(
        id: entity.id,
        counters: entity.counters
            .map((counter) => TasbihCounterModel.fromEntity(counter))
            .toList(),
        startTime: entity.startTime,
        endTime: entity.endTime,
        totalCount: entity.totalCount,
        isCompleted: entity.isCompleted,
      );
}
