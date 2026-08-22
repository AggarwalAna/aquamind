import 'package:flutter/material.dart';
import 'choose_pool_page.dart';

class ChooseEventPage extends StatelessWidget {
  final String stroke;

  const ChooseEventPage({super.key, required this.stroke});

  List<String> getEvents() {
    switch (stroke) {
      case "Freestyle":
        return ["50 Free", "100 Free", "200 Free", "500 Free", "1650 Free"];

      case "Backstroke":
        return ["50 Back", "100 Back", "200 Back"];

      case "Breaststroke":
        return ["50 Breast", "100 Breast", "200 Breast"];

      case "Butterfly":
        return ["50 Fly", "100 Fly", "200 Fly"];

      case "Individual Medley":
        return ["100 IM", "200 IM", "400 IM"];

      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final events = getEvents();

    return Scaffold(
      backgroundColor: const Color(0xFF061A2B),

      appBar: AppBar(
        backgroundColor: const Color(0xFF061A2B),

        elevation: 0,

        title: Text(
          "$stroke Events",

          style: const TextStyle(
            color: Colors.white,

            fontWeight: FontWeight.bold,
          ),
        ),

        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          children: [
            const Text(
              "Choose your event",

              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),

            const SizedBox(height: 30),

            Expanded(
              child: ListView.builder(
                itemCount: events.length,

                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 15),

                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,

                          MaterialPageRoute(
                            builder: (context) =>
                                ChoosePoolPage(event: events[index]),
                          ),
                        );
                      },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,

                        foregroundColor: Colors.black,

                        minimumSize: const Size(double.infinity, 65),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),

                      child: Text(
                        events[index],

                        style: const TextStyle(
                          fontSize: 21,

                          fontWeight: FontWeight.bold,
                        ),
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
