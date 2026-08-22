// lib/start_race_page.dart
import 'package:flutter/material.dart';
import 'race_session.dart';
import 'mental_readiness_page.dart';
import 'user_storage.dart';
import 'user_profile.dart';

class StartRacePage extends StatefulWidget {
  const StartRacePage({super.key});

  @override
  State<StartRacePage> createState() => _StartRacePageState();
}

class _StartRacePageState extends State<StartRacePage> {
  String? _selectedEventToStart;

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
        ),
        body: const Center(
          child: Text(
            "No active swimmer profile found.",
            style: TextStyle(color: Colors.white60),
          ),
        ),
      );
    }

    // Retrieve active queue sessions for this profile
    List<dynamic> activeQueue = UserStorage.activeQueues[profile.id] ?? [];

    // Extract event names strictly from the profile setup
    final List<String> profileEvents = profile.events
        .map((e) => e.eventName.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    // Validate and fix dropdown selection if it's out of bounds
    if (_selectedEventToStart == null ||
        !profileEvents.contains(_selectedEventToStart)) {
      _selectedEventToStart = profileEvents.isNotEmpty
          ? profileEvents.first
          : null;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF061A2B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF061A2B),
        title: const Text(
          "AquaMind – AA",
          style: TextStyle(color: Colors.white),
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
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "Select an upcoming event from your profile setup below to initiate your pre-race mental readiness and reaction test.",
              style: TextStyle(color: Colors.white60, fontSize: 13),
            ),
            const SizedBox(height: 16),

            // Dropdown Card for Profile Events Only
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0D2840),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.cyanAccent.withValues(alpha: 0.4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Select Event to Start Preparation",
                    style: TextStyle(
                      color: Colors.cyanAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 12),
                  profileEvents.isEmpty
                      ? const Text(
                          "No events configured in your profile setup. Please add events in settings first.",
                          style: TextStyle(
                            color: Colors.orangeAccent,
                            fontSize: 13,
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF061A2B),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.cyanAccent.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedEventToStart,
                                  isExpanded: true,
                                  dropdownColor: const Color(0xFF0D2840),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                  items: profileEvents.map((String eventName) {
                                    return DropdownMenuItem<String>(
                                      value: eventName,
                                      child: Text(eventName),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    if (newValue != null) {
                                      setState(() {
                                        _selectedEventToStart = newValue;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.cyanAccent,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                if (_selectedEventToStart == null ||
                                    _selectedEventToStart!.isEmpty) {
                                  return;
                                }

                                final freshSession = RaceSession();
                                freshSession.event = _selectedEventToStart!;

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MentalReadinessPage(
                                      session: freshSession,
                                      onSubmit: (updatedSession) async {
                                        activeQueue.add({
                                          'event': updatedSession.event,
                                          'energy': updatedSession.energy,
                                          'timestamp': DateTime.now()
                                              .toString(),
                                        });
                                        await UserStorage.saveRaceData(
                                          profile.id,
                                          activeQueue,
                                          UserStorage.completedHistories[profile
                                                  .id] ??
                                              [],
                                        );
                                        setState(() {});
                                      },
                                    ),
                                  ),
                                );
                              },
                              child: const Text(
                                "Start Race & Set Mental State",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Active Races / Resume Queue List
            const Text(
              "Active Race Sessions (Pending Completion)",
              style: TextStyle(
                color: Colors.cyanAccent,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            activeQueue.isEmpty
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D2840),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: const Text(
                      "No active races in progress. Choose an event above to begin.",
                      style: TextStyle(color: Colors.white54, fontSize: 13),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: activeQueue.length,
                    itemBuilder: (context, index) {
                      final activeRace = activeQueue[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D2840),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.orangeAccent.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    activeRace['event'] ?? 'Unknown Event',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Started: ${activeRace['timestamp']?.substring(0, 16) ?? ''}",
                                    style: const TextStyle(
                                      color: Colors.white60,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orangeAccent,
                                foregroundColor: Colors.black,
                              ),
                              onPressed: () {
                                final sessionToResume = RaceSession();
                                sessionToResume.event =
                                    activeRace['event'] ?? '';
                                sessionToResume.energy =
                                    activeRace['energy'] ?? 5;

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MentalReadinessPage(
                                      session: sessionToResume,
                                      onSubmit: (updatedSession) async {
                                        activeQueue[index] = {
                                          'event': updatedSession.event,
                                          'energy': updatedSession.energy,
                                          'timestamp': DateTime.now()
                                              .toString(),
                                        };
                                        await UserStorage.saveRaceData(
                                          profile.id,
                                          activeQueue,
                                          UserStorage.completedHistories[profile
                                                  .id] ??
                                              [],
                                        );
                                        setState(() {});
                                      },
                                    ),
                                  ),
                                );
                              },
                              child: const Text(
                                "Resume Race",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
