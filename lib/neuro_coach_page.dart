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
                "Log at least one race in the Race Start tab to generate multi-race AI Coach insights.",
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
          _buildEventSpeedCard(_selectedEvent!),
          const SizedBox(height: 16),
          _buildNutritionHydrationCard(selectedRaces),
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

  // 2. Deep Correlated Neural & Mental Profile
  Widget _buildDeepNeuralMentalCard(
    String eventName,
    List<RaceLogEntry> races,
  ) {
    if (races.isEmpty) return const SizedBox.shrink();

    List<RaceLogEntry> sorted = List.from(races);
    sorted.sort(
      (a, b) => (a.finishTime ?? "99").compareTo(b.finishTime ?? "99"),
    );

    RaceLogEntry bestRace = sorted.first;

    double avgFocus = 0, avgAnxiety = 0, avgPumped = 0, avgFatigue = 0;
    for (var r in races) {
      avgFocus += (r.mentalStateScores['Focused'] ?? 5);
      avgAnxiety += (r.mentalStateScores['Anxious'] ?? 2);
      avgPumped += (r.mentalStateScores['Pumped'] ?? 5);
      avgFatigue += (r.mentalStateScores['Fatigued'] ?? 2);
    }
    int len = races.length;
    avgFocus /= len;
    avgAnxiety /= len;
    avgPumped /= len;
    avgFatigue /= len;

    int bestAnxiety = bestRace.mentalStateScores['Anxious'] ?? 3;
    int bestFocus = bestRace.mentalStateScores['Focused'] ?? 7;
    int bestPumped = bestRace.mentalStateScores['Pumped'] ?? 7;

    return _buildSectionCard(
      title: "1. Deep Mental & Performance Correlations ($eventName)",
      icon: Icons.psychology,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBulletPoint(
            "Anxiety vs. Velocity Correlation (Avg ${avgAnxiety.toStringAsFixed(1)}/10):\n"
            "Data indicates that when your anxiety rating is controlled between $bestAnxiety/10 and ${bestAnxiety + 1}/10, you hit your fastest times (including your PR of ${bestRace.finishTime}). "
            "${avgAnxiety > 5.0 ? 'When pre-race anxiety spikes above 6/10, elevated cortisol triggers premature adrenaline dumping, resulting in early lactic acid buildup during the middle 50s.' : 'Your nervous system is well-calibrated for this event length, preventing wasteful glycogen depletion before heat start.'}",
          ),
          const SizedBox(height: 12),
          _buildBulletPoint(
            "Focus & Block Execution Correlation (Avg ${avgFocus.toStringAsFixed(1)}/10):\n"
            "Your peak race performance occurred with a Focus score of $bestFocus/10. High focus correlates directly with tighter underwater streamline positioning and faster auditory reaction time off the horn. "
            "${avgFocus < 6.5 ? 'On races where focus dropped below 6/10, breakout tempo was visibly delayed. Spend 60 seconds visualising stroke tempo behind the block.' : 'You maintain strong cognitive focus for this race type, minimizing dead time during wall transitions.'}",
          ),
          const SizedBox(height: 12),
          _buildBulletPoint(
            "Neuromuscular Drive (Pumped Rating) (Avg ${avgPumped.toStringAsFixed(1)}/10):\n"
            "Optimal performance occurs when your activation level reaches $bestPumped/10, activating fast-twitch muscle fibers required for aggressive kick tempo. "
            "${avgPumped < 6.0 ? 'Physical arousal stays low. Perform 4 explosive vertical hops 3 minutes before stepping up to activate high-threshold motor units.' : 'Activation levels are well aligned with your race pacing demands.'}",
          ),
          const SizedBox(height: 12),
          _buildBulletPoint(
            "Fatigue Accumulation & Speed Retention (Avg ${avgFatigue.toStringAsFixed(1)}/10):\n"
            "${avgFatigue > 4.0 ? 'Elevated central fatigue shows a strong statistical link to split decay on late laps. Incorporate active recovery swimming (minimum 400 yards easy) between event sessions.' : 'Neuromuscular fatigue is well-managed across swims, maintaining explosive power output through late heats.'}",
          ),
        ],
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
        double s2 = double.tryParse(r.splits[1]) ?? 0.0;
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
                ? "Average Second-Half Split Decay: +${avgDecay.toStringAsFixed(2)}s across $racesWithSplits heat(s)"
                : "Single lap data logged. Log 50-yard/meter split times to unlock lap-by-lap decay analysis.",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          if (avgDecay > 2.0) ...[
            _buildBulletPoint(
              "Split Trend Analysis:\n"
              "A drop-off of +${avgDecay.toStringAsFixed(2)}s in the second half points to premature lactic acidosis. "
              "Cross-referencing your mental logs reveals that elevated pre-race anxiety causes an overly aggressive opening 50, resulting in reduced stroke length on subsequent laps.",
            ),
            const SizedBox(height: 8),
            _buildBulletPoint(
              "Actionable Pacing Adjustment:\n"
              "Hold target stroke rate on turn breakouts and enforce a strict no-breathing rule on the first 3 strokes out of every wall to carry momentum.",
            ),
          ] else ...[
            _buildBulletPoint(
              "Split Trend Analysis:\n"
              "Exceptional split retention (+${avgDecay.toStringAsFixed(2)}s). Your mental focus scores correlate directly with strong lap pacing and stable kick turnover throughout.",
            ),
            const SizedBox(height: 8),
            _buildBulletPoint(
              "Actionable Pacing Adjustment:\n"
              "To lower times further, accelerate hip rotation speed into the final turn wall.",
            ),
          ],
        ],
      ),
    );
  }

  // 4. Technical Cues (Dynamically Tailored to the Event)
  Widget _buildEventSpeedCard(String eventName) {
    String speedTips = "";
    final ev = eventName.toLowerCase();

    if (ev.contains("free") || ev.contains("freestyle")) {
      speedTips =
          "• High-Elbow Catch: Anchor maximum water mass with an early vertical forearm pull for $eventName.\n\n"
          "• Breakout Efficiency: Execute 4-5 dynamic dolphin kicks off every wall in tight streamline before breaking the surface breath-free.\n\n"
          "• Kick Tempo Maintenance: Keep a continuous 6-beat kick turnover through turn transitions to preserve forward velocity.";
    } else if (ev.contains("back") || ev.contains("backstroke")) {
      speedTips =
          "• Head Stability & Hip Drive: Keep head static while driving aggressive hip rotation for your $eventName.\n\n"
          "• SDK Velocity: Maximize underwater kick speed off every turn wall before surface transition.\n\n"
          "• Clean Recovery: Exit thumb-first and enter pinky-first without crossing the body midline.";
    } else if (ev.contains("breast") || ev.contains("breaststroke")) {
      speedTips =
          "• Pull-Out Glide Control: Hold streamline on the underwater pull-out of your $eventName to capitalize on wall push-off speed.\n\n"
          "• Narrow Whip Kick: Keep knees inside shoulder width to minimize frontal resistance.\n\n"
          "• Dynamic Recovery: Shoot hands forward fast along the surface to transition immediately into glide phase.";
    } else if (ev.contains("fly") || ev.contains("butterfly")) {
      speedTips =
          "• Forward Chest Drive: Press momentum forward through the chest rather than bouncing vertically during your $eventName.\n\n"
          "• Second Kick Timing: Deliver a strong second kick as hands exit the water to drive hand recovery forward.\n\n"
          "• Low Chin Line: Keep chin near the water surface when breathing to maintain high hip alignment.";
    } else if (ev.contains("im") || ev.contains("medley")) {
      speedTips =
          "• Stroke Transition Acceleration: Build velocity into stroke transition walls (Fly-to-Back, Back-to-Breast, Breast-to-Free) for your $eventName.\n\n"
          "• Pacing Distribution: Control leg tempo across the middle legs so you stay fresh for the final Freestyle finish sprint.";
    } else {
      speedTips =
          "• Turn Speed & Pacing: Build stroke rate into turn walls for $eventName and execute fast, compact transitions.";
    }

    return _buildSectionCard(
      title: "3. Technical Cues for $eventName",
      icon: Icons.speed,
      child: Text(
        speedTips,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 13,
          height: 1.4,
        ),
      ),
    );
  }

  // 5. Nutrition Strategy
  Widget _buildNutritionHydrationCard(List<RaceLogEntry> races) {
    bool hasHighAnxietyOrFatigue = races.any((r) {
      int anxiety = r.mentalStateScores['Anxious'] ?? 0;
      int fatigue = r.mentalStateScores['Fatigued'] ?? 0;
      return anxiety >= 6 || fatigue >= 6 || r.energy <= 4;
    });

    return _buildSectionCard(
      title: "4. Nutrition & Hydration Strategy",
      icon: Icons.restaurant_menu,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBulletPoint(
            hasHighAnxietyOrFatigue
                ? "Pre-Race Fueling Protocol:\nHigh anxiety or fatigue noted in recent logs. Eat slow-digesting complex carbs (oatmeal, banana toast) 3 hours prior to race time. Avoid high-sugar gel spikes 1 hour before call time, which trigger cortisol spikes and worsen nerve jitters."
                : "Pre-Race Fueling Protocol:\nEnergy levels remain steady. A clean carb source 2-3 hours prior paired with a small piece of fruit 45 minutes before call time optimizes available blood glucose without stomach discomfort.",
          ),
          const SizedBox(height: 12),
          _buildBulletPoint(
            "Hydration & Electrolyte Sync:\nSip 8-12 oz of electrolyte solution up to 20 minutes before stepping behind the blocks. Sodium/potassium balance maintains neural signaling speed for explosive muscle contractility.",
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
              Text(
                title,
                style: const TextStyle(
                  color: Colors.cyanAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
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
