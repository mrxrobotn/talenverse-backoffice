import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/user.dart';

Future<void> createUser(String epicGamesId, String name, String email, List<String> events, List<String> sessions, String room, bool canAccess,bool isAuthorized, String role) async {

  final response = await http.post(
    Uri.parse('$apiUrl/users'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, dynamic>{
      'epicGamesId': epicGamesId,
      'name': name,
      'email': email,
      'events': events,
      'sessions': sessions,
      'room': room,
      'canAccess': canAccess,
      'isAuthorized': isAuthorized,
      'role': role,
    }),
  );

  if (response.statusCode == 200) {
    print('Data posted successfully');
  } else {
    // Handle error
    print('Error posting data: ${response.statusCode}');
    print(response.body);
  }
}

Future<bool> checkUser(String epicGamesId) async {
  final response = await http.get(Uri.parse('$apiUrl/users/$epicGamesId'));

  if (response.statusCode == 200) {
    return true;
  } else {
    return false;
  }
}

Future<Map<String, dynamic>?> getUserData(String epicGamesId) async {
  final response = await http.get(Uri.parse('$apiUrl/users/$epicGamesId'));

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to get user data');
  }
}

Future<List<User>> fetchUsers() async {
  final response = await http.get(Uri.parse('$apiUrl/users'));

  if (response.statusCode == 200) {
    List<dynamic> jsonResponse = json.decode(response.body);
    return jsonResponse.map((user) => User.fromJson(user)).toList();
  } else {
    throw Exception('Failed to load users');
  }
}

Future<void> updateUser(String epicGamesId, List<String> events, List<String> sessions, String room, bool canAccess, bool isAuthorized) async {
  final response = await http.put(
    Uri.parse('$apiUrl/users/$epicGamesId'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'events': events,
      'sessions': sessions,
      'room': room,
      'canAccess': canAccess,
      'isAuthorized': isAuthorized,
    }),
  );

  if (response.statusCode == 200) {
    print('User updated successfully');
  } else {
    print('Failed to update user: ${response.statusCode}');
    throw Exception('Failed to update user');
  }
}

Future<void> updateUserRole(String epicGamesId, String role) async {
  final response = await http.patch(
    Uri.parse('$apiUrl/users/$epicGamesId'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'role': role,
    }),
  );

  if (response.statusCode == 200) {
    print('User updated successfully');
  } else {
    print('Failed to update user: ${response.statusCode}');
    throw Exception('Failed to update user');
  }
}