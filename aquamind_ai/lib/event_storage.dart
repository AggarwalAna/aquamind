// lib/event_storage.dart
import 'swim_event.dart';

class EventStorage {
  // Initialize with default events so the dropdown is immediately populated
  static final List<SwimEvent> events = [
    SwimEvent(event: "50 Free", pool: "SCY", currentPB: "24.50", goal: "23.80"),
    SwimEvent(
        event: "100 Free", pool: "SCY", currentPB: "54.20", goal: "52.50"),
    SwimEvent(
        event: "100 Back", pool: "SCY", currentPB: "1:02.10", goal: "59.90"),
  ];
}
