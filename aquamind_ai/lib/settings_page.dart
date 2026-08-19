// lib/settings_page.dart
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

  final List<String> _availableEvents = [
    '50 Free',
    '100 Free',
    '200 Free',
    '500 Free',
    '100 Back',
    '100 Breast',
    '100 Fly',
    '200 IM'
  ];

  @override
  void initState() {
    super.initState();
    _currentProfile = UserStorage.profile ??
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
        title: const Text("Add New Swimmer Profile",
            style: TextStyle(color: Colors.cyanAccent)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: newNameCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                  labelText: "Swimmer Name",
                  labelStyle: TextStyle(color: Colors.white60)),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: newAgeCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                  labelText: "Age",
                  labelStyle: TextStyle(color: Colors.white60)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child:
                const Text("Cancel", style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyanAccent,
                foregroundColor: Colors.black),
            onPressed: () async {
              if (newNameCtrl.text.trim().isNotEmpty) {
                final newP = UserProfile(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: newNameCtrl.text.trim(),
                  age: int.tryParse(newAgeCtrl.text.trim()) ?? 14,
                  category: newCat,
                  events: [
                    EventRecord(
                        eventName: '100 Free', personalBest: '', goalTime: '')
                  ],
                );
                await UserStorage.saveActiveProfile(newP);
                if (!mounted) return;
                setState(() {
                  _currentProfile = newP;
                  _populateFields();
                });
                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          "Created and switched to profile: ${newP.name}")),
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
        String selectedEvent = _availableEvents.first;
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            backgroundColor: const Color(0xFF0D2840),
            title: const Text("Add Event Record",
                style: TextStyle(color: Colors.cyanAccent)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: selectedEvent,
                  dropdownColor: const Color(0xFF0D2840),
                  style: const TextStyle(color: Colors.white),
                  items: _availableEvents.toSet().map((e) {
                    return DropdownMenuItem<String>(
                      value: e,
                      child: Text(e),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() {
                        selectedEvent = val;
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
                      labelStyle: TextStyle(color: Colors.white60)),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: goalController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                      labelText: "Goal Time (e.g., 56.50)",
                      labelStyle: TextStyle(color: Colors.white60)),
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text("Cancel")),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyanAccent),
                onPressed: () {
                  setState(() {
                    _currentProfile.events.add(EventRecord(
                      eventName: selectedEvent,
                      personalBest: pbController.text.trim(),
                      goalTime: goalController.text.trim(),
                    ));
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
    return Scaffold(
      backgroundColor: const Color(0xFF061A2B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF061A2B),
        title: const Text("Swimmer Profiles & Settings",
            style: TextStyle(color: Colors.white)),
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
                    const Text("Switch Swimmer Profile",
                        style: TextStyle(
                            color: Colors.cyanAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: _currentProfile.id,
                      dropdownColor: const Color(0xFF0D2840),
                      style: const TextStyle(color: Colors.white),
                      items: UserStorage.profiles.map((p) {
                        return DropdownMenuItem<String>(
                          value: p.id,
                          child: Text("${p.name} (Age ${p.age})"),
                        );
                      }).toList()
                        ..add(
                          const DropdownMenuItem<String>(
                            value: 'NEW',
                            child: Text("+ Add New Swimmer Profile...",
                                style: TextStyle(color: Colors.cyanAccent)),
                          ),
                        ),
                      onChanged: _switchSwimmer,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text("Edit Swimmer Details",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Swimmer Name",
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.cyanAccent)),
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
                      borderSide: BorderSide(color: Colors.cyanAccent)),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Managed Events & PBs",
                      style: TextStyle(
                          color: Colors.cyanAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyanAccent,
                        foregroundColor: Colors.black),
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
                          Text(ev.eventName,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          Text(
                              "PB: ${ev.personalBest.isEmpty ? 'N/A' : ev.personalBest} • Goal: ${ev.goalTime.isEmpty ? 'N/A' : ev.goalTime}",
                              style: const TextStyle(
                                  color: Colors.white60, fontSize: 12)),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete,
                            color: Colors.redAccent, size: 20),
                        onPressed: () {
                          setState(() {
                            _currentProfile.events.removeWhere(
                                (e) => e.eventName == ev.eventName);
                          });
                        },
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                      foregroundColor: Colors.black),
                  onPressed: _saveProfile,
                  child: const Text("Save Profile Changes",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
