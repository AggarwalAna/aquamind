import 'package:flutter/material.dart';

class EventSavedPage extends StatelessWidget {
  final String event;
  final String pool;
  final String currentTime;
  final String goalTime;

  const EventSavedPage({
    super.key,
    required this.event,
    required this.pool,
    required this.currentTime,
    required this.goalTime,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF061A2B),

      appBar: AppBar(
        backgroundColor: const Color(0xFF061A2B),

        title: const Text("Event Saved", style: TextStyle(color: Colors.white)),
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Text(
              "Your Event",

              style: TextStyle(
                color: Colors.white,

                fontSize: 28,

                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            Text(
              "$event • $pool",

              style: const TextStyle(color: Colors.cyan, fontSize: 24),
            ),

            const SizedBox(height: 30),

            Text(
              "Current Time: $currentTime",

              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),

            const SizedBox(height: 15),

            Text(
              "Goal Time: $goalTime",

              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
