// lib/main.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'user_storage.dart';
import 'onboarding_page.dart';
import 'settings_page.dart';
import 'user_profile.dart';
import 'neuro_coach_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AquaMindApp());
}

class AquaMindApp extends StatelessWidget {
  const AquaMindApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'AquaMind',
      debugShowCheckedModeBanner: false,
      home: LandingLogoPage(),
    );
  }
}

// 1. The First Page showing Logo & Continue Button
class LandingLogoPage extends StatelessWidget {
  const LandingLogoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF061A2B),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Custom Crest Artwork
                Image.asset(
                  'assets/images/aquamind_crest.png',
                  height: 280,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.pool,
                    size: 100,
                    color: Colors.cyanAccent,
                  ),
                ),
                const SizedBox(height: 24),
                // Continue Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyanAccent,
                      foregroundColor: Colors.black,
                    ),
                    onPressed: () async {
                      // Check if profile exists in storage when Continue is tapped
                      await UserStorage.loadAllData();
                      final profile = UserStorage.profile;
                      final bool hasProfile =
                          profile != null && profile.name.trim().isNotEmpty;

                      if (!context.mounted) return;

                      if (hasProfile) {
                        // Subsequent runs: Go straight to Dashboard
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DashboardPage(),
                          ),
                        );
                      } else {
                        // First time: Go to Onboarding Setup
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OnboardingPage(
                              onProfileCreated: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const DashboardPage(),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      }
                    },
                    child: const Text(
                      "Continue",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Data Model for Logged Races / Active Queue with JSON Serialization
class RaceLogEntry {
  final String id;
  final String event;
  final Map<String, int> mentalStateScores;
  final double calculatedMentalReadiness;
  final int energy;
  final int? neuroScoreMs;
  final String date;
  String? finishTime;
  List<String> splits;
  bool isCompleted;

  RaceLogEntry({
    required this.id,
    required this.event,
    required this.mentalStateScores,
    required this.calculatedMentalReadiness,
    required this.energy,
    this.neuroScoreMs,
    required this.date,
    this.finishTime,
    List<String>? splits,
    this.isCompleted = false,
  }) : splits = splits ?? [];

  Map<String, dynamic> toJson() => {
    'id': id,
    'event': event,
    'mentalStateScores': mentalStateScores,
    'calculatedMentalReadiness': calculatedMentalReadiness,
    'energy': energy,
    'neuroScoreMs': neuroScoreMs,
    'date': date,
    'finishTime': finishTime,
    'splits': splits,
    'isCompleted': isCompleted,
  };

  factory RaceLogEntry.fromJson(Map<String, dynamic> json) => RaceLogEntry(
    id: json['id'] ?? '',
    event: json['event'] ?? '',
    mentalStateScores: Map<String, int>.from(json['mentalStateScores'] ?? {}),
    calculatedMentalReadiness:
        (json['calculatedMentalReadiness'] as num?)?.toDouble() ?? 0.0,
    energy: json['energy'] ?? 5,
    neuroScoreMs: json['neuroScoreMs'],
    date: json['date'] ?? '',
    finishTime: json['finishTime'],
    splits: List<String>.from(json['splits'] ?? []),
    isCompleted: json['isCompleted'] ?? false,
  );
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  // Active Race Queue & History Store
  final List<RaceLogEntry> _activeRaceQueue = [];
  final List<RaceLogEntry> _completedRaceHistory = [];

  @override
  void initState() {
    super.initState();
    _loadSavedRaces();
  }

  void _loadSavedRaces() {
    final profileId = UserStorage.profile?.id;
    if (profileId != null) {
      final rawQueue = UserStorage.activeQueues[profileId] ?? [];
      final rawHistory = UserStorage.completedHistories[profileId] ?? [];
      setState(() {
        _activeRaceQueue.clear();
        _activeRaceQueue.addAll(
          rawQueue.map((item) => RaceLogEntry.fromJson(item)),
        );
        _completedRaceHistory.clear();
        _completedRaceHistory.addAll(
          rawHistory.map((item) => RaceLogEntry.fromJson(item)),
        );
      });
    }
  }

  Future<void> _persistRaces() async {
    final profileId = UserStorage.profile?.id;
    if (profileId != null) {
      final queueJson = _activeRaceQueue.map((e) => e.toJson()).toList();
      final historyJson = _completedRaceHistory.map((e) => e.toJson()).toList();
      await UserStorage.saveRaceData(profileId, queueJson, historyJson);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = UserStorage.profile;
    final eventsList = profile?.events ?? [];

    final List<Widget> pages = [
      _buildUserManualTab(),
      StartRacePage(
        profile: profile,
        activeRaceQueue: _activeRaceQueue,
        completedRaceHistory: _completedRaceHistory,
        onQueueUpdated: () {
          _persistRaces();
          setState(() {});
        },
      ),
      _buildProgressTrackerTab(eventsList),
      _buildRacePredictorTab(eventsList),
      NeuroCoachPage(
        profile: profile,
        completedRaceHistory: _completedRaceHistory,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF061A2B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF061A2B),
        elevation: 0,
        title: Text(
          "AquaMind — ${profile?.name ?? 'Swimmer'}",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.cyanAccent),
            tooltip: "Settings",
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
              _loadSavedRaces();
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex < pages.length ? _selectedIndex : 0,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex < pages.length ? _selectedIndex : 0,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF0D2840),
        selectedItemColor: Colors.cyanAccent,
        unselectedItemColor: Colors.white60,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Manual'),
          BottomNavigationBarItem(
            icon: Icon(Icons.play_circle_fill),
            label: 'Race Start',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Progress',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.bolt), label: 'Predictor'),
          BottomNavigationBarItem(
            icon: Icon(Icons.smart_toy),
            label: 'Neuro Coach',
          ),
        ],
      ),
    );
  }

  Widget _buildUserManualTab() {
    final List<Map<String, dynamic>> manualSteps = [
      {
        "stepNum": "STEP 1",
        "title": "Race Start & Queue",
        "icon": Icons.play_circle_fill,
        "color": Colors.cyanAccent,
        "targetIndex": 1,
        "description":
            "Select your upcoming event, assign individual intensity scores to your active mental states, take the required Neuro Score reaction test, and tap 'Start Race Session'.",
      },
      {
        "stepNum": "STEP 2",
        "title": "Complete & Resume Race",
        "icon": Icons.edit_note,
        "color": Colors.greenAccent,
        "targetIndex": 1,
        "description":
            "Right after your race, use the Active Race Queue card on the Race Start tab to enter your final finish time and split breakdowns.",
      },
      {
        "stepNum": "STEP 3",
        "title": "Progress Tracker",
        "icon": Icons.show_chart,
        "color": Colors.purpleAccent,
        "targetIndex": 2,
        "description":
            "Review your historical performance trends and track second drops required to hit your target goals across each event.",
      },
      {
        "stepNum": "STEP 4",
        "title": "Race Predictor",
        "icon": Icons.bolt,
        "color": Colors.amberAccent,
        "targetIndex": 3,
        "description":
            "Generate intelligent split forecasts and optimal pacing strategies automatically once you have completed at least 2 logged race entries.",
      },
      {
        "stepNum": "STEP 5",
        "title": "Settings & Profile",
        "icon": Icons.settings,
        "color": Colors.blueAccent,
        "targetIndex": null,
        "description":
            "Update your swimmer profile, add new events via dropdowns, and modify your Personal Bests anytime.",
      },
    ];

    return Scrollbar(
      thumbVisibility: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.auto_stories, color: Colors.cyanAccent, size: 28),
                SizedBox(width: 10),
                Text(
                  "AquaMind Quick Guide",
                  style: TextStyle(
                    color: Colors.cyanAccent,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              "Follow the chronological sequence below from pre-race setup to post-race analysis:",
              style: TextStyle(color: Colors.white70, fontSize: 13.5),
            ),
            const SizedBox(height: 16),
            ...manualSteps.map((step) {
              return InkWell(
                onTap: () {
                  if (step["targetIndex"] != null) {
                    setState(() {
                      _selectedIndex = step["targetIndex"] as int;
                    });
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsPage(),
                      ),
                    ).then((_) => _loadSavedRaces());
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D2840),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: (step["color"] as Color).withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF061A2B),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          step["icon"] as IconData,
                          color: step["color"] as Color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: (step["color"] as Color).withValues(
                                      alpha: 0.2,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    step["stepNum"] as String,
                                    style: TextStyle(
                                      color: step["color"] as Color,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    step["title"] as String,
                                    style: TextStyle(
                                      color: step["color"] as Color,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              step["description"] as String,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13.5,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.white38),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressTrackerTab(List? eventsList) {
    final safeEvents = eventsList ?? [];
    return Scrollbar(
      thumbVisibility: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Progress Tracker & Goal Delta",
              style: TextStyle(
                color: Colors.purpleAccent,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Track your historical data, event trends, and goal progression cleanly organized by event.",
              style: TextStyle(color: Colors.white70, fontSize: 13.5),
            ),
            const SizedBox(height: 16),
            ...safeEvents.map((evRecord) {
              final evHistory = _completedRaceHistory
                  .where((h) => h.event == evRecord.eventName)
                  .toList();

              String comparisonTime = evRecord.personalBest ?? '';
              double? bestSec;

              for (var h in evHistory) {
                double? sec = _parseTimeToSeconds(h.finishTime ?? '');
                if (sec != null) {
                  if (bestSec == null || sec < bestSec) {
                    bestSec = sec;
                    comparisonTime = h.finishTime ?? '';
                  }
                }
              }

              if (comparisonTime.isEmpty && evRecord.personalBest != null) {
                comparisonTime = evRecord.personalBest!;
                bestSec = _parseTimeToSeconds(comparisonTime);
              }

              double? goalSec = _parseTimeToSeconds(evRecord.goalTime ?? '');
              String deltaText = "Goal time not set";

              if (bestSec != null && goalSec != null) {
                double diff = goalSec - bestSec;
                if (diff >= 0) {
                  deltaText =
                      "Goal achieved! Surpassed by ${diff.toStringAsFixed(2)}s";
                } else {
                  deltaText =
                      "Need ${(-diff).toStringAsFixed(2)}s drop to reach goal";
                }
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D2840),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.purpleAccent.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          evRecord.eventName ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.cyanAccent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "Best: ${comparisonTime.isEmpty ? 'N/A' : comparisonTime}",
                            style: const TextStyle(
                              color: Colors.cyanAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Goal: ${(evRecord.goalTime == null || evRecord.goalTime!.isEmpty) ? 'Not set' : evRecord.goalTime} • $deltaText",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Divider(color: Colors.white24, height: 1),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Race Log History",
                          style: TextStyle(
                            color: Colors.purpleAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          "${evHistory.length} entries recorded",
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    evHistory.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              "No completed races logged for this event yet.",
                              style: TextStyle(
                                color: Colors.white60,
                                fontStyle: FontStyle.italic,
                                fontSize: 13,
                              ),
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF061A2B),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.purpleAccent.withValues(
                                  alpha: 0.2,
                                ),
                              ),
                            ),
                            child: ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: evHistory.length,
                              separatorBuilder: (context, index) =>
                                  const Divider(
                                    color: Colors.white12,
                                    height: 1,
                                  ),
                              itemBuilder: (context, index) {
                                final hist = evHistory[index];
                                String statesStr = hist
                                    .mentalStateScores
                                    .entries
                                    .map((e) => "${e.key}: ${e.value}/10")
                                    .join(', ');
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              hist.date,
                                              style: const TextStyle(
                                                color: Colors.white60,
                                                fontSize: 12,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              "Readiness: ${hist.calculatedMentalReadiness.toStringAsFixed(0)}% | $statesStr",
                                              style: const TextStyle(
                                                color: Colors.white38,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            hist.finishTime ?? 'N/A',
                                            style: const TextStyle(
                                              color: Colors.greenAccent,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                          if (hist.splits.isNotEmpty)
                                            SizedBox(
                                              width: 120,
                                              child: Text(
                                                "Splits: ${hist.splits.join(' / ')}",
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.right,
                                                style: const TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 11.5,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRacePredictorTab(List? eventsList) {
    final safeEvents = eventsList ?? [];
    return Scrollbar(
      thumbVisibility: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Race Predictor & Split Forecasts",
              style: TextStyle(
                color: Colors.amberAccent,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...safeEvents.map((evRecord) {
              final evHistory = _completedRaceHistory
                  .where((h) => h.event == evRecord.eventName)
                  .toList();
              final hasEnoughData = evHistory.length >= 2;

              String predictedSplit1 = "N/A";
              String predictedSplit2 = "N/A";
              String projectedFinish = "N/A";

              if (hasEnoughData) {
                double s1Sum = 0;
                int s1Count = 0;
                double s2Sum = 0;
                int s2Count = 0;
                double finishSum = 0;
                int finishCount = 0;

                for (var h in evHistory) {
                  final s1Sec = h.splits.isNotEmpty
                      ? _parseTimeToSeconds(h.splits.first)
                      : null;
                  if (s1Sec != null) {
                    s1Sum += s1Sec;
                    s1Count++;
                  }
                  final s2Sec = h.splits.length > 1
                      ? _parseTimeToSeconds(h.splits.last)
                      : null;
                  if (s2Sec != null) {
                    s2Sum += s2Sec;
                    s2Count++;
                  }
                  final finSec = _parseTimeToSeconds(h.finishTime ?? '');
                  if (finSec != null) {
                    finishSum += finSec;
                    finishCount++;
                  }
                }

                String formatSec(double avgSec) {
                  int mins = (avgSec ~/ 60);
                  double secs = avgSec % 60;
                  return mins > 0
                      ? "$mins:${secs.toStringAsFixed(2).padLeft(5, '0')}"
                      : secs.toStringAsFixed(2);
                }

                if (s1Count > 0) {
                  predictedSplit1 = formatSec(s1Sum / s1Count);
                }
                if (s2Count > 0) {
                  predictedSplit2 = formatSec(s2Sum / s2Count);
                }
                if (finishCount > 0) {
                  projectedFinish = formatSec(finishSum / finishCount);
                } else if (s1Count > 0 && s2Count > 0) {
                  double totalAvg = (s1Sum / s1Count) + (s2Sum / s2Count);
                  projectedFinish = formatSec(totalAvg);
                }
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D2840),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: hasEnoughData
                        ? Colors.amberAccent.withValues(alpha: 0.5)
                        : Colors.white24,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          evRecord.eventName ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: hasEnoughData
                                ? Colors.green.withValues(alpha: 0.2)
                                : Colors.red.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            hasEnoughData
                                ? "Ready (${evHistory.length} races logged)"
                                : "Need 2+ races (${evHistory.length}/2 logged)",
                            style: TextStyle(
                              color: hasEnoughData
                                  ? Colors.greenAccent
                                  : Colors.redAccent,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (!hasEnoughData)
                      const Text(
                        "Race predictor requires at least 2 completed race entries for this event to calculate accurate split trends and pace projections.",
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      )
                    else ...[
                      const Text(
                        "Predicted Split Strategy (Averaged from recent logs):",
                        style: TextStyle(
                          color: Colors.amberAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "• Split 1 Target: $predictedSplit1\n"
                        "• Final Split Target: $predictedSplit2\n"
                        "• Projected Finish: $projectedFinish",
                        style: const TextStyle(
                          color: Colors.white70,
                          height: 1.5,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  double? _parseTimeToSeconds(String timeStr) {
    if (timeStr.isEmpty) return null;
    try {
      if (timeStr.contains(':')) {
        final parts = timeStr.split(':');
        final mins = double.parse(parts[0]);
        final secs = double.parse(parts[1]);
        return mins * 60 + secs;
      } else {
        return double.parse(timeStr);
      }
    } catch (_) {
      return null;
    }
  }
}

// Dedicated Widget for Race Start & Active Queue Tab with Event Selection Hub
class StartRacePage extends StatefulWidget {
  final UserProfile? profile;
  final List<RaceLogEntry> activeRaceQueue;
  final List<RaceLogEntry> completedRaceHistory;
  final VoidCallback onQueueUpdated;

  const StartRacePage({
    super.key,
    required this.profile,
    required this.activeRaceQueue,
    required this.completedRaceHistory,
    required this.onQueueUpdated,
  });

  @override
  State<StartRacePage> createState() => _StartRacePageState();
}

class _StartRacePageState extends State<StartRacePage> {
  String? _selectedActiveEvent;

  final Set<String> _selectedMentalStates = {"Focused"};
  final Map<String, double> _mentalStateValues = {
    "Focused": 8.0,
    "Anxious": 5.0,
    "Calm": 7.0,
    "Fatigued": 4.0,
    "Pumped": 8.0,
  };

  double _energyLevel = 8.0;

  bool _isTestRunning = false;
  bool _waitingForGreen = false;
  bool _canTap = false;
  DateTime? _startTime;
  int? _reactionTimeMs;
  String _reactionStatus =
      "Tap 'Start Reaction Test' to evaluate mental readiness.";

  final TextEditingController _finishTimeController = TextEditingController();
  List<TextEditingController> _splitControllers = [];

  @override
  void dispose() {
    _finishTimeController.dispose();
    for (var c in _splitControllers) {
      c.dispose();
    }
    super.dispose();
  }

  int getSplitCount(String eventName) {
    if (eventName.contains('1650')) return 33;
    if (eventName.contains('1000')) return 20;
    if (eventName.contains('800')) return 16;
    if (eventName.contains('500')) return 10;
    if (eventName.contains('400')) return 8;
    if (eventName.contains('200')) return 4;
    if (eventName.contains('100')) return 2;
    return 1;
  }

  void _startReactionTest() {
    setState(() {
      _isTestRunning = true;
      _waitingForGreen = true;
      _canTap = false;
      _reactionTimeMs = null;
      _reactionStatus = "Wait for green...";
    });

    final randomDelay = 1500 + Random().nextInt(2500);
    Future.delayed(Duration(milliseconds: randomDelay), () {
      if (!mounted || !_isTestRunning) return;
      setState(() {
        _waitingForGreen = false;
        _canTap = true;
        _startTime = DateTime.now();
        _reactionStatus = "TAP NOW!";
      });
    });
  }

  void _handleReactionTap() {
    if (_waitingForGreen) {
      setState(() {
        _isTestRunning = false;
        _waitingForGreen = false;
        _canTap = false;
        _reactionStatus = "Too early! False start. Try again.";
      });
      return;
    }

    if (_canTap && _startTime != null) {
      final difference = DateTime.now().difference(_startTime!).inMilliseconds;
      setState(() {
        _reactionTimeMs = difference;
        _isTestRunning = false;
        _canTap = false;
        _reactionStatus =
            "Neuro Score / Reaction: ${difference}ms — Ready for Swim!";
      });
    }
  }

  void _startRaceSession() {
    if (_reactionTimeMs == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please complete the Neuro Score Reaction Test before starting a race session!",
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (_selectedActiveEvent == null) return;

    Map<String, int> submittedScores = {};
    for (var state in _selectedMentalStates) {
      submittedScores[state] = (_mentalStateValues[state] ?? 5.0).round();
    }

    double mentalReadinessSum = 0;
    submittedScores.forEach((_, val) => mentalReadinessSum += val);
    double avgMentalState = submittedScores.isNotEmpty
        ? mentalReadinessSum / submittedScores.length
        : 5.0;

    double neuroPenalty = _reactionTimeMs! > 500 ? 5.0 : 0.0;
    double calculatedReadiness =
        (((avgMentalState + _energyLevel) / 20) * 100) - neuroPenalty;
    if (calculatedReadiness < 0) calculatedReadiness = 0;
    if (calculatedReadiness > 100) calculatedReadiness = 100;

    final newEntry = RaceLogEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      event: _selectedActiveEvent!,
      mentalStateScores: submittedScores,
      calculatedMentalReadiness: calculatedReadiness,
      energy: _energyLevel.round(),
      neuroScoreMs: _reactionTimeMs,
      date:
          "${DateTime.now().month}/${DateTime.now().day}/${DateTime.now().year}",
    );

    setState(() {
      widget.activeRaceQueue.insert(0, newEntry);
      _reactionTimeMs = null;
      _reactionStatus =
          "Tap 'Start Reaction Test' to evaluate mental readiness.";
      _selectedActiveEvent = null;
    });

    widget.onQueueUpdated();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Race session queued successfully! Readiness: ${calculatedReadiness.toStringAsFixed(1)}%",
        ),
      ),
    );
  }

  void _showResumeRaceDialog(RaceLogEntry entry) {
    _finishTimeController.text = entry.finishTime ?? '';

    int splitCount = getSplitCount(entry.event);

    for (var c in _splitControllers) {
      c.dispose();
    }
    _splitControllers = List.generate(splitCount, (index) {
      String existingVal = (index < entry.splits.length)
          ? entry.splits[index]
          : '';
      return TextEditingController(text: existingVal);
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0D2840),
        title: Text(
          "Resume Race: ${entry.event}",
          style: const TextStyle(color: Colors.cyanAccent),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Enter final time and splits for ${entry.event} (${entry.date}):",
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _finishTimeController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "Final Finish Time (e.g., 0:32 or 1:02.45)",
                    labelStyle: TextStyle(color: Colors.white60),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.cyanAccent),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.cyanAccent),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Event Splits",
                  style: TextStyle(
                    color: Colors.amberAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: splitCount,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: TextField(
                        controller: _splitControllers[index],
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText:
                              "Split ${index + 1} (at ${(index + 1) * 50} mark)",
                          labelStyle: const TextStyle(color: Colors.white60),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white24),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.amberAccent),
                          ),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.white60),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.greenAccent,
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              final finalT = _finishTimeController.text.trim();
              if (finalT.isNotEmpty) {
                setState(() {
                  entry.finishTime = finalT;
                  entry.splits = _splitControllers
                      .map((c) => c.text.trim())
                      .where((text) => text.isNotEmpty)
                      .toList();
                  entry.isCompleted = true;

                  widget.activeRaceQueue.removeWhere((e) => e.id == entry.id);
                  widget.completedRaceHistory.insert(0, entry);
                });
                widget.onQueueUpdated();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Race ${entry.event} successfully completed & logged!",
                    ),
                  ),
                );
              }
            },
            child: const Text("Save & Complete"),
          ),
        ],
      ),
    );
  }

  Widget _buildLabeledSlider({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
    int divisions = 9,
    double min = 1,
    double max = 10,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.cyanAccent,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Rating: ${value.round()}/${max.toInt()}",
                style: const TextStyle(color: Colors.white60, fontSize: 13),
              ),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            activeColor: Colors.cyanAccent,
            label: value.round().toString(),
            onChanged: onChanged,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Not ${label.toLowerCase()} at all (${min.toInt()})",
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
                Text(
                  "Extremely ${label.toLowerCase()} (${max.toInt()})",
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final eventsList = widget.profile?.events ?? [];
    final mentalStatesList = [
      "Focused",
      "Anxious",
      "Calm",
      "Fatigued",
      "Pumped",
    ];

    return Scrollbar(
      thumbVisibility: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Race Start & Mental Readiness Hub",
              style: TextStyle(
                color: Colors.cyanAccent,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Select an upcoming event from your profile list below to initiate your pre-race mental readiness and reaction test.",
              style: TextStyle(color: Colors.white70, fontSize: 13.5),
            ),
            const SizedBox(height: 16),

            if (widget.activeRaceQueue.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF162D4A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.greenAccent, width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.pending_actions, color: Colors.greenAccent),
                        SizedBox(width: 8),
                        Text(
                          "Active Race Queue (Pending Results)",
                          style: TextStyle(
                            color: Colors.greenAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "You have races waiting for results. Resume them here when finished.",
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.activeRaceQueue.length,
                      itemBuilder: (context, index) {
                        final item = widget.activeRaceQueue[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF061A2B),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.greenAccent.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.event,
                                    style: const TextStyle(
                                      color: Colors.cyanAccent,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Readiness: ${item.calculatedMentalReadiness.toStringAsFixed(0)}% • Energy: ${item.energy}/10",
                                    style: const TextStyle(
                                      color: Colors.white60,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.greenAccent,
                                  foregroundColor: Colors.black,
                                ),
                                onPressed: () => _showResumeRaceDialog(item),
                                icon: const Icon(Icons.edit, size: 16),
                                label: const Text("Resume / Enter Time"),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            if (_selectedActiveEvent == null) ...[
              const Text(
                "Select Event to Start Preparation",
                style: TextStyle(
                  color: Colors.cyanAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              eventsList.isEmpty
                  ? Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D2840),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        "No events found in your profile. Please add events in Settings.",
                        style: TextStyle(color: Colors.white60),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: eventsList.length,
                      itemBuilder: (context, index) {
                        final ev = eventsList[index];
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedActiveEvent = ev.eventName;
                              _reactionTimeMs = null;
                              _reactionStatus =
                                  "Tap 'Start Reaction Test' to evaluate mental readiness.";
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0D2840),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.cyanAccent.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      ev.eventName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Personal Best: ${ev.personalBest.isEmpty ? 'N/A' : ev.personalBest} • Goal: ${ev.goalTime.isEmpty ? 'N/A' : ev.goalTime}",
                                      style: const TextStyle(
                                        color: Colors.white60,
                                        fontSize: 12.5,
                                      ),
                                    ),
                                  ],
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.cyanAccent,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "Preparing for: $_selectedActiveEvent",
                      style: const TextStyle(
                        color: Colors.cyanAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedActiveEvent = null;
                      });
                    },
                    icon: const Icon(Icons.arrow_back, size: 16),
                    label: const Text("Change Event"),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.amberAccent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D2840),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.cyanAccent.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Mental States & Individual Ratings (Select & Rate)",
                      style: TextStyle(
                        color: Colors.cyanAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8.0,
                      children: mentalStatesList.map((state) {
                        final isSelected = _selectedMentalStates.contains(
                          state,
                        );
                        return FilterChip(
                          label: Text(state),
                          selected: isSelected,
                          selectedColor: Colors.cyanAccent,
                          backgroundColor: const Color(0xFF061A2B),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.black : Colors.white,
                          ),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedMentalStates.add(state);
                                _mentalStateValues.putIfAbsent(
                                  state,
                                  () => 7.0,
                                );
                              } else {
                                if (_selectedMentalStates.length > 1) {
                                  _selectedMentalStates.remove(state);
                                }
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),
                    if (_selectedMentalStates.isNotEmpty) ...[
                      const Text(
                        "Set Intensity (1-10) for each active mental state:",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._selectedMentalStates.map((state) {
                        double val = _mentalStateValues[state] ?? 5.0;
                        return _buildLabeledSlider(
                          label: state,
                          value: val,
                          onChanged: (newVal) {
                            setState(() {
                              _mentalStateValues[state] = newVal;
                            });
                          },
                        );
                      }),
                    ],
                    const Divider(color: Colors.white24, height: 20),
                    const Text(
                      "Overall Energy Level (1 - 10)",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    _buildLabeledSlider(
                      label: "Energized",
                      value: _energyLevel,
                      onChanged: (val) => setState(() => _energyLevel = val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D2840),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.amberAccent.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Capture Neuro Score (Required Reaction Test)",
                      style: TextStyle(
                        color: Colors.amberAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Note: You must complete and capture your Neuro Score reaction time before you can start your race session.",
                      style: TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _reactionStatus,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: (!_isTestRunning && !_canTap)
                            ? _startReactionTest
                            : _handleReactionTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _waitingForGreen
                              ? Colors.redAccent
                              : (_canTap
                                    ? Colors.greenAccent
                                    : Colors.amberAccent),
                          foregroundColor: Colors.black,
                        ),
                        child: Text(
                          _isTestRunning
                              ? (_waitingForGreen
                                    ? "Wait for Green..."
                                    : "TAP NOW!")
                              : "Start Reaction Test",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: widget.profile != null ? _startRaceSession : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyanAccent,
                    foregroundColor: Colors.black,
                  ),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text(
                    "Start Race Session (Queue Event)",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
