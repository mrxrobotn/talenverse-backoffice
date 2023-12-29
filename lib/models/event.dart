class Event {
  final String name;
  final String date;
  final List<String> sessions;

  Event({
    required this.name,
    required this.date,
    required this.sessions,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      name: json['name'],
      date: json['date'],
      sessions: (json['sessions'] as List<dynamic>?)
          ?.map((session) => session.toString())
          .toList() ?? [],
    );
  }
}