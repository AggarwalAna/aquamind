// lib/user_profile.dart

class EventRecord {
  String eventName;
  String personalBest;
  String goalTime;

  EventRecord({
    required this.eventName,
    required this.personalBest,
    required this.goalTime,
  });

  Map<String, dynamic> toJson() => {
        'eventName': eventName,
        'personalBest': personalBest,
        'goalTime': goalTime,
      };

  factory EventRecord.fromJson(Map<String, dynamic> json) => EventRecord(
        eventName: json['eventName'] ?? '',
        personalBest: json['personalBest'] ?? '',
        goalTime: json['goalTime'] ?? '',
      );
}

class UserProfile {
  final String id;
  String name;
  int age;
  String category;
  List<EventRecord> events;

  UserProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.category,
    required this.events,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'age': age,
        'category': category,
        'events': events.map((e) => e.toJson()).toList(),
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: json['name'] ?? '',
        age: json['age'] ?? 14,
        category: json['category'] ?? 'Club Swimmer',
        events: (json['events'] as List<dynamic>?)
                ?.map((e) => EventRecord.fromJson(e))
                .toList() ??
            [],
      );
}
