// lib/mental_readiness_page.dart
import 'package:flutter/material.dart';
import 'race_session.dart';

class MentalReadinessPage extends StatefulWidget {
  final RaceSession session;
  final Function(RaceSession updatedSession) onSubmit;

  const MentalReadinessPage({
    super.key,
    required this.session,
    required this.onSubmit,
  });

  @override
  State<MentalReadinessPage> createState() => _MentalReadinessPageState();
}

class _MentalReadinessPageState extends State<MentalReadinessPage> {
  late double energy;
  late double focus;
  late double confidence;
  late double stress;
  late double fatigue;

  @override
  void initState() {
    super.initState();
    _resetToZero();
  }

  void _resetToZero() {
    // Force clean 0 baseline every time page opens
    energy = 0.0;
    focus = 0.0;
    confidence = 0.0;
    stress = 0.0;
    fatigue = 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF061A2B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF061A2B),
        title: const Text(
          "Pre-Race Mental & Physical Check-In",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Swimmers must complete all metrics below to unlock accurate AI Coach insights.",
              style: TextStyle(color: Colors.cyan, fontSize: 16),
            ),
            const SizedBox(height: 20),
            _buildSliderCard(
              title: "Energy Level",
              value: energy,
              minLabel: "Not energetic at all (0)",
              maxLabel: "Extremely energetic (10)",
              onChanged: (val) => setState(() => energy = val),
            ),
            _buildSliderCard(
              title: "Mental Focus",
              value: focus,
              minLabel: "Not focused at all (0)",
              maxLabel: "Extremely focused (10)",
              onChanged: (val) => setState(() => focus = val),
            ),
            _buildSliderCard(
              title: "Self Confidence",
              value: confidence,
              minLabel: "Not confident at all (0)",
              maxLabel: "Extremely confident (10)",
              onChanged: (val) => setState(() => confidence = val),
            ),
            _buildSliderCard(
              title: "Stress & Nerves",
              value: stress,
              minLabel: "Not nervous at all (0)",
              maxLabel: "Extremely nervous (10)",
              onChanged: (val) => setState(() => stress = val),
            ),
            _buildSliderCard(
              title: "Physical Fatigue",
              value: fatigue,
              minLabel: "Not fatigued at all (0)",
              maxLabel: "Extremely fatigued (10)",
              onChanged: (val) => setState(() => fatigue = val),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  widget.session.energy = energy.toInt();
                  widget.session.focus = focus.toInt();
                  widget.session.confidence = confidence;
                  widget.session.stress = stress;

                  widget.onSubmit(widget.session);

                  // Reset local values after submitting
                  _resetToZero();

                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyan,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Save & Return to Coach",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderCard({
    required String title,
    required double value,
    required String minLabel,
    required String maxLabel,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0A253D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.cyan.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.cyan.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  value.toStringAsFixed(0),
                  style: const TextStyle(
                    color: Colors.cyanAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Slider(
            value: value,
            min: 0,
            max: 10,
            divisions: 10,
            activeColor: Colors.cyan,
            inactiveColor: Colors.white24,
            onChanged: onChanged,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  minLabel,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  maxLabel,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
