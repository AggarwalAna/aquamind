// lib/reaction_test_page.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'reaction_storage.dart';
import 'race_session.dart';
import 'race_ready_page.dart';

class ReactionTestPage extends StatefulWidget {
  final RaceSession session;

  const ReactionTestPage({super.key, required this.session});

  @override
  State<ReactionTestPage> createState() => _ReactionTestPageState();
}

class _ReactionTestPageState extends State<ReactionTestPage> {
  Timer? timer;
  final Stopwatch stopwatch = Stopwatch();

  bool waiting = false;
  bool canTap = false;
  String message = "Press Start";
  double? reactionTime;

  void startTest() {
    timer?.cancel();

    setState(() {
      waiting = true;
      canTap = false;
      reactionTime = null;
      message = "Wait...";
    });

    final delay = Random().nextInt(3000) + 2000;

    timer = Timer(Duration(milliseconds: delay), () {
      if (!mounted) return;
      setState(() {
        waiting = false;
        canTap = true;
        message = "TAP NOW!";
      });

      stopwatch.reset();
      stopwatch.start();
    });
  }

  void tapScreen() {
    if (canTap) {
      stopwatch.stop();

      final time = stopwatch.elapsedMilliseconds / 1000;

      ReactionStorage.addReaction(time);

      setState(() {
        reactionTime = time;
        canTap = false;
        message = "Complete!";
      });
    } else if (waiting) {
      timer?.cancel();

      setState(() {
        waiting = false;
        message = "Too early!\nTry again.";
      });
    }
  }

  void continueToDirections() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => RaceReadyPage(
          session: widget.session,
          reactionTime: reactionTime,
        ),
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF061A2B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF061A2B),
        elevation: 0,
        title: const Text(
          "Reaction Test",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Test your reaction speed",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 25),
            GestureDetector(
              onTap: tapScreen,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: canTap ? Colors.green : Colors.amber,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (reactionTime != null)
              Text(
                "Reaction Time: ${reactionTime!.toStringAsFixed(3)} sec",
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            const SizedBox(height: 20),
            if (reactionTime == null)
              ElevatedButton(
                onPressed: startTest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyan,
                  foregroundColor: Colors.black,
                ),
                child: const Text(
                  "START TEST",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            if (reactionTime != null)
              ElevatedButton(
                onPressed: continueToDirections,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                ),
                child: const Text(
                  "DONE — GO SWIM",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
