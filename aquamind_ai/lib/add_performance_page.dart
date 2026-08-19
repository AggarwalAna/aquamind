// lib/add_performance_page.dart
import 'package:flutter/material.dart';
import 'race_session.dart';
import 'race_session_storage.dart';

class AddPerformancePage extends StatefulWidget {
  const AddPerformancePage({super.key});

  @override
  State<AddPerformancePage> createState() => _AddPerformancePageState();
}

class _AddPerformancePageState extends State<AddPerformancePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  List<TextEditingController> _splitControllers = [];

  String _selectedEvent = "100 Free (SCY)";
  String _selectedPool = "SCY";

  double _confidenceValue = 7.0;
  double _stressValue = 4.0;

  final List<String> _events = [
    // Freestyle
    "50 Free (SCY)", "50 Free (LCM)",
    "100 Free (SCY)", "100 Free (LCM)",
    "200 Free (SCY)", "200 Free (LCM)",
    "500 Free (SCY)", "400 Free (LCM)",
    // Backstroke
    "50 Back (SCY)", "50 Back (LCM)",
    "100 Back (SCY)", "100 Back (LCM)",
    "200 Back (SCY)", "200 Back (LCM)",
    // Breaststroke
    "50 Breast (SCY)", "50 Breast (LCM)",
    "100 Breast (SCY)", "100 Breast (LCM)",
    "200 Breast (SCY)", "200 Breast (LCM)",
    // Butterfly
    "50 Fly (SCY)", "50 Fly (LCM)",
    "100 Fly (SCY)", "100 Fly (LCM)",
    "200 Fly (SCY)", "200 Fly (LCM)",
    // Individual Medley
    "200 IM (SCY)", "200 IM (LCM)",
    "400 IM (SCY)", "400 IM (LCM)",
  ];

  final List<String> _pools = ["SCY", "LCM", "SCM"];

  @override
  void initState() {
    super.initState();
    _updateSplitControllers();
  }

  /// Extracts numeric distance from the event string (e.g., "200 Fly" -> 200)
  int _extractDistance(String eventName) {
    final regExp = RegExp(r'(\d+)');
    final match = regExp.firstMatch(eventName);
    if (match != null) {
      return int.parse(match.group(0)!);
    }
    return 100;
  }

  /// Dynamically computes the required split count and lap distance based on pool course and total race distance.
  /// SCY/SCM = 25 units per lap. LCM = 50 units per lap.
  int _getExpectedSplitCount() {
    int totalDistance = _extractDistance(_selectedEvent);
    int lapLength = (_selectedPool == "LCM") ? 50 : 25;
    return (totalDistance / lapLength).round();
  }

  void _updateSplitControllers() {
    for (var c in _splitControllers) {
      c.dispose();
    }
    int count = _getExpectedSplitCount();
    _splitControllers = List.generate(count, (_) => TextEditingController());
  }

  @override
  void dispose() {
    _timeController.dispose();
    _notesController.dispose();
    for (var c in _splitControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _savePerformance() async {
    if (_formKey.currentState!.validate()) {
      List<String> splitValues =
          _splitControllers.map((c) => c.text.trim()).toList();

      final newSession = RaceSession(
        event: _selectedEvent,
        pool: _selectedPool,
        time: _timeController.text.trim(),
        splits: splitValues,
        confidence: _confidenceValue,
        stress: _stressValue,
        notes: _notesController.text.trim(),
      );

      await RaceSessionStorage.instance.addSession(newSession);

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    int splitCount = _splitControllers.length;
    int lapLength = (_selectedPool == "LCM") ? 50 : 25;
    String unitLabel =
        (_selectedPool == "LCM") ? "m" : (_selectedPool == "SCY" ? "yd" : "m");

    return Scaffold(
      backgroundColor: const Color(0xFF061A2B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF061A2B),
        elevation: 0,
        title: const Text(
          "Add Performance",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedEvent,
                      dropdownColor: const Color(0xFF0B2A44),
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: const InputDecoration(
                        labelText: "Event",
                        labelStyle: TextStyle(color: Colors.cyan),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.cyan),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.cyan, width: 2),
                        ),
                      ),
                      items: _events.map((event) {
                        return DropdownMenuItem(
                          value: event,
                          child: Text(event, overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedEvent = val;
                            if (val.contains("LCM")) {
                              _selectedPool = "LCM";
                            } else if (val.contains("SCY")) {
                              _selectedPool = "SCY";
                            }
                            _updateSplitControllers();
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedPool,
                      dropdownColor: const Color(0xFF0B2A44),
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: "Course",
                        labelStyle: TextStyle(color: Colors.cyan),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.cyan),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.cyan, width: 2),
                        ),
                      ),
                      items: _pools.map((pool) {
                        return DropdownMenuItem(value: pool, child: Text(pool));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedPool = val;
                            _updateSplitControllers();
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _timeController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Final Time (e.g. 54.20 or 1:02.15)",
                  labelStyle: TextStyle(color: Colors.cyan),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.cyan),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.cyan, width: 2),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return "Please enter a valid time";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Text(
                "Splits ($splitCount Laps Required — Each Lap = $lapLength$unitLabel)",
                style: const TextStyle(
                  color: Colors.cyanAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: splitCount,
                itemBuilder: (context, index) {
                  int distanceMarker = (index + 1) * lapLength;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: TextFormField(
                      controller: _splitControllers[index],
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText:
                            "Split ${index + 1} ($distanceMarker$unitLabel mark)",
                        labelStyle: const TextStyle(color: Colors.white70),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white24),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.cyan),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Text(
                "Confidence Level: ${_confidenceValue.toInt()}/10",
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              Slider(
                value: _confidenceValue,
                min: 1,
                max: 10,
                divisions: 9,
                activeColor: Colors.cyanAccent,
                onChanged: (val) => setState(() => _confidenceValue = val),
              ),
              const SizedBox(height: 12),
              Text(
                "Stress Level: ${_stressValue.toInt()}/10",
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              Slider(
                value: _stressValue,
                min: 1,
                max: 10,
                divisions: 9,
                activeColor: Colors.orangeAccent,
                onChanged: (val) => setState(() => _stressValue = val),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Race Notes & Strategy",
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.cyan),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyan,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _savePerformance,
                  child: const Text(
                    "Save Performance",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
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
