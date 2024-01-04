import 'package:flutter/material.dart';

const Color chartColor1 = Color(0xFF15CCC7);
const Color chartColor2 = Color(0xFFFE0000);
const Color backgroundColorLight = Color(0xFFF2F6FF);
const Color backgroundColorDark = Color(0xFF25254B);
const Color shadowColorLight = Color(0xFF4A5367);
const Color shadowColorDark = Colors.black;
const Color cardColor = Colors.green;

const String apiUrl = 'http://localhost:3000/api/v1';
//const String apiUrl = 'https://nm-api-nfcyw7o2xa-ew.a.run.app/api/v1';

List<String> roles = ['Admin', 'Staff', 'Entrepreneur', 'Talent', 'Visitor'];

class CustomPositioned extends StatelessWidget {
  const CustomPositioned({super.key, required this.child, this.size = 100});
  final Widget child;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Column(
        children: [
          const Spacer(),
          SizedBox(
            height: size,
            width: size,
            child: child,
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}

const String htmlFirstContent = '''
      <html>
        <head></head>
        <body>
          <p>Hello ,</p>
          <p>Thank you for your request. To complete your registration, please click the following link:</p>
          <a href="https://talentverse-8aa4e.firebaseapp.com/#/sessions">Complete Registration</a>
          <p>If you have any questions, feel free to contact us.</p>
        </body>
      </html>
    ''';

const String htmlSecondContent = '''
      <html>
        <head></head>
        <body>
          <p>Hello ,</p>
          <p>Thank you for your request. You are now accepted to be a part in the TalentVerse space</p>
          <p>Please follow this link if you forget your room number.</p>
          <a href="https://talentverse-8aa4e.firebaseapp.com/#/sessions">Visit link</a>
          <p>If you have any questions, feel free to contact us.</p>
        </body>
      </html>
    ''';