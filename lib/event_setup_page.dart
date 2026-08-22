import 'package:flutter/material.dart';
import 'choose_stroke_page.dart';
import 'event_storage.dart';
import 'home_dashboard_page.dart';

class EventSetupPage extends StatefulWidget {
  const EventSetupPage({super.key});

  @override
  State<EventSetupPage> createState() => _EventSetupPageState();
}

class _EventSetupPageState extends State<EventSetupPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF061A2B),

      appBar: AppBar(
        backgroundColor: const Color(0xFF061A2B),

        elevation: 0,

        centerTitle: true,

        title: const Text(
          "Add Your Events",

          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,

          children: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,

                  MaterialPageRoute(
                    builder: (context) => const ChooseStrokePage(),
                  ),
                ).then((value) {
                  setState(() {});
                });
              },

              icon: const Icon(Icons.add, size: 28),

              label: const Text(
                "Add Event",

                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,

                foregroundColor: Colors.black,

                minimumSize: const Size(double.infinity, 60),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),

            const SizedBox(height: 35),

            const Text(
              "Your Events",

              style: TextStyle(
                color: Colors.white,

                fontSize: 24,

                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: EventStorage.events.isEmpty
                  ? Container(
                      decoration: BoxDecoration(
                        color: Colors.white10,

                        borderRadius: BorderRadius.circular(14),
                      ),

                      child: const Center(
                        child: Text(
                          "No events added yet.\nTap 'Add Event' to begin.",

                          textAlign: TextAlign.center,

                          style: TextStyle(color: Colors.white70, fontSize: 18),
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: EventStorage.events.length,

                      itemBuilder: (context, index) {
                        final event = EventStorage.events[index];

                        return Card(
                          color: const Color(0xFF0B2A44),

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),

                          child: ListTile(
                            title: Text(
                              event.event,

                              style: const TextStyle(
                                color: Colors.white,

                                fontSize: 20,

                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            subtitle: Text(
                              "${event.pool}\nCurrent PB: ${event.currentPB}\nGoal: ${event.goal}",

                              style: const TextStyle(color: Colors.white70),
                            ),

                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete,

                                color: Colors.redAccent,
                              ),

                              onPressed: () {
                                setState(() {
                                  EventStorage.events.removeAt(index);
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,

                  MaterialPageRoute(
                    builder: (context) => const HomeDashboardPage(),
                  ),
                );
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,

                foregroundColor: Colors.black,

                minimumSize: const Size(double.infinity, 55),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),

              child: const Text(
                "Finish Setup",

                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
