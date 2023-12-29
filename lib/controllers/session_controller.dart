import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/session.dart';

Future<List<Session>> fetchSessions() async {
  final response = await http.get(Uri.parse('$apiUrl/sessions'));

  if (response.statusCode == 200) {
    List<dynamic> jsonResponse = json.decode(response.body);
    return jsonResponse.map((user) => Session.fromJson(user)).toList();
  } else {
    throw Exception('Failed to load sessions. Status code: ${response.statusCode}');
  }
}

Future<Map<String, dynamic>> getSessionById(String sessionId) async {
  final response = await http.get(Uri.parse('$apiUrl/sessions/id/$sessionId'));

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    // Handle error cases
    throw Exception('Failed to load session');
  }
}

Future<String?> fetchSessionIdByName(String name) async {
  final response = await http.get(Uri.parse('$apiUrl/sessions/$name'));

  if (response.statusCode == 200) {
    Map<String, dynamic> jsonResponse = json.decode(response.body);
    return jsonResponse['_id'];
  } else {
    throw Exception('Failed to fetch session ID. Status code: ${response.statusCode}');
  }
}

Future<List<Session>> fetchActiveSessions() async {
  final response = await http.get(Uri.parse('$apiUrl/sessions'));

  if (response.statusCode == 200) {
    List<dynamic> jsonResponse = json.decode(response.body);

    List<dynamic> activeSessions = jsonResponse.where((session) => session['isActive'] == true).toList();

    return activeSessions.map((session) => Session.fromJson(session)).toList();
  } else {
    throw Exception('Failed to load sessions. Status code: ${response.statusCode}');
  }
}

Future<void> updateSession(String name, int slotTal, int slotEnt, bool isActive, List<dynamic> users, bool shouldUpdateUsers) async {
  final Map<String, dynamic> requestBody = {
    'slotTal': slotTal,
    'slotEnt': slotEnt,
    'isActive': isActive,
  };

  if (shouldUpdateUsers) {
    requestBody['users'] = users;
  }

  final response = await http.put(
    Uri.parse('$apiUrl/sessions/$name'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode(requestBody),
  );

  if (response.statusCode == 200) {
    print('Session updated successfully');
  } else {
    print('Failed to update Session: ${response.statusCode}');
    throw Exception('Failed to update Session');
  }
}

Future<void> createSession(String name, int slotTal, int slotEnt, bool isActive, List<String> users, List<Map<String, dynamic>> votes) async {

  final response = await http.post(
    Uri.parse('$apiUrl/sessions'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, dynamic>{
      'name': name,
      'slotTal': slotTal,
      'slotEnt': slotEnt,
      'isActive': isActive,
      'users': users,
      'votes': votes,
    }),
  );

  if (response.statusCode == 200) {
    print('Session Data posted successfully');
  } else {
    // Handle error
    print('Error posting data: ${response.statusCode}');
    print(response.body);
  }
}

Future<void> addUserToSession(String sessionName, String userId) async {

  final response = await http.put(
    Uri.parse('$apiUrl/sessions/$sessionName/users'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, dynamic>{
      '_id': userId,
    }),
  );

  if (response.statusCode == 200) {
    print('User added successfully');
  } else {
    // Handle error
    print('Error adding user: ${response.statusCode}');
    print(response.body);
  }
}

Future<void> updateSessionUser(String sessionName, String userId, String room) async {
  final response = await http.put(
    Uri.parse('$apiUrl/sessions/$sessionName/users/$userId'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, dynamic>{
      'room': room,
    }),
  );

  if (response.statusCode == 200) {
    print('Room updated successfully');
  } else {
    // Handle error
    print('Error updating room: ${response.statusCode}');
    print(response.body);
  }
}

Future<bool> checkUserInSessions(String userId) async {
  try {
    // Fetch a list of active sessions
    final List<Session> activeSessions = await fetchActiveSessions();

    // Iterate through each active session
    for (var activeSession in activeSessions) {
      final sessionName = activeSession.name;

      // Fetch session details
      final sessionResponse =
      await http.get(Uri.parse('$apiUrl/sessions/$sessionName'));

      if (sessionResponse.statusCode == 200) {
        final sessionData = jsonDecode(sessionResponse.body);
        final List<dynamic> users = sessionData['users'];

        // Check if the user exists in the current session
        if (users.any((user) => user['userId'] == userId)) {
          return true;
        }
      } else {
        // Handle error for fetching session details
        print('Error fetching session details: ${sessionResponse.statusCode}');
        print(sessionResponse.body);
      }
    }

    // User was not found in any active session
    return false;
  } catch (e) {
    // Handle other exceptions
    print('Exception: $e');
    return false;
  }
}

Future<void> deleteUserFromSession(String sessionName, String userId, int slotTal, int slotEnt) async {
  try {
    // Fetch session details
    final sessionResponse = await http.get(Uri.parse('$apiUrl/sessions/$sessionName'));

    if (sessionResponse.statusCode == 200) {
      final Map<String, dynamic> sessionData = jsonDecode(sessionResponse.body);

      // Retrieve the users array
      List<dynamic> users = List<String>.from(sessionData['users']);

      // Remove the user with the specified userId
      users.removeWhere((user) => user['_id'] == userId);

      // Update the session with the modified users array
      await updateSession(
        sessionName,
        slotTal,
        slotEnt,
        sessionData['isActive'],
        users,
        true
      );
    } else {
      // Handle error for fetching session details
      print('Error fetching session details: ${sessionResponse.statusCode}');
      print(sessionResponse.body);
    }
  } catch (e) {
    // Handle other exceptions
    print('Exception: $e');
  }
}

Future<List<dynamic>> getUsersInSession(String sessionName) async {
  final sessionResponse = await http.get(Uri.parse('$apiUrl/sessions/$sessionName'));

  if (sessionResponse.statusCode == 200) {
    final sessionData = jsonDecode(sessionResponse.body);
    final List<dynamic> users = sessionData['users'];

    return users;
  } else {
    // Handle error
    print('Error fetching session: ${sessionResponse.statusCode}');
    print(sessionResponse.body);
    return [];
  }
}

Future<void> deleteSession(String name) async {

  try {
    final response = await http.delete(
      Uri.parse('$apiUrl/sessions/$name'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      print('Session deleted successfully');
    } else if (response.statusCode == 500) {
      print('Session not found');
    } else {
      print('Failed to delete Session. Status code: ${response.statusCode}');
      print('Error: ${json.decode(response.body)}');
    }
  } catch (error) {
    print('Error: $error');
  }
}

Future<void> updateSlots(String name, int slotTal, int slotEnt) async {
  final response = await http.patch(
    Uri.parse('$apiUrl/sessions/$name'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'slotTal': slotTal,
      'slotEnt': slotEnt,
    }),
  );

  if (response.statusCode == 200) {
    print('Slots updated successfully');
  } else {
    throw Exception('Failed to update Slots');
  }
}