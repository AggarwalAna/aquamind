// lib/start_race_page.dart
import 'package:flutter/material.dart';
import 'race_session.dart';
import 'mental_readiness_page.dart';
import 'user_storage.dart';
import 'user_profile.dart';
import 'race_session_storage.dart';

class StartRacePage extends StatefulWidget {
  const StartRacePage({super.key});

  @override
  State<StartRacePage> createState() => _StartRacePageState();
}

class _StartRacePageState extends State<StartRacePage> {
  dynamic _selectedProfileEvent;

  @override
  Widget build(BuildContext context) {
    UserProfile? profile = UserStorage.profile;
    if (profile == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF061A2B),
        appBar: AppBar(
          backgroundColor: const Color(0xFF061A2B),
          title: const Text(
            "Start Race",
            style: TextStyle(color: Colors.white),
          ),
          iconTheme: const IconThemeData(color: Colors.cyanAccent),
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Text(
              "No active swimmer profile found. Please configure your profile and events in settings first.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white60, fontSize: 15),
            ),
          ),
        ),
      );
    }

    final profileEvents = profile.events;

    if (_selectedProfileEvent == null ||
        !profileEvents.contains(_selectedProfileEvent)) {
      _selectedProfileEvent = profileEvents.isNotEmpty
          ? profileEvents.first
          : null;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF061A2B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF061A2B),
        elevation: 0,
        title: const Text(
          "AquaMind – AA",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.cyanAccent),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Race Start & Mental Readiness Hub",
              style: TextStyle(
                color: Colors.cyanAccent,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Select your target event from your profile setup below to initiate your pre-race mental readiness check-in.",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0D2840),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.cyanAccent.withValues(alpha: 0.4),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        color: Colors.cyanAccent,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Select Event to Start Preparation",
                        style: TextStyle(
                          color: Colors.cyanAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  profileEvents.isEmpty
                      ? Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF061A2B),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.orangeAccent.withValues(alpha: 0.5),
                            ),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.orangeAccent,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  "No events configured in your profile setup. Please add events in your profile settings first.",
                                  style: TextStyle(
                                    color: Colors.orangeAccent,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF061A2B),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.cyanAccent.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<dynamic>(
                                  value: _selectedProfileEvent,
                                  isExpanded: true,
                                  dropdownColor: const Color(0xFF0D2840),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  items: profileEvents.map((eventObj) {
                                    return DropdownMenuItem<dynamic>(
                                      value: eventObj,
                                      child: Text(
                                        eventObj.eventName,
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (dynamic newValue) {
                                    if (newValue != null) {
                                      setState(() {
                                        _selectedProfileEvent = newValue;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.cyanAccent,
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () async {
                                  if (_selectedProfileEvent == null) {
                                    return;
                                  }

                                  final rawEventName =
                                      _selectedProfileEvent.eventName;
                                  final poolTypeString =
                                      _selectedProfileEvent.poolType ?? 'SCY';

                                  final formattedEventName =
                                      rawEventName.contains('(')
                                      ? rawEventName
                                      : "$rawEventName ($poolTypeString)";

                                  // Initialize session with NO time so it correctly enters the queue
                                  final session = RaceSession()
                                    ..event = formattedEventName
                                    ..pool = poolTypeString;

                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MentalReadinessPage(
                                        session: session,
                                        onSubmit: (updatedSession) {
                                          updatedSession.event =
                                              formattedEventName;
                                          updatedSession.pool = poolTypeString;
                                          // Time variable explicitly left untouched here to maintain queue status
                                        },
                                      ),
                                    ),
                                  );

                                  // Saves the incomplete session to trigger your "Resume Race" button
                                  await RaceSessionStorage.instance.addSession(
                                    session,
                                  );
                                  await RaceSessionStorage.loadSessions();

                                  if (!context.mounted) return;

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Race queued! Use 'Resume Race' when you are ready.",
                                      ),
                                      backgroundColor: Colors.teal,
                                    ),
                                  );

                                  Navigator.pop(context, true);
                                },
                                child: const Text(
                                  "Queue Race & Mental Check-In",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
