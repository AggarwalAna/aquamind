// lib/home_dashboard_page.dart
import 'package:flutter/material.dart';
import 'race_session.dart';
import 'race_session_storage.dart';
import 'add_performance_page.dart';

class HomeDashboardPage extends StatefulWidget {
  const HomeDashboardPage({super.key});

  @override
  State<HomeDashboardPage> createState() => _HomeDashboardPageState();
}

class _HomeDashboardPageState extends State<HomeDashboardPage> {
  RaceSession? _incompleteSession;
  RaceSession? _latestSession;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    // Ensure storage is initialized from disk
    await RaceSessionStorage.instance.init();
    setState(() {
      _incompleteSession = RaceSessionStorage.instance.getIncompleteSession();
      _latestSession = RaceSessionStorage.instance.getLatest();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF061A2B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF061A2B),
        elevation: 0,
        title: const Text(
          "AquaMind Dashboard",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ActiveSessionCard(session: _incompleteSession),
            const SizedBox(height: 20),
            const Text(
              "Latest Performance",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            if (_latestSession != null)
              Card(
                color: const Color(0xFF0B2A44),
                child: ListTile(
                  title: Text(
                    "${_latestSession!.event} (${_latestSession!.pool})",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    "Time: ${_latestSession!.time ?? 'N/A'} | Confidence: ${_latestSession!.confidence}/5",
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              )
            else
              const Text(
                "No logged performances yet.",
                style: TextStyle(color: Colors.white54),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.cyan,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddPerformancePage(),
            ),
          );
          _loadData(); // Re-read storage and refresh dashboard state
        },
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text(
          "Add Performance",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class ActiveSessionCard extends StatelessWidget {
  final RaceSession? session;

  const ActiveSessionCard({super.key, this.session});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF0B2A44),
        borderRadius: BorderRadius.circular(12),
        // FIX: Replaced withOpacity with withValues to avoid precision loss warning
        border: Border.all(color: Colors.cyan.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Active Race Session",
            style: TextStyle(color: Colors.cyan, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            session != null
                ? "${session!.event} (${session!.pool}) - Entry Pending"
                : "No active session in progress",
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
