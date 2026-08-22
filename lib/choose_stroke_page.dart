import 'package:flutter/material.dart';
import 'choose_event_page.dart';

class ChooseStrokePage extends StatelessWidget {
  const ChooseStrokePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF061A2B),

      appBar: AppBar(
        backgroundColor: const Color(0xFF061A2B),
        elevation: 0,

        title: const Text(
          "Choose Stroke",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),

        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,

          children: [
            const Text(
              "What stroke do you swim?",
              textAlign: TextAlign.center,

              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),

            const SizedBox(height: 30),

            strokeCard(context, "Freestyle", Icons.pool),

            strokeCard(context, "Butterfly", Icons.accessibility_new),

            strokeCard(context, "Backstroke", Icons.airline_seat_flat),

            strokeCard(context, "Breaststroke", Icons.waves),

            strokeCard(context, "Individual Medley", Icons.sports),
          ],
        ),
      ),
    );
  }

  Widget strokeCard(BuildContext context, String stroke, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),

      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChooseEventPage(stroke: stroke),
            ),
          );
        },

        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,

          foregroundColor: Colors.black,

          minimumSize: const Size(double.infinity, 70),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),

        child: Row(
          children: [
            Icon(icon, size: 35, color: Colors.amber[800]),

            const SizedBox(width: 25),

            Text(
              stroke,

              style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
