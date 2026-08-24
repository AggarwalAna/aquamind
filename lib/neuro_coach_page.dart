// lib/neuro_coach_page.dart
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
  String? _selectedEvent;

  @override
  Widget build(BuildContext context) {
    if (widget.completedRaceHistory.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.analytics_outlined,
                size: 64,
                color: Colors.cyanAccent,
              ),
              const SizedBox(height: 16),
              const Text(
                "No Race Data Logged",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Log at least one race in the Race Start tab to generate multi-race AI-free Coach insights.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white60, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    final uniqueEvents = widget.completedRaceHistory
        .map((r) => r.event)
        .toSet()
        .toList();

    if (_selectedEvent == null || !uniqueEvents.contains(_selectedEvent)) {
      _selectedEvent = uniqueEvents.first;
    }

    final selectedRaces = widget.completedRaceHistory
        .where((r) => r.event == _selectedEvent)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event Selection Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF0D2840),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.cyanAccent.withValues(alpha: 0.5),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedEvent,
                isExpanded: true,
                dropdownColor: const Color(0xFF0D2840),
                icon: const Icon(
                  Icons.arrow_drop_down,
                  color: Colors.cyanAccent,
                ),
                style: const TextStyle(
                  color: Colors.cyanAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                items: uniqueEvents.map((eventName) {
                  final eventCount = widget.completedRaceHistory
                      .where((r) => r.event == eventName)
                      .length;
                  return DropdownMenuItem<String>(
                    value: eventName,
                    child: Text(
                      "$eventName ($eventCount Logged)",
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedEvent = newValue;
                    });
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 16),

          _buildOverviewHeaderCard(_selectedEvent!, selectedRaces),
          const SizedBox(height: 16),
          _buildDeepNeuralMentalCard(_selectedEvent!, selectedRaces),
          const SizedBox(height: 16),
          _buildMultiRaceSplitCard(_selectedEvent!, selectedRaces),
          const SizedBox(height: 16),
          _buildDynamicWallAnalysisCard(_selectedEvent!, selectedRaces),
          const SizedBox(height: 16),
          _buildNutritionHydrationCard(_selectedEvent!, selectedRaces),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // 1. Overview Header
  Widget _buildOverviewHeaderCard(String eventName, List<RaceLogEntry> races) {
    String fastestTime = races.first.finishTime ?? "--:--.--";

    for (var r in races) {
      final time = r.finishTime;
      if (time != null && time.isNotEmpty) {
        if (fastestTime == "--:--.--" || time.compareTo(fastestTime) < 0) {
          fastestTime = time;
        }
      }
    }

    String recentTime = races.first.finishTime ?? "--:--.--";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D2840),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "$eventName — Multi-Race Trends",
                  style: const TextStyle(
                    color: Colors.cyanAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.cyanAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "${races.length} Race${races.length > 1 ? 's' : ''} Tracked",
                  style: const TextStyle(
                    color: Colors.cyanAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  "Fastest Time",
                  fastestTime,
                  Icons.emoji_events,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricTile(
                  "Recent Time",
                  recentTime,
                  Icons.history,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 2. Deep Correlated Neural & Mental Profile (Hides unselected / 0 metrics)
  Widget _buildDeepNeuralMentalCard(
    String eventName,
    List<RaceLogEntry> races,
  ) {
    if (races.isEmpty) {
      return const SizedBox.shrink();
    }

    List<RaceLogEntry> sorted = List.from(races);
    sorted.sort(
      (a, b) => (a.finishTime ?? "99").compareTo(b.finishTime ?? "99"),
    );

    RaceLogEntry latestRace = races.first;

    double avgFocus = 0;
    double avgFatigue = 0;
    for (var r in races) {
      avgFocus += (r.mentalStateScores['Focused'] ?? 0);
      avgFatigue += (r.mentalStateScores['Fatigued'] ?? 0);
    }
    int len = races.length;
    avgFocus /= len;
    avgFatigue /= len;

    int latestAnxiety = latestRace.mentalStateScores['Anxious'] ?? 0;
    int latestFocus = latestRace.mentalStateScores['Focused'] ?? 0;

    List<Widget> correlationWidgets = [];

    // Only display if anxiety score was actively logged (> 0)
    if (latestAnxiety > 0) {
      correlationWidgets.add(
        _buildBulletPoint(
          "Anxiety Baseline & Last Entry (Latest: $latestAnxiety/10):\n"
          "${latestAnxiety > 6 ? 'Your last race showed elevated stress ($latestAnxiety/10), which often triggers premature adrenaline burnout. Recommended protocol: 3 minutes of box breathing prior to call time.' : 'Your pre-race composure was well-balanced ($latestAnxiety/10), keeping your neuromuscular pathways clear for explosive race output.'}",
        ),
      );
      correlationWidgets.add(const SizedBox(height: 12));
    }

    // Only display if focus score was actively logged (> 0)
    if (latestFocus > 0) {
      correlationWidgets.add(
        _buildBulletPoint(
          "Focus & Start Execution (Latest Focus: $latestFocus/10 | Average: ${avgFocus.toStringAsFixed(1)}/10):\n"
          "${latestFocus < 6.5 ? 'Lower focus ratings correlate with slower reaction times off the block. Spend 60 seconds visualizing your initial breakout before stepping up.' : 'You maintained strong cognitive focus, minimizing dead time during initial water entry.'}",
        ),
      );
      correlationWidgets.add(const SizedBox(height: 12));
    }

    // Only display if average fatigue is meaningful (> 0)
    if (avgFatigue > 0) {
      correlationWidgets.add(
        _buildBulletPoint(
          "Fatigue Retention & System Load (Average Fatigue: ${avgFatigue.toStringAsFixed(1)}/10):\n"
          "${avgFatigue > 4.0 ? 'Elevated cumulative fatigue is impacting back-half speed for $eventName. Ensure adequate active recovery.' : 'Neuromuscular fatigue is well-managed across heats for this event, preserving high-threshold power.'}",
        ),
      );
    }

    // Fallback if no mental metrics were logged at all
    if (correlationWidgets.isEmpty) {
      correlationWidgets.add(
        _buildBulletPoint(
          "No specific mental state scores logged for this event. Complete a pre-race check-in to unlock personalized neural insights.",
        ),
      );
    }

    return _buildSectionCard(
      title: "1. Deep Mental & Performance Correlations ($eventName)",
      icon: Icons.psychology,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: correlationWidgets,
      ),
    );
  }

  // 3. Multi-Race Split & Pacing Analysis
  Widget _buildMultiRaceSplitCard(String eventName, List<RaceLogEntry> races) {
    double totalDecay = 0.0;
    int racesWithSplits = 0;

    for (var r in races) {
      if (r.splits.length >= 2) {
        double s1 = double.tryParse(r.splits[0]) ?? 0.0;
        double s2 = double.tryParse(r.splits.last) ?? 0.0;
        if (s1 > 0 && s2 > 0) {
          totalDecay += (s2 - s1);
          racesWithSplits++;
        }
      }
    }

    double avgDecay = racesWithSplits > 0
        ? (totalDecay / racesWithSplits)
        : 0.0;

    return _buildSectionCard(
      title: "2. Comprehensive Pacing & Split Analysis",
      icon: Icons.timer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            racesWithSplits > 0
                ? "Average Split Drift: +${avgDecay.toStringAsFixed(2)}s across $racesWithSplits heat(s)"
                : "Single lap data logged. Input multi-lap split times to unlock lap-by-lap decay analysis.",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          if (avgDecay > 2.0) ...[
            _buildBulletPoint(
              "Pacing Diagnosis:\n"
              "A drop-off of +${avgDecay.toStringAsFixed(2)}s indicates an overly aggressive opening split that depleted your energy stores early.",
            ),
          ] else ...[
            _buildBulletPoint(
              "Pacing Diagnosis:\n"
              "Exceptional split retention (+${avgDecay.toStringAsFixed(2)}s drift). Your energy distribution across the race distance is well-calibrated.",
            ),
          ],
        ],
      ),
    );
  }

  // 4. Data-Driven Turn & Wall Efficiency Analyzer
  Widget _buildDynamicWallAnalysisCard(
    String eventName,
    List<RaceLogEntry> races,
  ) {
    return _buildSectionCard(
      title: "3. Wall Turn Efficiency & Rule-Safe Analysis",
      icon: Icons.waves,
      child: Text(
        _generateWallAndTurnAnalysis(eventName, races),
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 13.5,
          height: 1.5,
        ),
      ),
    );
  }

  String _generateWallAndTurnAnalysis(
    String eventName,
    List<RaceLogEntry> races,
  ) {
    if (races.isEmpty) {
      return "Log race entries with split times to evaluate turn performance.";
    }

    final latestRace = races.first;
    List<double> splits = latestRace.splits
        .map((s) => double.tryParse(s) ?? 0.0)
        .where((s) => s > 0)
        .toList();

    if (splits.length < 2) {
      return "• **Wall Transition Data Needed:** Multi-lap split times are required to compute turn deceleration variance. Input individual lap splits on your next entry.";
    }

    double maxSplit = splits.reduce((a, b) => a > b ? a : b);
    double minSplit = splits.reduce((a, b) => a < b ? a : b);
    double splitVariance = maxSplit - minSplit;

    String ev = eventName.toLowerCase();
    String ruleNote = "";
    if (ev.contains("breast")) {
      ruleNote =
          "\n\n⚠️ **Rule Compliance Alert ($eventName):** Exactly ONE legal dolphin kick is permitted during the pull-out. Do not exceed this limit to avoid disqualification.";
    } else if (ev.contains("back")) {
      ruleNote =
          "\n\n⚠️ **Rule Compliance Alert ($eventName):** Keep a continuous rolling motion into flip turns without gliding past the 15-meter mark.";
    } else if (ev.contains("fly") || ev.contains("butterfly")) {
      ruleNote =
          "\n\n⚠️ **Rule Compliance Alert ($eventName):** Both hands must touch the wall simultaneously and separated at the turn.";
    } else {
      ruleNote =
          "\n\n✅ **Rule Compliance ($eventName):** Ensure tight streamline and clean wall contact on every flip.";
    }

    if (splitVariance > 3.0) {
      return "⚠️ **Turn Deceleration Detected:** Your split variance is high (${splitVariance.toStringAsFixed(2)}s spread). This points to heavy deceleration into walls and slow breakout rebound velocity.$ruleNote";
    } else {
      return "✅ **Consistent Wall Retention:** Low split variance (${splitVariance.toStringAsFixed(2)}s spread) demonstrates clean, repeatable wall transitions.$ruleNote";
    }
  }

  // 5. Nutrition Strategy Card
  Widget _buildNutritionHydrationCard(
    String eventName,
    List<RaceLogEntry> eventRaces,
  ) {
    bool hasHighAnxietyOrFatigue = false;

    if (eventRaces.isNotEmpty) {
      final latest = eventRaces.first;
      int anxiety = latest.mentalStateScores['Anxious'] ?? 0;
      int fatigue = latest.mentalStateScores['Fatigued'] ?? 0;
      int energy = latest.energy;

      // Only flag if anxiety or fatigue were explicitly logged above zero
      bool hasStressData = anxiety > 0 || fatigue > 0;
      hasHighAnxietyOrFatigue =
          hasStressData && (anxiety >= 6 || fatigue >= 6 || energy <= 4);
    }

    String fuelingAdvice = hasHighAnxietyOrFatigue
        ? "Pre-Race Fueling Protocol ($eventName):\nElevated stress or fatigue was detected in your latest log for this specific event. Consume slow-digesting complex carbohydrates 3 hours prior. Avoid heavy sugar spikes right before race time to prevent cortisol crashes."
        : "Pre-Race Fueling Protocol ($eventName):\nEnergy and composure levels remain steady for this event. A balanced carb source 2-3 hours prior optimizes available blood glucose without causing stomach discomfort.";

    return _buildSectionCard(
      title: "4. Nutrition & Hydration Strategy ($eventName)",
      icon: Icons.restaurant_menu,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBulletPoint(fuelingAdvice),
          const SizedBox(height: 12),
          _buildBulletPoint(
            "Hydration Protocol ($eventName):\nSip 8-12 oz of electrolyte solution up to 20 minutes before stepping behind the blocks to maintain optimal nerve conduction velocity.",
          ),
        ],
      ),
    );
  }

  // Helper UI Methods
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D2840),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.cyanAccent, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.cyanAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildMetricTile(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF162D4A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.cyanAccent, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.white60, fontSize: 11),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "• ",
          style: TextStyle(
            color: Colors.cyanAccent,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
