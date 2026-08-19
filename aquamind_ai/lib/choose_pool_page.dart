import 'package:flutter/material.dart';
import 'event_storage.dart';
import 'swim_event.dart';
import 'event_setup_page.dart';

class ChoosePoolPage extends StatelessWidget {
  final String event;

  const ChoosePoolPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF061A2B),

      appBar: AppBar(
        backgroundColor: const Color(0xFF061A2B),

        elevation: 0,

        title: Text(
          event,

          style: const TextStyle(
            color: Colors.white,

            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Text(
              "Choose Pool Type",

              style: TextStyle(
                color: Colors.white,

                fontSize: 28,

                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 40),

            poolButton(context, "SCY"),

            const SizedBox(height: 20),

            poolButton(context, "SCM"),

            const SizedBox(height: 20),

            poolButton(context, "LCM"),
          ],
        ),
      ),
    );
  }

  Widget poolButton(BuildContext context, String pool) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0B2A44),

        minimumSize: const Size(double.infinity, 65),
      ),

      onPressed: () {
        Navigator.push(
          context,

          MaterialPageRoute(
            builder: (context) => EnterTimePage(event: event, pool: pool),
          ),
        );
      },

      child: Text(
        pool,

        style: const TextStyle(
          color: Colors.cyan,

          fontSize: 24,

          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class EnterTimePage extends StatefulWidget {
  final String event;

  final String pool;

  const EnterTimePage({super.key, required this.event, required this.pool});

  @override
  State<EnterTimePage> createState() => _EnterTimePageState();
}

class _EnterTimePageState extends State<EnterTimePage> {
  final currentController = TextEditingController();

  final goalController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF061A2B),

      appBar: AppBar(
        backgroundColor: const Color(0xFF061A2B),

        title: Text(widget.event, style: const TextStyle(color: Colors.white)),
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              "${widget.event} • ${widget.pool}",

              style: const TextStyle(
                color: Colors.cyan,

                fontSize: 22,

                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 35),

            inputBox("Current PB", currentController),

            const SizedBox(height: 25),

            inputBox("Goal Time", goalController),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: () {
                  if (currentController.text.isEmpty ||
                      goalController.text.isEmpty) {
                    return;
                  }

                  EventStorage.events.add(
                    SwimEvent(
                      event: widget.event,

                      pool: widget.pool,

                      currentPB: currentController.text,

                      goal: goalController.text,
                    ),
                  );

                  showDialog(
                    context: context,

                    builder: (context) {
                      return AlertDialog(
                        title: const Text("Event Saved! ✅"),

                        content: Text(
                          "${widget.event} has been saved.\n\nGo back to your events page to see it.",
                        ),

                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);

                              Navigator.pushAndRemoveUntil(
                                context,

                                MaterialPageRoute(
                                  builder: (context) => const EventSetupPage(),
                                ),

                                (route) => false,
                              );
                            },

                            child: const Text("OK"),
                          ),
                        ],
                      );
                    },
                  );
                },

                child: const Text("Save Event"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget inputBox(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 22)),

        const SizedBox(height: 10),

        TextField(
          controller: controller,

          style: const TextStyle(color: Colors.white),

          decoration: InputDecoration(
            filled: true,

            fillColor: const Color(0xFF0B2A44),

            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          ),
        ),
      ],
    );
  }
}
