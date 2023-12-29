class Session {
  late final String id;
  final String name;
  int slotTal;
  int slotEnt;
  final bool isActive;
  final List<Map<String, dynamic>> votes;
  final List<String> users;

  Session({
    required this.id,
    required this.name,
    required this.slotTal,
    required this.slotEnt,
    required this.isActive,
    required this.users,
    required this.votes,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['_id'],
      name: json['name'],
      slotTal: json['slotTal'],
      slotEnt: json['slotEnt'],
      isActive: json['isActive'],
      users: (json['users'] as List<dynamic>?)
          ?.map((event) => event.toString())
          .toList() ?? [],
      votes: (json['votes'] as List<dynamic>?)
          ?.map((user) => {
        'voters': user['voters'],
        'talent': user['talent'],
        'mark': user['mark'],
      })
          .toList() ?? [],
    );
  }
}