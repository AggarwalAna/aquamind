// lib/race_session_storage.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'race_session.dart';

class RaceSessionStorage {
  // Singleton pattern setup
  RaceSessionStorage._internal();
  static final RaceSessionStorage instance = RaceSessionStorage._internal();

  static const String _storageKey = 'saved_race_sessions';

  // In-memory list
  final List<RaceSession> completedSessions = [];

  /// Initialize and load sessions from disk
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_storageKey);

    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        completedSessions.clear();
        completedSessions.addAll(
          jsonList.map(
              (item) => RaceSession.fromJson(item as Map<String, dynamic>)),
        );
      } catch (e) {
        debugPrint('Error loading saved race sessions: $e');
      }
    }
  }

  /// Backward-compatible alias for init()
  static Future<void> loadSessions() async {
    await instance.init();
  }

  /// Write current list state to disk
  Future<void> _saveToDisk() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> jsonList =
        completedSessions.map((session) => session.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(jsonList));
  }

  /// Add a new race session and persist to disk
  Future<void> addSession(RaceSession session) async {
    completedSessions.add(session);
    await _saveToDisk();
  }

  /// Delete a race session and persist change to disk
  Future<void> deleteSession(RaceSession session) async {
    completedSessions.remove(session);
    await _saveToDisk();
  }

  /// Get filtered list of race sessions matching event and pool safely handling nulls
  List<RaceSession> getRacesForEvent(String eventName, String poolType) {
    return completedSessions.where((race) {
      final raceEvent = race.event ?? '';
      final racePool = race.pool ?? '';
      return raceEvent.toLowerCase() == eventName.toLowerCase() &&
          racePool.toLowerCase() == poolType.toLowerCase();
    }).toList();
  }

  /// Returns the latest logged race session (last item in the list)
  RaceSession? getLatest() {
    if (completedSessions.isEmpty) return null;
    return completedSessions.last;
  }

  /// Returns the first session with low confidence or notes missing as a fallback check
  RaceSession? getIncompleteSession() {
    try {
      return completedSessions.firstWhere(
          (session) => session.time == null || session.time!.isEmpty);
    } catch (_) {
      return null;
    }
  }
}
