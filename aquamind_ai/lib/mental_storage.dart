class MentalEntry {
  final DateTime date;

  final String event;

  final String pool;

  final int energy;

  final int focus;

  final int confidence;

  final int stress;

  final int score;

  MentalEntry({
    required this.date,
    required this.event,
    required this.pool,
    required this.energy,
    required this.focus,
    required this.confidence,
    required this.stress,
    required this.score,
  });
}

class MentalStorage {
  static final List<MentalEntry> entries = [];

  static void addEntry(MentalEntry entry) {
    entries.add(entry);
  }
}
