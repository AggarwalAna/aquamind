import 'package:flutter/material.dart';

class GettingStartedPage extends StatelessWidget {
  const GettingStartedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF061A2B),

      appBar: AppBar(
        backgroundColor: const Color(0xFF061A2B),
        elevation: 0,

        title: const Text(
          "Getting Started",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Text(
              "🏊 Welcome to AquaMind",
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Train Smarter. Race Stronger.",
              style: TextStyle(
                color: Colors.cyan,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 25),

            section(
              "1. Complete Your Profile",
              "Set up your swimmer profile and add your events. "
                  "Enter your current personal best and goal time for each event. "
                  "SCY and LCM are treated as separate events.",
            ),

            section(
              "2. Start A Race Session",
              "Before a race, create a race session by selecting the event "
                  "and pool you are competing in.",
            ),

            section(
              "3. Complete Your Race Preparation",
              "Before racing, complete your Mental Readiness Check and "
                  "Reaction Test. AquaMind connects these results to your race.",
            ),

            section(
              "4. Add Your Race Results",
              "After your race, enter your official time, splits, and notes. "
                  "You can return later if you need to finish entering information.",
            ),

            section(
              "5. Track Your Progress",
              "Progress Tracker shows your improvement for each event. "
                  "It compares your current performances, personal bests, "
                  "and goals.",
            ),

            section(
              "6. Race Predictions",
              "After enough race data is collected, Race Predictions "
                  "estimates future performance based on your history.",
            ),

            section(
              "7. AI Coach",
              "Your AI Coach analyzes patterns from your races, splits, "
                  "reaction times, and mental readiness. "
                  "It can identify trends such as when higher focus leads "
                  "to better performances or where pacing needs improvement.",
            ),

            const SizedBox(height: 25),

            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(18),

              decoration: BoxDecoration(
                color: const Color(0xFF0B2A44),

                borderRadius: BorderRadius.circular(16),

                border: Border.all(color: Colors.cyan),
              ),

              child: const Text(
                "The more races you record, the smarter AquaMind becomes.",
                textAlign: TextAlign.center,

                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget section(String title, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: const Color(0xFF0B2A44),

        borderRadius: BorderRadius.circular(14),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(
            title,

            style: const TextStyle(
              color: Colors.cyan,

              fontSize: 19,

              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            description,

            style: const TextStyle(color: Colors.white, fontSize: 15),
          ),
        ],
      ),
    );
  }
}
