import 'dart:convert';
import 'package:http/http.dart' as http;
import '../private_credentials.dart';

Future<bool> validateCredentials(String email, String password) async {
  final response = await http.get(
      Uri.parse('$SERVER_API_URL/admins')
  );

  if (response.statusCode == 200) {
    final List<dynamic> admins = jsonDecode(response.body);

    for (var admin in admins) {
      final String adminEmail = admin['email'];
      final String adminPassword = admin['password'];

      if (adminEmail == email && adminPassword == password) {
        return true;
      }
    }
    return false;
  } else {
    print('Failed to load admins. Error ${response.statusCode}');
    return false;
  }
}