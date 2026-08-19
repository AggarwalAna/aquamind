import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'event_page.dart';

class SeasonPage extends StatefulWidget {
  final String seasonName;
  final String poolType;

  const SeasonPage({
    super.key,

    required this.seasonName,

    required this.poolType,
  });

  @override
  State<SeasonPage> createState() => _SeasonPageState();
}

class _SeasonPageState extends State<SeasonPage> {
  List<Map<String, String>> events = [];

  @override
  void initState() {
    super.initState();

    loadEvents();
  }

  String get storageKey {
    return "events_${widget.seasonName}";
  }

  Future<void> loadEvents() async {
    final prefs = await SharedPreferences.getInstance();

    String? savedData = prefs.getString(storageKey);

    if (savedData != null) {
      List decoded = jsonDecode(savedData);

      setState(() {
        events = decoded.map((item) {
          return Map<String, String>.from(item);
        }).toList();
      });
    }
  }

  Future<void> saveEvents() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(storageKey, jsonEncode(events));
  }

  void addEvent() {
    TextEditingController eventController = TextEditingController();

    TextEditingController goalController = TextEditingController();

    showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: const Text("Add Event"),

          content: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              TextField(
                controller: eventController,

                decoration: const InputDecoration(
                  labelText: "Event (Example: 100 Fly)",
                ),
              ),

              TextField(
                controller: goalController,

                decoration: const InputDecoration(
                  labelText: "Goal Time (Example: 1:10.00)",
                ),
              ),
            ],
          ),

          actions: [
            TextButton(
              onPressed: () {
                if (eventController.text.isNotEmpty) {
                  setState(() {
                    events.add({
                      "event": eventController.text,

                      "goal": goalController.text,
                    });
                  });

                  saveEvents();
                }

                Navigator.pop(context);
              },

              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.seasonName),

        backgroundColor: const Color(0xFF12344D),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: addEvent,

        child: const Icon(Icons.add),
      ),

      body: events.isEmpty
          ? const Center(child: Text("No events added yet 🏊"))
          : ListView.builder(
              itemCount: events.length,

              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.all(12),

                  child: ListTile(
                    title: Text(events[index]["event"]!),

                    subtitle: Text("Goal: ${events[index]["goal"]}"),

                    onTap: () {
                      Navigator.push(
                        context,

                        MaterialPageRoute(
                          builder: (context) => EventPage(
                            eventName: events[index]["event"]!,

                            goalTime: events[index]["goal"]!,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
