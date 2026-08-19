import 'package:flutter/material.dart';
import 'pages/performance_page.dart';

void main() {
  runApp(const AquaMindAI());
}

class AquaMindAI extends StatelessWidget {
  const AquaMindAI({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AquaMind',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF061A2B),
        primaryColor: Colors.cyan,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Widget featureCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Card(
        color: const Color(0xFF12344D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            if (title == "Performance Tracker") {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PerformancePage(),
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(icon, color: Colors.cyanAccent, size: 40),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              const Text(
                "AquaMind 🌊",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Train smarter. Race stronger.",
                style: TextStyle(fontSize: 17, color: Colors.white70),
              ),
              const SizedBox(height: 30),

              featureCard(
                context,
                "Performance Tracker",
                "Track races, times, and personal records",
                Icons.pool,
              ),

              featureCard(
                context,
                "AI Swim Coach",
                "Get personalized training advice",
                Icons.smart_toy,
              ),

              featureCard(
                context,
                "Reaction Time",
                "Improve starts and speed",
                Icons.flash_on,
              ),

              featureCard(
                context,
                "Mental Readiness",
                "Prepare your mind before races",
                Icons.psychology,
              ),

              featureCard(
                context,
                "Meet Tracker",
                "Save meets and race results",
                Icons.calendar_month,
              ),

              featureCard(
                context,
                "Analytics",
                "See your improvement over time",
                Icons.bar_chart,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
