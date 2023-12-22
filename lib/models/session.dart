class Session {
  final String name;
  final String date;
  int slotTal;
  int slotEnt;
  final bool isActive;
  final List<Map<String, dynamic>> users;

  Session({
    required this.name,
    required this.date,
    required this.slotTal,
    required this.slotEnt,
    required this.isActive,
    required this.users,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      name: json['name'],
      date: json['date'],
      slotTal: json['slotTal'],
      slotEnt: json['slotEnt'],
      isActive: json['isActive'],
      users: (json['users'] as List<dynamic>?)
          ?.map((user) => {
        'userId': user['epicGamesId'],
        'role': user['role'],
      })
          .toList() ?? [],
    );
  }
}