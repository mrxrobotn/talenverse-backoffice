class User {
  final String epicGamesId;
  final String name;
  final String email;
  late final List<String> events;
  late final List<String> sessions;
  final String room;
  late final bool canAccess;
  late final bool isAuthorized;
  String role;

  User({
    required this.epicGamesId,
    required this.name,
    required this.email,
    required this.events,
    required this.sessions,
    required this.room,
    required this.canAccess,
    required this.isAuthorized,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      epicGamesId: json['epicGamesId'],
      name: json['name'],
      email: json['email'],
      events: (json['events'] as List<dynamic>?)
          ?.map((event) => event.toString())
          .toList() ?? [],
      sessions: (json['sessions'] as List<dynamic>?)
          ?.map((event) => event.toString())
          .toList() ?? [],
      room: json['room'],
      canAccess: json['canAccess'],
      isAuthorized: json['isAuthorized'],
      role: json['role'],
    );
  }
}