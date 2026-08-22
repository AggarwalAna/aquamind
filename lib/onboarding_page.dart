// lib/onboarding_page.dart
import 'package:flutter/material.dart';
import 'user_profile.dart';
import 'user_storage.dart';

class OnboardingPage extends StatefulWidget {
  final VoidCallback onProfileCreated;

  const OnboardingPage({super.key, required this.onProfileCreated});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final TextEditingController _nameController =
      TextEditingController(text: "First_Name Last_Name");
  final TextEditingController _ageController =
      TextEditingController(text: "10");
  String _selectedCategory = "Club Swimmer";

  final List<EventInputRow> _eventRows = [
    EventInputRow(
      eventController: TextEditingController(text: "100 Free"),
      pool: "SCY",
      pbController: TextEditingController(text: ""),
      goalController: TextEditingController(text: ""),
    ),
  ];

  final List<String> _categories = [
    "Club Swimmer",
    "High School Varsity",
    "Masters Swimmer",
    "Triathlete / Multi-Sport"
  ];

  final List<String> _pools = ["SCY", "LCM", "SCM"];

  void _addEventRow() {
    setState(() {
      _eventRows.add(EventInputRow(
        eventController: TextEditingController(),
        pool: "SCY",
        pbController: TextEditingController(),
        goalController: TextEditingController(),
      ));
    });
  }

  void _removeEventRow(int index) {
    if (_eventRows.length > 1) {
      setState(() {
        _eventRows.removeAt(index);
      });
    }
  }

  void _completeOnboarding() async {
    final name = _nameController.text.trim();
    final age = int.tryParse(_ageController.text.trim()) ?? 14;
    if (name.isEmpty) return;

    List<EventRecord> records = [];
    for (var row in _eventRows) {
      final ev = row.eventController.text.trim();
      final pool = row.pool;
      final pb = row.pbController.text.trim();
      final goal = row.goalController.text.trim();
      if (ev.isNotEmpty) {
        records.add(EventRecord(
          eventName: "$ev ($pool)",
          personalBest: pb,
          goalTime: goal,
        ));
      }
    }

    final profile = UserProfile(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      age: age,
      category: _selectedCategory,
      events: records.isNotEmpty
          ? records
          : [
              EventRecord(
                  eventName: "100 Free (SCY)", personalBest: "", goalTime: "")
            ],
    );

    await UserStorage.saveActiveProfile(profile);
    widget.onProfileCreated();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF061A2B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF061A2B),
        title: const Text("Welcome to AquaMind",
            style: TextStyle(color: Colors.cyanAccent)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Set Up Your Swimmer Profile",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Configure your name, age, category, course pools, and initial events to start tracking your mental readiness and race splits.",
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Swimmer Name",
                labelStyle: TextStyle(color: Colors.cyanAccent),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.cyanAccent)),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.cyanAccent)),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: "Age",
                      labelStyle: TextStyle(color: Colors.cyanAccent),
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.cyanAccent)),
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.cyanAccent)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    dropdownColor: const Color(0xFF0D2840),
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                        labelText: "Swimmer Category",
                        labelStyle: TextStyle(color: Colors.cyanAccent)),
                    items: _categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) =>
                        setState(() => _selectedCategory = val!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Initial Events, Course & PBs",
                    style: TextStyle(
                        color: Colors.cyanAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyanAccent,
                      foregroundColor: Colors.black),
                  onPressed: _addEventRow,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text("Add Event"),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _eventRows.length,
              itemBuilder: (context, index) {
                final row = _eventRows[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D2840),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: Colors.cyanAccent.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: TextField(
                              controller: row.eventController,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                  labelText: "Event Name (e.g., 200 Fly)",
                                  labelStyle: TextStyle(color: Colors.white60)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: DropdownButtonFormField<String>(
                              initialValue: row.pool,
                              dropdownColor: const Color(0xFF061A2B),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 13),
                              decoration: const InputDecoration(
                                  labelText: "Course",
                                  labelStyle:
                                      TextStyle(color: Colors.cyanAccent)),
                              items: _pools
                                  .map((p) => DropdownMenuItem(
                                      value: p, child: Text(p)))
                                  .toList(),
                              onChanged: (val) {
                                setState(() {
                                  row.pool = val!;
                                });
                              },
                            ),
                          ),
                          if (_eventRows.length > 1)
                            IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.redAccent),
                              onPressed: () => _removeEventRow(index),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: row.pbController,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                  labelText: "Current PB (e.g., 2:10.50)",
                                  labelStyle: TextStyle(color: Colors.white60)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: row.goalController,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                  labelText: "Goal Time (e.g., 2:05.00)",
                                  labelStyle: TextStyle(color: Colors.white60)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyanAccent,
                    foregroundColor: Colors.black),
                onPressed: _completeOnboarding,
                child: const Text("Save & Enter Dashboard",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EventInputRow {
  final TextEditingController eventController;
  String pool;
  final TextEditingController pbController;
  final TextEditingController goalController;

  EventInputRow({
    required this.eventController,
    required this.pool,
    required this.pbController,
    required this.goalController,
  });
}
