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
  static Future<Room?> getRoom(String roomId) async {
    final url = Uri.parse('$SERVER_API_URL/rooms/$roomId');
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
  static Future<Room?> updateRoom(String roomId, Map<String, dynamic> updates) async {
    final url = Uri.parse('$SERVER_API_URL/rooms/$roomId');
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
  static Future<bool> deleteRoom(String roomId) async {
    final url = Uri.parse('$SERVER_API_URL/rooms/roomId');
    final response = await http.delete(url);

    return response.statusCode == 200;
  }

  // Add Asset to Room
  static Future<Room?> addAsset(String roomId, Asset asset) async {
    final url = Uri.parse('$SERVER_API_URL/rooms/$roomId/asset');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(asset.toJson()),
    );

    if (response.statusCode == 201) {
      return Room.fromJson(jsonDecode(response.body));
    } else {
      return null;
    }
  }

  // Update Asset
  static Future<Asset?> updateAsset(String roomId, String assetId, Map<String, dynamic> updates) async {
    final url = Uri.parse('$SERVER_API_URL/rooms/$roomId/asset/$assetId');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(updates),
    );

    if (response.statusCode == 200) {
      return Asset.fromJson(jsonDecode(response.body));
    } else {
      return null;
    }
  }

  // Delete Asset
  static Future<bool> deleteAsset(String roomId, String assetId) async {
    final url = Uri.parse('$SERVER_API_URL/rooms/$roomId/asset/$assetId');
    final response = await http.delete(url);

    return response.statusCode == 200;
  }

  // Get All Assets for a Room
  static Future<List<Asset>> getAllAssetsByRoomId(String roomId) async {
    final url = Uri.parse('$SERVER_API_URL/rooms/$roomId/asset');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((e) => Asset.fromJson(e)).toList();
    } else {
      return [];
    }
  }

  // Get Specific Asset by asset_id
  static Future<Asset?> getAssetById(String roomId, String assetId) async {
    final url = Uri.parse('$SERVER_API_URL/rooms/$roomId/asset/$assetId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return Asset.fromJson(jsonDecode(response.body));
    } else {
      return null;
    }
  }
}
