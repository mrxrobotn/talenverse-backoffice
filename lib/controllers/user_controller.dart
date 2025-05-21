import 'dart:convert';
import 'package:http/http.dart' as http;
import '../private_credentials.dart';
import '../models/user.dart';

Future<void> createUser(String epicGamesId, String name, String email, List<String> events, List<String> sessions, String room, bool canAccess,bool isAuthorized, String role) async {

  final response = await http.post(
    Uri.parse('$SERVER_API_URL/users'),
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
  final response = await http.get(Uri.parse('$SERVER_API_URL/users/$epicGamesId'));

  if (response.statusCode == 200) {
    return true;
  } else {
    return false;
  }
}

Future<Map<String, dynamic>?> getUserData(String epicGamesId) async {
  final response = await http.get(Uri.parse('$SERVER_API_URL/users/$epicGamesId'));

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to get user data');
  }
}

Future<Map<String, dynamic>?> getUserById(String id) async {
  final response = await http.get(Uri.parse('$SERVER_API_URL/users/id/$id'));

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to get user data');
  }
}

Future<List<User>> fetchUsers() async {
  final response = await http.get(Uri.parse('$SERVER_API_URL/users'));

  if (response.statusCode == 200) {
    List<dynamic> jsonResponse = json.decode(response.body);
    return jsonResponse.map((user) => User.fromJson(user)).toList();
  } else {
    throw Exception('Failed to load users');
  }
}

Future<void> updateUser(String epicGamesId, List<String> events, List<String> sessions, String room, bool canAccess, bool isAuthorized) async {
  final response = await http.put(
    Uri.parse('$SERVER_API_URL/users/$epicGamesId'),
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
    Uri.parse('$SERVER_API_URL/users/$epicGamesId'),
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

Future<void> deleteSessionAndEventFromUser(String userId, String event, String session) async {
  final String apiUrl = 'YOUR_SERVER_API_ENDPOINT/users/$userId'; // Replace with your actual API endpoint

  final Map<String, String> headers = {'Content-Type': 'application/json'};

  final Map<String, dynamic> requestBody = {
    'events': [event],
    'sessions': [session],
  };

  try {
    final response = await http.delete(
      Uri.parse('$apiUrl/users/id/$userId'),
      headers: headers,
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      print('Session & Event deleted successfully');
    } else if (response.statusCode == 404) {
      print('User not found');
    } else {
      print('Internal Server Error');
    }
  } catch (error) {
    print('Error: $error');
  }
}