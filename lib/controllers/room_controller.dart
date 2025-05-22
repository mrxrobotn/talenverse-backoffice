import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/room.dart';
import '../private_credentials.dart'; // Path to your Room, Asset, Transform classes

class RoomManager {

  // Add Room
  static Future<Room?> addRoom(Room room) async {
    final url = Uri.parse('$SERVER_API_URL/rooms/');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(room.toJson()),
    );

    if (response.statusCode == 201) {
      return Room.fromJson(jsonDecode(response.body));
    } else {
      print('Error adding room: ${response.body}');
      return null;
    }
  }

  // Get all Rooms
  static Future<List<Room>> getRooms() async {
    final url = Uri.parse('$SERVER_API_URL/rooms/');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((e) => Room.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch rooms');
    }
  }

  // Get Room by room_id
  static Future<Room?> getRoom(String ownerEpicGamesId) async {
    final url = Uri.parse('$SERVER_API_URL/rooms/$ownerEpicGamesId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return Room.fromJson(jsonDecode(response.body));
    } else {
      return null;
    }
  }

  // Get Room by _id
  static Future<Room?> getRoomById(String id) async {
    final url = Uri.parse('$SERVER_API_URL/rooms/id/$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return Room.fromJson(jsonDecode(response.body));
    } else {
      return null;
    }
  }

  // Update Room
  static Future<Room?> updateRoom(String ownerEpicGamesId, Map<String, dynamic> updates) async {
    final url = Uri.parse('$SERVER_API_URL/rooms/$ownerEpicGamesId');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(updates),
    );

    if (response.statusCode == 200) {
      return Room.fromJson(jsonDecode(response.body));
    } else {
      return null;
    }
  }

  // Delete Room
  static Future<bool> deleteRoom(String ownerEpicGamesId) async {
    final url = Uri.parse('$SERVER_API_URL/rooms/ownerEpicGamesId');
    final response = await http.delete(url);

    return response.statusCode == 200;
  }
}
