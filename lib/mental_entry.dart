class MentalEntry {
  final String event;

  final int confidence;
  final int focus;
  final int energy;
  final int stress;

  final String date;

  MentalEntry({
    required this.event,
    required this.confidence,
    required this.focus,
    required this.energy,
    required this.stress,
    required this.date,
  });
}
