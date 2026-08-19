import 'package:flutter/material.dart';

class EventPage extends StatefulWidget {
  final String eventName;
  final String goalTime;

  const EventPage({super.key, required this.eventName, required this.goalTime});

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  List<Map<String, String>> races = [];

  void addRace() {
    TextEditingController meetController = TextEditingController();

    TextEditingController dateController = TextEditingController();

    TextEditingController timeController = TextEditingController();

    showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: const Text("Add Race"),

          content: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              TextField(
                controller: meetController,

                decoration: const InputDecoration(labelText: "Meet Name"),
              ),

              TextField(
                controller: dateController,

                decoration: const InputDecoration(labelText: "Date"),
              ),

              TextField(
                controller: timeController,

                decoration: const InputDecoration(
                  labelText: "Time (Example: 1:12.84)",
                ),
              ),
            ],
          ),

          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  races.add({
                    "meet": meetController.text,

                    "date": dateController.text,

                    "time": timeController.text,
                  });
                });

                Navigator.pop(context);
              },

              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  String? getBestTime() {
    if (races.isEmpty) {
      return null;
    }

    List<double> convertedTimes = races.map((race) {
      return convertTime(race["time"]!);
    }).toList();

    double best = convertedTimes.reduce((a, b) => a < b ? a : b);

    int minutes = best ~/ 60;

    double seconds = best % 60;

    return "$minutes:${seconds.toStringAsFixed(2)}";
  }

  double convertTime(String time) {
    List<String> parts = time.split(":");

    int minutes = int.parse(parts[0]);

    double seconds = double.parse(parts[1]);

    return minutes * 60 + seconds;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.eventName),

        backgroundColor: const Color(0xFF12344D),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: addRace,

        child: const Icon(Icons.add),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              "Goal: ${widget.goalTime}",

              style: const TextStyle(fontSize: 20),
            ),

            const SizedBox(height: 15),

            Text(
              getBestTime() == null
                  ? "Current Best: --"
                  : "Current Best: ${getBestTime()}",

              style: const TextStyle(fontSize: 20),
            ),

            const SizedBox(height: 20),

            const Text(
              "Race History",

              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            Expanded(
              child: races.isEmpty
                  ? const Center(child: Text("No races added yet 🏊"))
                  : ListView.builder(
                      itemCount: races.length,

                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            title: Text(races[index]["meet"]!),

                            subtitle: Text(
                              "${races[index]["date"]} - ${races[index]["time"]}",
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
