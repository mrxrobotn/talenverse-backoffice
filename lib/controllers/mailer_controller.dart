import 'dart:convert';
import 'package:http/http.dart' as http;
import '../private_credentials.dart';

void sendEmail({
  required String toEmail,
  required String toName,
  required String subject,
  required String htmlContent,
}) async {

  final headers = {
    'accept': 'application/json',
    'api-key': MAILER_API_KEY,
    'content-type': 'application/json',
  };

  final emailData = {
    'sender': {'name': 'Talent Verse Team', 'email': 'production@dall4all.org'},
    'to': [{'email': toEmail, 'name': toName}],
    'subject': subject,
    'htmlContent': htmlContent,
  };

  try {
    final response = await http.post(
      Uri.parse(MAILER_API_URL),
      headers: headers,
      body: jsonEncode(emailData),
    );

    if (response.statusCode == 200) {
      print('Email sent successfully. Response: ${response.body}');
    } else {
      print('Error sending email. Status code: ${response.statusCode}, Response: ${response.body}');
    }
  } catch (error) {
    print('Error sending email: $error');
  }
}
