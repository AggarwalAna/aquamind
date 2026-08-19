// lib/progress_tracker_page.dart
import 'package:flutter/material.dart';
import 'race_session.dart';
import 'race_session_storage.dart';

class ProgressTrackerPage extends StatefulWidget {
  const ProgressTrackerPage({super.key});

  @override
  State<ProgressTrackerPage> createState() => _ProgressTrackerPageState();
}

class _ProgressTrackerPageState extends State<ProgressTrackerPage> {
  bool isLoading = true;
  List<RaceSession> sessions = [];

  double _parseTimeToSeconds(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return 0.0;

    String cleanStr = timeStr.trim();
    if (cleanStr.contains(' ')) {
      cleanStr = cleanStr.split(' ')[0];
    }

    if (cleanStr.contains(':')) {
      List<String> parts = cleanStr.split(':');
      double mins = double.tryParse(parts[0]) ?? 0;
      double secs = double.tryParse(parts[1]) ?? 0;
      return (mins * 60) + secs;
    }

    double val = double.tryParse(cleanStr) ?? 0.0;
    return val;
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await RaceSessionStorage.loadSessions();
    setState(() {
      sessions = RaceSessionStorage.instance.completedSessions;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    const double goalSeconds = 52.0;

    double bestSeconds = 0;
    if (sessions.isNotEmpty) {
      List<double> validTimes = sessions
          .map((s) => _parseTimeToSeconds(s.time))
          .where((t) => t > 5.0)
          .toList();

      if (validTimes.isNotEmpty) {
        bestSeconds =
            validTimes.reduce((curr, next) => curr < next ? curr : next);
      } else {
        bestSeconds = _parseTimeToSeconds(sessions.last.time);
      }
    }

    double delta = bestSeconds > 0 ? bestSeconds - goalSeconds : 0;
    String deltaMessage = delta > 0
        ? "Need ${delta.toStringAsFixed(2)}s drop to reach goal"
        : "Goal achieved! 🎉";

    return Scaffold(
      backgroundColor: const Color(0xFF061A2B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF061A2B),
        elevation: 0,
        title: const Text(
          "Progress Tracker & Goal Delta",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.cyan))
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Track your historical data, event trends, and goal progression cleanly organized by event.",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A253D),
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: Colors.cyan.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "100 Free",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.cyan.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "Recent/PB: ${bestSeconds > 0 ? bestSeconds.toStringAsFixed(2) : 'N/A'}",
                                style: const TextStyle(
                                  color: Colors.cyan,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Goal: ${goalSeconds.toStringAsFixed(2)} • $deltaMessage",
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  const Text(
                    "Race Log History",
                    style: TextStyle(
                      color: Colors.pinkAccent,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: sessions.isEmpty
                        ? const Center(
                            child: Text(
                              "No race logs recorded yet.",
                              style: TextStyle(color: Colors.white54),
                            ),
                          )
                        : ListView.builder(
                            itemCount: sessions.length,
                            itemBuilder: (context, index) {
                              final session = sessions[index];
                              // Fallback or use session.notes instead of non-existent moods
                              final displayInfo = (session.notes != null &&
                                      session.notes!.isNotEmpty)
                                  ? session.notes!
                                  : 'Focused';
                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0A253D),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.white12),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "8/5/2026",
                                          style: TextStyle(
                                              color: Colors.white54,
                                              fontSize: 12),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "$displayInfo (${session.energy ?? 3}/10 energy)",
                                          style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 13),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      session.time ?? "N/A",
                                      style: const TextStyle(
                                        color: Colors.cyan,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
