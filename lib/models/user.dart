class User {
  final String epicGamesId;
  final String name;
  final String email;
  late final bool canAccess;
  late final bool isAuthorized;
  String role;

  User({
    required this.epicGamesId,
    required this.name,
    required this.email,
    required this.canAccess,
    required this.isAuthorized,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      epicGamesId: json['epicGamesId'],
      name: json['name'],
      email: json['email'],
      canAccess: json['canAccess'],
      isAuthorized: json['isAuthorized'],
      role: json['role'],
    );
  }
}