// lib/race_session.dart
class RaceSession {
  String? event;
  String? pool;
  String? time;
  List<String> splits;
  int? energy;
  int? focus;
  double confidence;
  double stress;
  String? notes;

  RaceSession({
    this.event,
    this.pool,
    this.time,
    List<String>? splits,
    this.energy,
    this.focus,
    this.confidence = 5.0,
    this.stress = 5.0,
    this.notes,
  }) : splits = splits ?? [];

  Map<String, dynamic> toJson() => {
    'event': event,
    'pool': pool,
    'time': time,
    'splits': splits,
    'energy': energy,
    'focus': focus,
    'confidence': confidence,
    'stress': stress,
    'notes': notes,
  };

  factory RaceSession.fromJson(Map<String, dynamic> json) => RaceSession(
    event: json['event'] as String?,
    pool: json['pool'] as String?,
    time: json['time'] as String?,
    splits:
        (json['splits'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
        [],
    energy: json['energy'] as int?,
    focus: json['focus'] as int?,
    confidence: (json['confidence'] as num?)?.toDouble() ?? 5.0,
    stress: (json['stress'] as num?)?.toDouble() ?? 5.0,
    notes: json['notes'] as String?,
  );
}
