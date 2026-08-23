// lib/race_session_storage.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'race_session.dart';

class RaceSessionStorage {
  // Singleton pattern setup
  RaceSessionStorage._internal();
  static final RaceSessionStorage instance = RaceSessionStorage._internal();

  static const String _storageKey = 'saved_race_sessions_v1';

  // In-memory list shared globally across the app
  final List<RaceSession> completedSessions = [];
  bool _hasLoadedOnce = false;

  /// Initialize and load sessions from disk
  Future<void> init() async {
    if (_hasLoadedOnce && completedSessions.isNotEmpty) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_storageKey);

      debugPrint(
        'RaceSessionStorage: Loading from disk. Raw JSON: $jsonString',
      );

      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        completedSessions.clear();
        completedSessions.addAll(
          jsonList.map(
            (item) => RaceSession.fromJson(item as Map<String, dynamic>),
          ),
        );
        debugPrint(
          'RaceSessionStorage: Successfully loaded ${completedSessions.length} sessions.',
        );
      } else {
        debugPrint('RaceSessionStorage: No saved sessions found on disk.');
      }
      _hasLoadedOnce = true;
    } catch (e) {
      debugPrint('Error loading saved race sessions: $e');
    }
  }

  /// Global accessor matching legacy calls
  static Future<void> loadSessions() async {
    await instance.init();
  }

  /// Write current list state to disk
  Future<void> _saveToDisk() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> jsonList = completedSessions
          .map((session) => session.toJson())
          .toList();
      final encodedString = jsonEncode(jsonList);
      await prefs.setString(_storageKey, encodedString);
      debugPrint(
        'RaceSessionStorage: Saved ${completedSessions.length} sessions to disk successfully.',
      );
    } catch (e) {
      debugPrint('Error saving race sessions to disk: $e');
    }
  }

  /// Add a new race session and persist to disk immediately
  Future<void> addSession(RaceSession session) async {
    completedSessions.add(session);
    _hasLoadedOnce = true;
    await _saveToDisk();
  }

  /// Delete a race session and persist change to disk
  Future<void> deleteSession(RaceSession session) async {
    completedSessions.remove(session);
    await _saveToDisk();
  }

  /// Update an existing session and save to disk
  Future<void> updateSession(RaceSession updatedSession) async {
    final index = completedSessions.indexWhere(
      (s) =>
          s == updatedSession ||
          (s.event == updatedSession.event &&
              (s.time == null || s.time!.isEmpty)),
    );

    if (index != -1) {
      completedSessions[index] = updatedSession;
      await _saveToDisk();
    } else {
      await addSession(updatedSession);
    }
  }

  /// Get filtered list of race sessions matching event and pool safely handling nulls
  List<RaceSession> getRacesForEvent(String eventName, String poolType) {
    final cleanTargetEvent = eventName.toLowerCase().replaceAll(
      RegExp(r'\s+|\(|\)'),
      '',
    );
    final cleanTargetPool = poolType.toLowerCase().trim();

    return completedSessions.where((race) {
      final raceEvent = race.event ?? '';
      final racePool = race.pool ?? '';

      final cleanRaceEvent = raceEvent.toLowerCase().replaceAll(
        RegExp(r'\s+|\(|\)'),
        '',
      );
      final cleanRacePool = racePool.toLowerCase().trim();

      bool eventMatches =
          cleanRaceEvent.contains(cleanTargetEvent) ||
          cleanTargetEvent.contains(cleanRaceEvent);
      bool poolMatches =
          cleanRacePool.isEmpty ||
          cleanTargetPool.isEmpty ||
          cleanRacePool == cleanTargetPool;

      return eventMatches && poolMatches;
    }).toList();
  }

  /// Returns the latest logged race session (last item in the list)
  RaceSession? getLatest() {
    if (completedSessions.isEmpty) return null;
    return completedSessions.last;
  }

  /// Returns the first session with no time as a queue check
  RaceSession? getIncompleteSession() {
    try {
      return completedSessions.firstWhere(
        (session) => session.time == null || session.time!.isEmpty,
      );
    } catch (_) {
      return null;
    }
  }
}
