// lib/start_race_page.dart
import 'package:flutter/material.dart';
import 'race_session.dart';
import 'mental_readiness_page.dart';

class StartRacePage extends StatefulWidget {
  const StartRacePage({super.key});

  @override
  State<StartRacePage> createState() => _StartRacePageState();
}

class _StartRacePageState extends State<StartRacePage> {
  RaceSession currentSession =
      RaceSession(); // Adjust based on your constructor

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Start Race")),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MentalReadinessPage(
                  session: currentSession,
                  onSubmit: (updatedSession) {
                    setState(() {
                      currentSession = updatedSession;
                    });
                  },
                ),
              ),
            );
          },
          child: const Text("Open Mental Readiness Check-In"),
        ),
      ),
    );
  }
}
