class SwimPerformance {
  final DateTime date;

  final String event;

  final String pool;

  final String time;

  final String split50;

  final String split100;

  final String notes;

  // Mental readiness
  int energy;

  int focus;

  int confidence;

  int stress;

  // Reaction
  double reactionTime;

  SwimPerformance({
    required this.date,

    required this.event,

    required this.pool,

    required this.time,

    required this.split50,

    required this.split100,

    required this.notes,

    this.energy = 3,

    this.focus = 3,

    this.confidence = 3,

    this.stress = 3,

    this.reactionTime = 0,
  });
}
