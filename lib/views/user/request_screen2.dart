import 'package:flutter/material.dart';
import 'components/user_request_form2.dart';

class RequestPage2 extends StatelessWidget {
  const RequestPage2({super.key});

  @override
  Widget build(BuildContext context) {
    return const Expanded(
      child: SingleChildScrollView(
        child: Column(
            children: [
              Text(
                "Join The Experience",
                style: TextStyle(fontSize: 34, fontFamily: "Poppins"),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  "Request download link and join the experience in the TalentVerse.",
                  textAlign: TextAlign.center,
                ),
              ),
              RequestForm2()
            ]
        ),
      ),
    );
  }
}
