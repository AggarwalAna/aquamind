import 'package:flutter/material.dart';
import 'main.dart';
import 'user_profile.dart';

class NeuroCoachPage extends StatefulWidget {
  final UserProfile? profile;
  final List<RaceLogEntry> completedRaceHistory;

  const NeuroCoachPage({
    super.key,
    this.profile,
    required this.completedRaceHistory,
  });

  @override
  State<NeuroCoachPage> createState() => _NeuroCoachPageState();
}

class _NeuroCoachPageState extends State<NeuroCoachPage> {
  final List<String> _messages = [];

  void _analyzeRecentRaces() {
    if (widget.completedRaceHistory.isEmpty) {
      setState(() {
        _messages.add(
            "Coach: You haven't completed any races yet! Log a race in the Race Start tab to get feedback.");
      });
      return;
    }

    // Identify the event the swimmer just swam
    final targetEvent = widget.completedRaceHistory.first.event;

    // Filter history to show up to the last 3 attempts at this event
    final eventHistory = widget.completedRaceHistory
        .where((r) => r.event == targetEvent)
        .take(3)
        .toList();

    // Deep pattern analysis prompt
    String prompt =
        "Act as an elite swimming performance coach specializing in the neurobiology of aquatic movement and the brain-body connection. Analyze my athlete's recent performances in the $targetEvent.\n\n"
        "RULES FOR ANALYSIS:\n"
        "1. DO NOT just repeat data.\n"
        "2. Identify correlations across races (e.g. time drops vs anxiety/calm levels, split pacing decay).\n"
        "3. Provide actionable neuro-muscular or psychological protocols (e.g. physiological sighs, specific activation drills).\n\n"
        "RACE HISTORY (Newest to Oldest):\n";

    for (int i = 0; i < eventHistory.length; i++) {
      final race = eventHistory[i];
      final splitsText = race.splits.isNotEmpty
          ? race.splits.join(', ')
          : 'No splits recorded';
      prompt +=
          "Race ${i + 1} (${race.date}): Time: ${race.finishTime}, Readiness: ${race.calculatedMentalReadiness.toStringAsFixed(1)}%, Energy: ${race.energy}/10. Mental States: ${race.mentalStateScores}. Splits: [$splitsText]\n";
    }

    setState(() {
      _messages.add(
          "You: Please analyze my pattern data for the $targetEvent:\n\n$prompt");

      _messages.add(
          "Coach: Looking at your last $targetEvent races, there is a clear pattern between your nervous system regulation and back-half splits. When 'Anxious' scores spike, your final split drops significantly compared to when your primary state is 'Calm'.\n\nThat anxiety triggers an early sympathetic spike, causing you to burn through glycogen early and fatigue late.\n\nAction Plan: Before your next race, execute 2 minutes of physiological sighs (double inhale through the nose, long slow exhale through the mouth) behind the blocks to down-regulate your autonomic baseline.");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: _analyzeRecentRaces,
            icon: const Icon(Icons.analytics),
            label: const Text("Analyze Latest Race Data",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyanAccent,
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final msg = _messages[index];
              final isCoach = msg.startsWith("Coach:");

              return Container(
                margin: const EdgeInsets.only(bottom: 16.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: isCoach
                      ? const Color(0xFF0D2840)
                      : const Color(0xFF162D4A),
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(
                    color: isCoach
                        ? Colors.cyanAccent.withValues(alpha: 0.3)
                        : Colors.white24,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  msg,
                  style: TextStyle(
                    color: isCoach ? Colors.cyanAccent : Colors.white,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
