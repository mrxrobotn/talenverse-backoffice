import 'package:flutter/material.dart';
import 'components/user_request_form.dart';

class RequestPage extends StatelessWidget {
  const RequestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        width: 450,
        height: 650,
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius:  BorderRadius.circular(10.0),
          color: Colors.white.withOpacity(0.6),
        ),
        child: Row(
          children: [
            Expanded(
              child: Image.asset('assets/Backgrounds/request.png')
            ),
            const Expanded(
              child: SingleChildScrollView(
                child: Column(
                    children: [
                      Text(
                        "Request Access",
                        style: TextStyle(fontSize: 34, fontFamily: "Poppins"),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          "Request access to enter and join the experience in the TalentVerse.",
                          textAlign: TextAlign.center,
                        ),
                      ),

                      RequestForm()
                    ]
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
