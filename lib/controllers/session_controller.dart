import 'dart:convert';
import 'package:Netinfo_Metaverse/controllers/event_controller.dart';
import 'package:Netinfo_Metaverse/controllers/user_controller.dart';
import 'package:http/http.dart' as http;
import '../private_credentials.dart';
import '../models/session.dart';

Future<List<Session>> fetchSessions() async {
  final response = await http.get(Uri.parse('$SERVER_API_URL/sessions'));

  if (response.statusCode == 200) {
    List<dynamic> jsonResponse = json.decode(response.body);
    return jsonResponse.map((user) => Session.fromJson(user)).toList();
  } else {
    throw Exception('Failed to load sessions. Status code: ${response.statusCode}');
  }
}

Future<Map<String, dynamic>> getSessionById(String sessionId) async {
  final response = await http.get(Uri.parse('$SERVER_API_URL/sessions/id/$sessionId'));

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    // Handle error cases
    throw Exception('Failed to load session');
  }
}

Future<String?> fetchSessionIdByName(String name) async {
  final response = await http.get(Uri.parse('$SERVER_API_URL/sessions/$name'));

  if (response.statusCode == 200) {
    Map<String, dynamic> jsonResponse = json.decode(response.body);
    return jsonResponse['_id'];
  } else {
    throw Exception('Failed to fetch session ID. Status code: ${response.statusCode}');
  }
}

Future<List<Session>> fetchActiveSessions() async {
  final response = await http.get(Uri.parse('$SERVER_API_URL/sessions'));

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
    Uri.parse('$SERVER_API_URL/sessions/$name'),
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
    Uri.parse('$SERVER_API_URL/sessions'),
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
    Uri.parse('$SERVER_API_URL/sessions/$sessionName/users'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, dynamic>{
      'users': userId,
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

Future<bool> checkUserInSessions(String userId) async {
  try {
    // Fetch a list of active sessions
    final List<Session> activeSessions = await fetchActiveSessions();

    // Iterate through each active session
    for (var activeSession in activeSessions) {
      final sessionName = activeSession.name;

      // Fetch session details
      final sessionResponse =
      await http.get(Uri.parse('$SERVER_API_URL/sessions/$sessionName'));

      if (sessionResponse.statusCode == 200) {
        final sessionData = jsonDecode(sessionResponse.body);
        final List<dynamic> users = sessionData['users'];

        // Check if the user exists in the current session
        if (users.contains(userId)) {
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

Future<void> deleteUserFromSession(String sessionName, String userId) async {
  try {
    final response = await http.delete(
      Uri.parse('$SERVER_API_URL/sessions/$sessionName/users'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'users': userId,
      }),
    );

    if (response.statusCode == 200) {
      // User deleted successfully
      print('User deleted successfully');
    } else if (response.statusCode == 404) {
      // User not found in the session
      print('User not found in the session');
    } else {
      // Handle other status codes
      print('Error: ${response.statusCode}');
    }
  } catch (error) {
    // Handle network or server errors
    print('Error: $error');
  }
}

Future<List<String>> getUsersInSession(String sessionName) async {
  final sessionResponse = await http.get(Uri.parse('$SERVER_API_URL/sessions/$sessionName'));

  if (sessionResponse.statusCode == 200) {
    final sessionData = jsonDecode(sessionResponse.body);

    // Extract the "users" array from the sessionData
    final List<dynamic> users = sessionData['users'];

    // Convert the list of users to a list of user ObjectIds (assuming they are strings)
    final List<String> userObjectIds = List<String>.from(users);

    return userObjectIds;
  } else {
    // Handle error
    print('Error fetching session: ${sessionResponse.statusCode}');
    print(sessionResponse.body);
    return [];
  }
}

Future<List<Map<String, dynamic>>> getUsersDataInSession(String sessionName) async {
  final userObjectIds = await getUsersInSession(sessionName);

  List<Map<String, dynamic>> usersData = [];
  for (String userObjectId in userObjectIds) {
    final userData = await getUserById(userObjectId);
    if (userData != null) {
      usersData.add(userData);
    }
  }

  return usersData;
}

Future<void> deleteSession(String name) async {

  try {
    final response = await http.delete(
      Uri.parse('$SERVER_API_URL/sessions/$name'),
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
    Uri.parse('$SERVER_API_URL/sessions/$name'),
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

Future<void> moveUserToAnotherSession(String sessionId, String destinationSessionId, String userId) async {

  try {
    final response = await http.put(
      Uri.parse('$SERVER_API_URL/sessions/id/$sessionId/users/$userId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': destinationSessionId,
      }),
    );


    if (response.statusCode == 200) {
      print('User $userId moved from session $sessionId to $destinationSessionId');

      // Update the user model after successful move
      await updateUserAfterMove(destinationSessionId, userId);
    } else {
      print('Error moving user: ${response.statusCode}');
      // Handle error response
    }
  } catch (error) {
    print('Error moving user: $error');
    // Handle network error
  }
}

Future<void> updateUserAfterMove(String destinationSessionId, String userId) async {

  try {
    // Retrieve the user's current data
    final getUserResponse = await http.get(Uri.parse('$SERVER_API_URL/users/id/$userId'));
    if (getUserResponse.statusCode == 200) {
      final userData = jsonDecode(getUserResponse.body);
      String eventId = await findEventBySessionId(destinationSessionId);

      // Extract the necessary data for update
      final events = [eventId];
      final sessions = [destinationSessionId];

      // Make the update user request
      await updateUser(userData['epicGamesId'], events, sessions, userData['room'], userData['canAccess'], userData['isAuthorized'], userData['enableRoomCreator']);
    } else {
      print('Error getting user data: ${getUserResponse.statusCode}');
      // Handle error response
    }
  } catch (error) {
    print('Error updating user: $error');
    // Handle network error
  }
}

Future<List<Map<String, dynamic>>> getTalentsWithMarksInSession(String sessionId) async {
  final sessionData = await getSessionById(sessionId);
  final userObjectIds = List<String>.from(sessionData['users']);
  final List<Map<String, dynamic>> talentsWithMarks = [];

  print('Session Data: $sessionData');

  for (String userObjectId in userObjectIds) {
    final userData = await getUserById(userObjectId);
    if (userData != null) {
      final votes = sessionData['votes'].where(
            (v) => v['voters'].first == userObjectId,
      );

      for (var vote in votes) {
        print('Vote: $vote');
        final talentId = vote['talent'][0]['\$oid']["_id"];
        final mark = vote['mark'];

        final Map<String, dynamic> talentWithMark = {
          'talent': talentId,
          'mark': mark,
        };

        talentsWithMarks.add(talentWithMark);
      }
    }
  }

  print('Talents With Marks: $talentsWithMarks');

  return talentsWithMarks;
}