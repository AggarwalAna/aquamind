import 'package:flutter/material.dart';
import 'user_profile.dart';
import 'user_storage.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late UserProfile _currentProfile;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String _selectedCategory = 'Club Swimmer';

  // Comprehensive master list of all competitive events
  final List<String> _availableEvents = [
    '50 Free',
    '100 Free',
    '200 Free',
    '400 Free',
    '500 Free',
    '800 Free',
    '1000 Free',
    '1650 Free',
    '50 Back',
    '100 Back',
    '200 Back',
    '50 Breast',
    '100 Breast',
    '200 Breast',
    '50 Fly',
    '100 Fly',
    '200 Fly',
    '100 IM',
    '200 IM',
    '400 IM',
  ];

  @override
  void initState() {
    super.initState();
    _currentProfile =
        UserStorage.profile ??
        UserProfile(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: '',
          age: 14,
          category: 'Club Swimmer',
          events: [],
        );
    _populateFields();
  }

  void _populateFields() {
    _nameController.text = _currentProfile.name;
    _ageController.text = _currentProfile.age.toString();
    _selectedCategory = _currentProfile.category;
  }

  void _switchSwimmer(String? profileId) async {
    if (profileId == 'NEW') {
      _createNewSwimmerDialog();
      return;
    }
    if (profileId != null) {
      await UserStorage.switchProfile(profileId);
      if (!mounted) return;
      setState(() {
        _currentProfile = UserStorage.profile!;
        _populateFields();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Switched profile to ${_currentProfile.name}")),
      );
    }
  }

  void _createNewSwimmerDialog() {
    final TextEditingController newNameCtrl = TextEditingController();
    final TextEditingController newAgeCtrl = TextEditingController();
    String newCat = 'Club Swimmer';

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF0D2840),
        title: const Text(
          "Add New Swimmer Profile",
          style: TextStyle(color: Colors.cyanAccent),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: newNameCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Swimmer Name",
                labelStyle: TextStyle(color: Colors.white60),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: newAgeCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Age",
                labelStyle: TextStyle(color: Colors.white60),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.white60),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyanAccent,
              foregroundColor: Colors.black,
            ),
            onPressed: () async {
              if (newNameCtrl.text.trim().isNotEmpty) {
                final newP = UserProfile(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: newNameCtrl.text.trim(),
                  age: int.tryParse(newAgeCtrl.text.trim()) ?? 14,
                  category: newCat,
                  events: [
                    EventRecord(
                      eventName: '100 Free (SCY)',
                      personalBest: '',
                      goalTime: '',
                    ),
                  ],
                );
                await UserStorage.saveActiveProfile(newP);
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
                if (!mounted) return;
                setState(() {
                  _currentProfile = newP;
                  _populateFields();
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Created and switched to profile: ${newP.name}",
                    ),
                  ),
                );
              }
            },
            child: const Text("Create"),
          ),
        ],
      ),
    );
  }

  void _addEventDialog() {
    final TextEditingController pbController = TextEditingController();
    final TextEditingController goalController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        String selectedEventBase = _availableEvents.first;
        String selectedCourseType = 'SCY';

        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            backgroundColor: const Color(0xFF0D2840),
            title: const Text(
              "Add Event Record",
              style: TextStyle(color: Colors.cyanAccent),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: selectedEventBase,
                  dropdownColor: const Color(0xFF0D2840),
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "Event",
                    labelStyle: TextStyle(color: Colors.white60),
                  ),
                  items: _availableEvents.toSet().map((e) {
                    return DropdownMenuItem<String>(value: e, child: Text(e));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() {
                        selectedEventBase = val;
                      });
                    }
                  },
                ),
                const SizedBox(height: 10),
                // Course Type selector embedded directly into Add Event dialog
                DropdownButtonFormField<String>(
                  initialValue: selectedCourseType,
                  dropdownColor: const Color(0xFF0D2840),
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "Course Type",
                    labelStyle: TextStyle(color: Colors.cyanAccent),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: "SCY",
                      child: Text("SCY (Short Course Yards)"),
                    ),
                    DropdownMenuItem(
                      value: "LCM",
                      child: Text("LCM (Long Course Meters)"),
                    ),
                    DropdownMenuItem(
                      value: "SCM",
                      child: Text("SCM (Short Course Meters)"),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() {
                        selectedCourseType = val;
                      });
                    }
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: pbController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "Personal Best (e.g., 58.40)",
                    labelStyle: TextStyle(color: Colors.white60),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: goalController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "Goal Time (e.g., 56.50)",
                    labelStyle: TextStyle(color: Colors.white60),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyanAccent,
                ),
                onPressed: () {
                  final String finalEventName =
                      "$selectedEventBase ($selectedCourseType)";
                  setState(() {
                    _currentProfile.events.add(
                      EventRecord(
                        eventName: finalEventName,
                        personalBest: pbController.text.trim(),
                        goalTime: goalController.text.trim(),
                      ),
                    );
                  });
                  Navigator.pop(dialogContext);
                },
                child: const Text("Add"),
              ),
            ],
          ),
        );
      },
    );
  }

  void _editRaceHistoryDialog(int index, Map<String, dynamic> race) {
    final TextEditingController finishCtrl = TextEditingController(
      text: race['finishTime'] ?? '',
    );
    final TextEditingController dateCtrl = TextEditingController(
      text: race['date'] ?? '',
    );
    final List<dynamic> rawSplits = race['splits'] ?? [];
    final TextEditingController splitsCtrl = TextEditingController(
      text: rawSplits.join(', '),
    );

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF0D2840),
        title: Text(
          "Edit Race Entry: ${race['event']}",
          style: const TextStyle(color: Colors.cyanAccent),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: finishCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Finish Time (e.g. 1:02.45)",
                labelStyle: TextStyle(color: Colors.white60),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: splitsCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Splits (every 50, comma separated)",
                labelStyle: TextStyle(color: Colors.white60),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: dateCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Date",
                labelStyle: TextStyle(color: Colors.white60),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.white60),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyanAccent,
              foregroundColor: Colors.black,
            ),
            onPressed: () async {
              List<String> updatedSplits = splitsCtrl.text
                  .split(',')
                  .map((s) => s.trim())
                  .where((s) => s.isNotEmpty)
                  .toList();

              List<dynamic> currentHistory =
                  UserStorage.completedHistories[_currentProfile.id] ?? [];
              if (index < currentHistory.length) {
                currentHistory[index]['finishTime'] = finishCtrl.text.trim();
                currentHistory[index]['splits'] = updatedSplits;
                currentHistory[index]['date'] = dateCtrl.text.trim();

                await UserStorage.saveRaceData(
                  _currentProfile.id,
                  UserStorage.activeQueues[_currentProfile.id] ?? [],
                  currentHistory,
                );
              }

              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
              }
              if (!mounted) return;
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Race entry updated!")),
              );
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _deleteRaceHistoryItem(int index) async {
    List<dynamic> currentHistory =
        UserStorage.completedHistories[_currentProfile.id] ?? [];
    if (index < currentHistory.length) {
      currentHistory.removeAt(index);
      await UserStorage.saveRaceData(
        _currentProfile.id,
        UserStorage.activeQueues[_currentProfile.id] ?? [],
        currentHistory,
      );
      if (!mounted) return;
      setState(() {});
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Race entry deleted.")));
    }
  }

  void _saveProfile() async {
    _currentProfile.name = _nameController.text.trim();
    _currentProfile.age = int.tryParse(_ageController.text.trim()) ?? 14;
    _currentProfile.category = _selectedCategory;

    await UserStorage.saveActiveProfile(_currentProfile);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile settings saved successfully!")),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> historyList =
        UserStorage.completedHistories[_currentProfile.id] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFF061A2B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF061A2B),
        title: const Text(
          "Swimmer Profiles & Settings",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.cyanAccent),
      ),
      body: Scrollbar(
        thumbVisibility: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D2840),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.cyanAccent),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Switch Swimmer Profile",
                      style: TextStyle(
                        color: Colors.cyanAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: _currentProfile.id,
                      dropdownColor: const Color(0xFF0D2840),
                      style: const TextStyle(color: Colors.white),
                      items:
                          UserStorage.profiles.map((p) {
                            return DropdownMenuItem<String>(
                              value: p.id,
                              child: Text("${p.name} (Age ${p.age})"),
                            );
                          }).toList()..add(
                            const DropdownMenuItem<String>(
                              value: 'NEW',
                              child: Text(
                                "+ Add New Swimmer Profile...",
                                style: TextStyle(color: Colors.cyanAccent),
                              ),
                            ),
                          ),
                      onChanged: _switchSwimmer,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Edit Swimmer Details",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Swimmer Name",
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.cyanAccent),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Age",
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.cyanAccent),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Managed Events & PBs",
                    style: TextStyle(
                      color: Colors.cyanAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyanAccent,
                      foregroundColor: Colors.black,
                    ),
                    onPressed: _addEventDialog,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text("Add Event"),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ..._currentProfile.events.map((ev) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D2840),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ev.eventName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "PB: ${ev.personalBest.isEmpty ? 'N/A' : ev.personalBest} • Goal: ${ev.goalTime.isEmpty ? 'N/A' : ev.goalTime}",
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.redAccent,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _currentProfile.events.removeWhere(
                              (e) => e.eventName == ev.eventName,
                            );
                          });
                        },
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 24),
              const Text(
                "Logged Race History",
                style: TextStyle(
                  color: Colors.cyanAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Edit or remove logged race results:",
                style: TextStyle(color: Colors.white60, fontSize: 12),
              ),
              const SizedBox(height: 10),
              historyList.isEmpty
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D2840),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "No logged races for this profile yet.",
                        style: TextStyle(color: Colors.white54, fontSize: 13),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: historyList.length,
                      itemBuilder: (context, index) {
                        final race = Map<String, dynamic>.from(
                          historyList[index],
                        );
                        final List<dynamic> splits = race['splits'] ?? [];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D2840),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.cyanAccent.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${race['event']} - ${race['finishTime'] ?? 'N/A'}",
                                      style: const TextStyle(
                                        color: Colors.greenAccent,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "Date: ${race['date'] ?? 'N/A'}${splits.isNotEmpty ? ' | Splits: ${splits.join(' / ')}' : ''}",
                                      style: const TextStyle(
                                        color: Colors.white60,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.cyanAccent,
                                  size: 20,
                                ),
                                onPressed: () =>
                                    _editRaceHistoryDialog(index, race),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.redAccent,
                                  size: 20,
                                ),
                                onPressed: () => _deleteRaceHistoryItem(index),
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
                    backgroundColor: Colors.greenAccent,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: _saveProfile,
                  child: const Text(
                    "Save Profile Changes",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
