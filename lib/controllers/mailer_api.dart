import 'dart:convert';
import 'package:http/http.dart' as http;

void sendEmail({
  required String toEmail,
  required String toName,
  required String subject,
  required String htmlContent,
}) async {
  const apiKey = 'https://api.brevo.com/v3/smtp/email';
  const apiToken = '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';

  final headers = {
    'accept': 'application/json',
    'api-key': apiToken,
    'content-type': 'application/json',
  };

  final emailData = {
    'sender': {'name': 'TalentVerse', 'email': 'production@dall4all.org'},
    'to': [{'email': toEmail, 'name': toName}],
    'subject': subject,
    'htmlContent': htmlContent,
  };

  try {
    final response = await http.post(
      Uri.parse(apiKey),
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
