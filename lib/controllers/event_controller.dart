import 'dart:convert';
import 'package:http/http.dart' as http;
import '../private_credentials.dart';
import '../../../models/event.dart';

Future<void> createEvent(String name, String date, List<String> sessions) async {

  final response = await http.post(
    Uri.parse('$SERVER_API_URL/events'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, dynamic>{
      'name': name,
      'date': date,
      'sessions': sessions,
    }),
  );

  if (response.statusCode == 200) {
    print('Event Data posted successfully');
  } else {
    // Handle error
    print('Error posting data: ${response.statusCode}');
    print(response.body);
  }
}

Future<List<Event>> fetchEvents() async {
  try {
    final response = await http.get(Uri.parse('$SERVER_API_URL/events'));

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      List<dynamic> documents = jsonResponse['documents'];

      return documents.map((event) => Event.fromJson(event)).toList();
    } else {
      throw Exception('Failed to load events. Status code: ${response.statusCode}');
    }
  } catch (error) {
    throw Exception('Failed to load events. Error: $error');
  }
}

Future<String> findEventBySessionId(String sessionId) async {
  final response = await http.get(Uri.parse('$SERVER_API_URL/events/sessions?sessionId=$sessionId'));

  if (response.statusCode == 200) {
    // If server returns an OK response, parse the JSON
    final Map<String, dynamic> data = json.decode(response.body);
    return data['eventId'];
  } else if (response.statusCode == 404) {
    // Handle the case where no matching event is found
    return "";
  } else {
    // If the server did not return a 200 OK or 404 Not Found response,
    // throw an exception.
    throw Exception('Failed to find event by session');
  }
}

Future<Map<String, dynamic>?> getEventDataById(String id) async {
  final response = await http.get(Uri.parse('$SERVER_API_URL/events/id/$id'));

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to get event data');
  }
}