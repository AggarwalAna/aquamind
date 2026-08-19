// lib/user_storage.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_profile.dart';

class UserStorage {
  static const String _profilesKey = 'aquamind_all_profiles_v2';
  static const String _activeProfileIdKey = 'aquamind_active_profile_id_v2';

  static List<UserProfile> profiles = [];
  static UserProfile? profile;

  // Independent history maps stored by profile ID
  static Map<String, List<dynamic>> activeQueues = {};
  static Map<String, List<dynamic>> completedHistories = {};

  static Future<void> loadAllData() async {
    final prefs = await SharedPreferences.getInstance();

    // Load profiles list
    final profilesJson = prefs.getString(_profilesKey);
    if (profilesJson != null) {
      final List<dynamic> decoded = jsonDecode(profilesJson);
      profiles = decoded.map((item) => UserProfile.fromJson(item)).toList();
    } else {
      profiles = [];
    }

    // Load active profile ID
    final activeId = prefs.getString(_activeProfileIdKey);
    if (profiles.isNotEmpty) {
      if (activeId != null && profiles.any((p) => p.id == activeId)) {
        profile = profiles.firstWhere((p) => p.id == activeId);
      } else {
        profile = profiles.first;
      }
    } else {
      profile = null;
    }

    // Load history for all profiles
    for (var p in profiles) {
      final queueJson = prefs.getString('queue_${p.id}');
      if (queueJson != null) {
        activeQueues[p.id] = jsonDecode(queueJson);
      } else {
        activeQueues[p.id] = [];
      }

      final historyJson = prefs.getString('history_${p.id}');
      if (historyJson != null) {
        completedHistories[p.id] = jsonDecode(historyJson);
      } else {
        completedHistories[p.id] = [];
      }
    }
  }

  static Future<UserProfile?> loadProfile() async {
    await loadAllData();
    return profile;
  }

  static Future<void> saveProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(profiles.map((p) => p.toJson()).toList());
    await prefs.setString(_profilesKey, encoded);
    if (profile != null) {
      await prefs.setString(_activeProfileIdKey, profile!.id);
    }
  }

  static Future<void> saveActiveProfile(UserProfile newProfile) async {
    final index = profiles.indexWhere((p) => p.id == newProfile.id);
    if (index >= 0) {
      profiles[index] = newProfile;
    } else {
      profiles.add(newProfile);
    }
    profile = newProfile;
    await saveProfiles();
  }

  static Future<void> switchProfile(String profileId) async {
    final match = profiles.firstWhere((p) => p.id == profileId);
    profile = match;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeProfileIdKey, profileId);
  }
}
