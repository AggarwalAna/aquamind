import 'package:flutter/material.dart';
import 'race_session.dart';

class RaceReadyPage extends StatelessWidget {
  final RaceSession session;
  final double?
      reactionTime; // Optional field to accept score without mutating RaceSession

  const RaceReadyPage({
    super.key,
    required this.session,
    this.reactionTime,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF061A2B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF061A2B),
        elevation: 0,
        title: const Text(
          "Race Ready",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Session Overview",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            if (reactionTime != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0E2A47),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "Latest Reaction Time: ${reactionTime!.toStringAsFixed(3)}s",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
