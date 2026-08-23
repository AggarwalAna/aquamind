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
  String? selectedEvent;

  double _parseTimeToSeconds(String? timeStr) {
    if (timeStr == null || timeStr.trim().isEmpty) return 0.0;
    String cleanStr = timeStr.trim();
    if (cleanStr.contains(' ')) cleanStr = cleanStr.split(' ')[0];
    if (cleanStr.contains(':')) {
      List<String> parts = cleanStr.split(':');
      double mins = double.tryParse(parts[0]) ?? 0;
      double secs = double.tryParse(parts[1]) ?? 0;
      return (mins * 60) + secs;
    }
    return double.tryParse(cleanStr) ?? 0.0;
  }

  String _formatSecondsToTime(double totalSeconds) {
    if (totalSeconds <= 0) return "--:--";
    if (totalSeconds >= 60) {
      int minutes = (totalSeconds / 60).floor();
      double seconds = totalSeconds % 60;
      return "$minutes:${seconds.toStringAsFixed(2).padLeft(5, '0')}";
    }
    return totalSeconds.toStringAsFixed(2);
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadData(); // Automatically refreshes data every time you return to this page/tab
  }

  Future<void> _loadData() async {
    await RaceSessionStorage.loadSessions();
    setState(() {
      // Filter out queued races without times so they don't break the tracker
      sessions = RaceSessionStorage.instance.completedSessions
          .where((s) => s.time != null && s.time!.trim().isNotEmpty)
          .toList();
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Dynamically pull all unique events the user has completed
    final uniqueEvents = sessions
        .map((s) => s.event ?? "Unknown")
        .toSet()
        .toList();

    // Default to the first available event if none is selected
    if (selectedEvent == null && uniqueEvents.isNotEmpty) {
      selectedEvent = uniqueEvents.first;
    }

    // Filter sessions to only show history for the selected event
    final eventSessions = sessions
        .where((s) => s.event == selectedEvent)
        .toList();

    double bestSeconds = 0;
    if (eventSessions.isNotEmpty) {
      List<double> validTimes = eventSessions
          .map((s) => _parseTimeToSeconds(s.time))
          .where((t) => t > 0.0)
          .toList();

      if (validTimes.isNotEmpty) {
        bestSeconds = validTimes.reduce(
          (curr, next) => curr < next ? curr : next,
        );
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFF061A2B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF061A2B),
        elevation: 0,
        title: const Text(
          "Progress Tracker",
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
                  if (uniqueEvents.isEmpty)
                    const Expanded(
                      child: Center(
                        child: Text(
                          "No completed races logged yet.",
                          style: TextStyle(color: Colors.white54),
                        ),
                      ),
                    )
                  else ...[
                    // Dynamic Event Dropdown Menu
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A253D),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.cyan.withValues(alpha: 0.3),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedEvent,
                          isExpanded: true,
                          dropdownColor: const Color(0xFF0A253D),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          items: uniqueEvents.map((eventName) {
                            return DropdownMenuItem(
                              value: eventName,
                              child: Text(eventName),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                selectedEvent = val;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Best Time Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A253D),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.cyan.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  selectedEvent ?? "Unknown",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.cyan.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "Best: ${bestSeconds > 0 ? _formatSecondsToTime(bestSeconds) : 'N/A'}",
                                  style: const TextStyle(
                                    color: Colors.cyan,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Goal: Not yet linked to profile",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
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
                      child: eventSessions.isEmpty
                          ? const Center(
                              child: Text(
                                "No completed races logged for this event yet.",
                                style: TextStyle(color: Colors.white54),
                              ),
                            )
                          : ListView.builder(
                              itemCount: eventSessions.length,
                              itemBuilder: (context, index) {
                                // Reverses the list so the newest entries are at the top
                                final session =
                                    eventSessions[eventSessions.length -
                                        1 -
                                        index];
                                final displayInfo =
                                    (session.notes != null &&
                                        session.notes!.isNotEmpty)
                                    ? session.notes!
                                    : 'Race Completed';
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
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              "Recent Log",
                                              style: TextStyle(
                                                color: Colors.white54,
                                                fontSize: 12,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              "$displayInfo (${session.energy ?? '-'}/10 energy)",
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 13,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 10),
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
                ],
              ),
            ),
    );
  }
}
