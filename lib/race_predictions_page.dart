// lib/race_predictions_page.dart
import 'package:flutter/material.dart';
import 'add_performance_page.dart';
import 'race_session_storage.dart';
import 'race_session.dart';

class RacePredictionsPage extends StatefulWidget {
  const RacePredictionsPage({super.key});

  @override
  State<RacePredictionsPage> createState() => _RacePredictionsPageState();
}

class _RacePredictionsPageState extends State<RacePredictionsPage> {
  double _energy = 8.0;
  double _focus = 8.0;
  double _stress = 4.0;

  @override
  Widget build(BuildContext context) {
    final allSessions = RaceSessionStorage.instance.completedSessions;
    final latestSession = RaceSessionStorage.instance.getLatest();

    return Scaffold(
      backgroundColor: const Color(0xFF061A2B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF061A2B),
        elevation: 0,
        title: const Text(
          "Race Predictions",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: (latestSession == null || allSessions.isEmpty)
            ? _buildLocked(context)
            : _buildPrediction(allSessions, latestSession),
      ),
    );
  }

  Widget _buildLocked(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "🏁 Race Predictions",
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Complete a race first\nto unlock predictions.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 17),
          ),
          const SizedBox(height: 25),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddPerformancePage(),
                ),
              );
            },
            child: const Text("Add Performance"),
          ),
        ],
      ),
    );
  }

  Widget _buildPrediction(
      List<RaceSession> allSessions, RaceSession latestSession) {
    RaceSession bestSession = latestSession;
    double bestSeconds = double.infinity;

    for (var session in allSessions) {
      double secs = _convertTimeToSeconds(session.time);
      if (secs >= 10.0 && secs < bestSeconds) {
        bestSeconds = secs;
        bestSession = session;
      }
    }

    if (bestSeconds == double.infinity) {
      bestSeconds = _convertTimeToSeconds(latestSession.time);
      bestSession = latestSession;
    }

    final predictionData = _calculatePrediction(bestSeconds);
    String splitsDisplay = bestSession.splits.isNotEmpty
        ? bestSession.splits.join(" / ")
        : "None recorded";

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "🤖 AI Race Prediction",
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Adjust readiness to project target race pace and lap splits based on your True Personal Best.",
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),
          _card("True Baseline (Personal Best)", """
Event: ${bestSession.event} (${bestSession.pool})
Fastest PB Time: ${bestSession.time ?? "N/A"}
Splits: $splitsDisplay
Total Races Logged: ${allSessions.length}
"""),
          const SizedBox(height: 20),
          const Text(
            "Pre-Race Readiness",
            style: TextStyle(
              color: Colors.cyan,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _sliderCard(
            "Energy Level",
            _energy,
            Colors.cyanAccent,
            (v) => setState(() => _energy = v),
          ),
          const SizedBox(height: 10),
          _sliderCard(
            "Focus Level",
            _focus,
            Colors.greenAccent,
            (v) => setState(() => _focus = v),
          ),
          const SizedBox(height: 10),
          _sliderCard(
            "Stress Level",
            _stress,
            Colors.orangeAccent,
            (v) => setState(() => _stress = v),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF0B2A44),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.cyan, width: 1.5),
            ),
            child: Column(
              children: [
                const Text(
                  "PROJECTED RACE TIME",
                  style: TextStyle(
                    color: Colors.cyan,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  predictionData["formattedTime"] ?? "--:--",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  predictionData["feedback"] ?? "",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _calculatePrediction(double baseSeconds) {
    if (baseSeconds <= 0) {
      return {
        "formattedTime": "--:--",
        "feedback": "Valid race time required for prediction.",
      };
    }

    double energyBonus = (10 - _energy) * 0.003;
    double focusBonus = (10 - _focus) * 0.002;
    double stressPenalty = (_stress > 5) ? (_stress - 5) * 0.004 : 0.0;

    double multiplier = 1.0 + energyBonus + focusBonus + stressPenalty - 0.008;
    double targetSecs = baseSeconds * multiplier;

    double delta = targetSecs - baseSeconds;
    String feedback = delta < 0
        ? "On track to drop ${delta.abs().toStringAsFixed(2)}s under peak conditions!"
        : "Projected +${delta.toStringAsFixed(2)}s off PB due to current stress/energy levels.";

    return {
      "formattedTime": _formatSecondsToTime(targetSecs),
      "feedback": feedback,
    };
  }

  double _convertTimeToSeconds(String? timeStr) {
    if (timeStr == null || timeStr.trim().isEmpty) return 0.0;
    try {
      final clean = timeStr.trim();
      if (clean.contains(":")) {
        final parts = clean.split(":");
        final mins = double.parse(parts[0]);
        final secs = double.parse(parts[1]);
        return (mins * 60.0) + secs;
      }
      return double.parse(clean);
    } catch (e) {
      return 0.0;
    }
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

  Widget _sliderCard(
    String title,
    double val,
    Color color,
    ValueChanged<double> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0D2840),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
          Expanded(
            child: Slider(
              value: val,
              min: 1.0,
              max: 10.0,
              divisions: 9,
              activeColor: color,
              inactiveColor: Colors.white12,
              onChanged: onChanged,
            ),
          ),
          Text(
            "${val.toInt()}/10",
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(String title, String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0B2A44),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.cyan),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.cyan,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
