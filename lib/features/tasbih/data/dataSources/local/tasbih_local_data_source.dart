import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/entities/tasbih_counter.codegen.dart';
import '../../models/tasbih_counter_model.codegen.dart';

abstract class TasbihLocalDataSource {
  Future<List<TasbihCounterModel>> getTasbihCounters();
  Future<TasbihCounterModel> incrementCounter(String counterId);
  Future<TasbihCounterModel> resetCounter(String counterId);
  Future<TasbihCounterModel> updateTarget(String counterId, int newTarget);
  Future<List<TasbihSessionModel>> getTasbihSessions();
  Future<TasbihSessionModel> startSession(List<String> counterIds);
  Future<TasbihSessionModel> endSession(String sessionId);
  Future<void> resetAllCounters();
  Future<TasbihCounterModel> createCustomCounter({
    required String name,
    required String arabicText,
    required String transliteration,
    required String translation,
    required int target,
  });
  Future<void> deleteCustomCounter(String counterId);
}

@LazySingleton(as: TasbihLocalDataSource)
class TasbihLocalDataSourceImpl implements TasbihLocalDataSource {
  final SharedPreferences _prefs;
  static const String _countersKey = 'tasbih_counters';
  static const String _sessionsKey = 'tasbih_sessions';

  TasbihLocalDataSourceImpl(this._prefs);

  @override
  Future<List<TasbihCounterModel>> getTasbihCounters() async {
    final String? countersJson = _prefs.getString(_countersKey);

    if (countersJson == null) {
      // Initialize with default counters
      final defaultCounters = TasbihCounter.defaultTasbihList
          .map((counter) => TasbihCounterModel.fromEntity(counter))
          .toList();
      await _saveCounters(defaultCounters);
      return defaultCounters;
    }

    final List<dynamic> countersList = json.decode(countersJson);
    return countersList
        .map(
            (json) => TasbihCounterModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<TasbihCounterModel> incrementCounter(String counterId) async {
    final counters = await getTasbihCounters();
    final counterIndex = counters.indexWhere((c) => c.id == counterId);

    if (counterIndex == -1) {
      throw Exception('Counter not found: $counterId');
    }

    final updatedCounter = counters[counterIndex].copyWith(
      count: counters[counterIndex].count + 1,
      lastUsed: DateTime.now(),
      isCompleted:
          counters[counterIndex].count + 1 >= counters[counterIndex].target,
    );

    counters[counterIndex] = updatedCounter;
    await _saveCounters(counters);

    return updatedCounter;
  }

  @override
  Future<TasbihCounterModel> resetCounter(String counterId) async {
    final counters = await getTasbihCounters();
    final counterIndex = counters.indexWhere((c) => c.id == counterId);

    if (counterIndex == -1) {
      throw Exception('Counter not found: $counterId');
    }

    final resetCounter = counters[counterIndex].copyWith(
      count: 0,
      isCompleted: false,
      lastUsed: DateTime.now(),
    );

    counters[counterIndex] = resetCounter;
    await _saveCounters(counters);

    return resetCounter;
  }

  @override
  Future<TasbihCounterModel> updateTarget(
      String counterId, int newTarget) async {
    final counters = await getTasbihCounters();
    final counterIndex = counters.indexWhere((c) => c.id == counterId);

    if (counterIndex == -1) {
      throw Exception('Counter not found: $counterId');
    }

    final updatedCounter = counters[counterIndex].copyWith(
      target: newTarget,
      isCompleted: counters[counterIndex].count >= newTarget,
      lastUsed: DateTime.now(),
    );

    counters[counterIndex] = updatedCounter;
    await _saveCounters(counters);

    return updatedCounter;
  }

  @override
  Future<void> resetAllCounters() async {
    final counters = await getTasbihCounters();
    final resetCounters = counters
        .map((counter) => counter.copyWith(
            count: 0, isCompleted: false, lastUsed: DateTime.now()))
        .toList();

    await _saveCounters(resetCounters);
  }

  @override
  Future<TasbihCounterModel> createCustomCounter({
    required String name,
    required String arabicText,
    required String transliteration,
    required String translation,
    required int target,
  }) async {
    final counters = await getTasbihCounters();
    final newCounter = TasbihCounterModel(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      arabicText: arabicText,
      transliteration: transliteration,
      translation: translation,
      target: target,
      lastUsed: DateTime.now(),
    );

    counters.add(newCounter);
    await _saveCounters(counters);

    return newCounter;
  }

  @override
  Future<void> deleteCustomCounter(String counterId) async {
    final counters = await getTasbihCounters();
    counters.removeWhere((counter) => counter.id == counterId);
    await _saveCounters(counters);
  }

  @override
  Future<List<TasbihSessionModel>> getTasbihSessions() async {
    final String? sessionsJson = _prefs.getString(_sessionsKey);

    if (sessionsJson == null) return [];

    final List<dynamic> sessionsList = json.decode(sessionsJson);
    return sessionsList
        .map(
            (json) => TasbihSessionModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<TasbihSessionModel> startSession(List<String> counterIds) async {
    final counters = await getTasbihCounters();
    final sessionCounters =
        counters.where((counter) => counterIds.contains(counter.id)).toList();

    final session = TasbihSessionModel(
      id: 'session_${DateTime.now().millisecondsSinceEpoch}',
      counters: sessionCounters,
      startTime: DateTime.now(),
    );

    final sessions = await getTasbihSessions();
    sessions.add(session);
    await _saveSessions(sessions);

    return session;
  }

  @override
  Future<TasbihSessionModel> endSession(String sessionId) async {
    final sessions = await getTasbihSessions();
    final sessionIndex = sessions.indexWhere((s) => s.id == sessionId);

    if (sessionIndex == -1) {
      throw Exception('Session not found: $sessionId');
    }

    final updatedSession = sessions[sessionIndex].copyWith(
      endTime: DateTime.now(),
      isCompleted: true,
    );

    sessions[sessionIndex] = updatedSession;
    await _saveSessions(sessions);

    return updatedSession;
  }

  Future<void> _saveCounters(List<TasbihCounterModel> counters) async {
    final countersJson = json.encode(
      counters.map((counter) => counter.toJson()).toList(),
    );
    await _prefs.setString(_countersKey, countersJson);
  }

  Future<void> _saveSessions(List<TasbihSessionModel> sessions) async {
    final sessionsJson = json.encode(
      sessions.map((session) => session.toJson()).toList(),
    );
    await _prefs.setString(_sessionsKey, sessionsJson);
  }
}
