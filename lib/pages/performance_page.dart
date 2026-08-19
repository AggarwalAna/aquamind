import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'season_page.dart';

class PerformancePage extends StatefulWidget {
  const PerformancePage({super.key});

  @override
  State<PerformancePage> createState() => _PerformancePageState();
}

class _PerformancePageState extends State<PerformancePage> {
  List<Map<String, String>> seasons = [];

  @override
  void initState() {
    super.initState();
    loadSeasons();
  }

  Future<void> loadSeasons() async {
    final prefs = await SharedPreferences.getInstance();

    String? savedData = prefs.getString("seasons");

    if (savedData != null) {
      List decodedData = jsonDecode(savedData);

      setState(() {
        seasons = decodedData.map((item) {
          return Map<String, String>.from(item);
        }).toList();
      });
    }
  }

  Future<void> saveSeasons() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString("seasons", jsonEncode(seasons));
  }

  void addSeason() {
    TextEditingController seasonController = TextEditingController();

    String poolType = "SCY";

    showDialog(
      context: context,

      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Add Season"),

              content: Column(
                mainAxisSize: MainAxisSize.min,

                children: [
                  TextField(
                    controller: seasonController,

                    decoration: const InputDecoration(
                      labelText: "Season Name (Example: 2026-2027)",
                    ),
                  ),

                  const SizedBox(height: 20),

                  DropdownButton<String>(
                    value: poolType,

                    items: const [
                      DropdownMenuItem(
                        value: "SCY",

                        child: Text("Short Course Yards (SCY)"),
                      ),

                      DropdownMenuItem(
                        value: "LCM",

                        child: Text("Long Course Meters (LCM)"),
                      ),
                    ],

                    onChanged: (value) {
                      setDialogState(() {
                        poolType = value!;
                      });
                    },
                  ),
                ],
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    if (seasonController.text.isNotEmpty) {
                      setState(() {
                        seasons.add({
                          "name": seasonController.text,

                          "pool": poolType,
                        });
                      });

                      saveSeasons();
                    }

                    Navigator.pop(context);
                  },

                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Performance Tracker"),

        backgroundColor: const Color(0xFF12344D),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: addSeason,

        child: const Icon(Icons.add),
      ),

      body: seasons.isEmpty
          ? const Center(
              child: Text(
                "No seasons added yet 🏊",

                style: TextStyle(fontSize: 20),
              ),
            )
          : ListView.builder(
              itemCount: seasons.length,

              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.all(12),

                  child: ListTile(
                    title: Text(seasons[index]["name"]!),

                    subtitle: Text(seasons[index]["pool"]!),

                    onTap: () {
                      Navigator.push(
                        context,

                        MaterialPageRoute(
                          builder: (context) => SeasonPage(
                            seasonName: seasons[index]["name"]!,

                            poolType: seasons[index]["pool"]!,
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
