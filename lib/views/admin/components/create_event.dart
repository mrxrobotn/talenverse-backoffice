import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../constants.dart';
import '../../../controllers/event_controller.dart';
import '../../../controllers/session_controller.dart';

class CreateEvent extends StatefulWidget {
  const CreateEvent({super.key});

  @override
  State<CreateEvent> createState() => _CreateEventState();
}

class _CreateEventState extends State<CreateEvent> {
  @override
  Widget build(BuildContext context) {
    return const AlertDialog(
      content: SizedBox(
        width: 520,
        height: 520,
        child: Column(
            children: [
              Text(
                "New Event",
                style: TextStyle(fontSize: 34, fontFamily: "Poppins"),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  "Please fill this form with the right informations.",
                  textAlign: TextAlign.center,
                ),
              ),
              NewEventForm(),
            ]
        ),
      ),
    );
  }
}


class NewEventForm extends StatefulWidget {
  const NewEventForm({super.key});

  @override
  State<NewEventForm> createState() => _NewEventFormState();
}

class _NewEventFormState extends State<NewEventForm> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController name = TextEditingController();
  TextEditingController date = TextEditingController();
  List<String> sessions = [];
  int slotTal = 12;
  int slotEnt = 8;
  bool isActive = false;
  List<String> users = [];
  List<Map<String, String>> votes = [];

  void checkValidStatus(BuildContext context) async {
    Future.delayed(const Duration(seconds: 1), () async {

      if (_formKey.currentState!.validate()) {
        String session1Name = "${date.text}_1";
        String session2Name = "${date.text}_2";
        createSession(session1Name, slotTal, slotEnt, isActive, users, votes);
        createSession(session2Name, slotTal, slotEnt, isActive, users, votes);
        // show success
        Future.delayed(const Duration(seconds: 2), () async {

          String? session1Id = await fetchSessionIdByName(session1Name);
          String? session2Id = await fetchSessionIdByName(session2Name);
          try {
            print('Session ID for $session1Name: $session1Id');
            print('Session ID for $session2Name: $session2Id');
            createEvent(name.text, date.text, [session1Id!, session2Id!]);

          } catch (e) {
            print('Error fetching session ID: $e');
          }

          Navigator.of(context).pop();
          const snackBar = SnackBar(
            content:
            Text('Event created'),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        });
      }
      else {
        const snackBar = SnackBar(
          content:
          Text('Failed'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Name*",
                    style: TextStyle(color: Colors.black54),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 16),
                    child: TextFormField(
                      controller: name,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter a name";
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        prefixIcon: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Icon(Icons.event),
                        ),
                        errorStyle: TextStyle(
                          color: chartColor2,
                        ),
                      ),
                    ),
                  ),
                  const Text(
                    "Date*",
                    style: TextStyle(color: Colors.black54),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 16),
                    child: TextFormField(
                      controller: date,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter a date";
                        }

                        // Define a regular expression for the desired date format (mm-dd-yyyy)
                        RegExp dateRegex = RegExp(r'^(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])-\d{4}$');

                        if (!dateRegex.hasMatch(value)) {
                          return "Please enter a valid date format (mm-dd-yyyy)";
                        }

                        return null;
                      },
                      decoration: const InputDecoration(
                        prefixIcon: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Icon(Icons.date_range),
                        ),
                        errorStyle: TextStyle(
                          color: chartColor2,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 24),
                    child: ElevatedButton.icon(
                        onPressed: () async {
                          checkValidStatus(context);
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: chartColor1,
                            minimumSize: const Size(double.infinity, 56),
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(10)))),
                        icon: const Icon(
                          CupertinoIcons.add,
                          color: backgroundColorDark,
                        ),
                        label: const Text("CREATE", style: TextStyle(color: backgroundColorDark))),
                  ),
                ],
              ),
            )
        ),
      ],
    );
  }
}
