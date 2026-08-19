class RaceEntry {
  final String event;
  final String time;
  final String split50;
  final String split100;
  final String feeling;
  final String notes;

  RaceEntry({
    required this.event,
    required this.time,
    required this.split50,
    required this.split100,
    required this.feeling,
    required this.notes,
  });
}

class RaceStorage {
  static final List<RaceEntry> races = [];

  static void addRace(RaceEntry race) {
    races.add(race);
  }

  static int get raceCount {
    return races.length;
  }
}
