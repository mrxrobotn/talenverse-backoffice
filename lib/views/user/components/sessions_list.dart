import 'dart:async';
import 'package:Netinfo_Metaverse/controllers/event_controller.dart';
import 'package:Netinfo_Metaverse/models/event.dart';
import 'package:flutter/material.dart';
import '../../../constants.dart';
import '../../../controllers/session_controller.dart';
import '../../../models/session.dart';

class SessionsList extends StatefulWidget {
  final String role;
  final String userId;
  final String name;
  final String room;
  const SessionsList({Key? key, required this.role, required this.userId, required this.name, required this.room})
      : super(key: key);

  @override
  _SessionsListState createState() => _SessionsListState();
}

class _SessionsListState extends State<SessionsList> {
  late StreamController<List<Session>> _sessionsController;
  late StreamController<List<Event>> _eventsController;
  late List<Event> allEvents;

  late List<Session> allSessions;
  List<Session> selectedSessions = [];
  late String sessionName;

  @override
  void initState() {
    super.initState();
    _sessionsController = StreamController<List<Session>>.broadcast();
    _eventsController = StreamController<List<Event>>.broadcast();
    fetchEvents().then((events) {
      allEvents = events;
      _updateUsersList();
    });
    fetchActiveSessions().then((sessions) {
      allSessions = sessions;
      _updateUsersList();
    });

  }

  @override
  void dispose() {
    _sessionsController.close();
    super.dispose();
  }

  void _updateUsersList() {
    List<Session> activeSessions = allSessions.where((session) => session.isActive).toList();
    List<Event> events = allEvents.toList();
    _eventsController.add(events);
    _sessionsController.add(activeSessions);
  }

  Event? selectedEvent;
  Session? selectedSession;


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Choose a session to join'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            const Text(
                'You are accepted to be a part of this experience. You can join and participate in any sessions from the list below.'),
            const SizedBox(height: 20),
            Row(
              children: [
                StreamBuilder<List<Event>>(
                    stream: _eventsController.stream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator(); // Placeholder for loading state
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text('No dates available.'); // Placeholder for empty state
                      }
                      return Expanded(
                        child: SizedBox(
                          width: 300,
                          child: Column(
                            children: [
                              const Text('Dates Available:'),
                              SizedBox(
                                height: 400,
                                child: ListView.builder(
                                  itemCount: snapshot.data!.length,
                                  itemBuilder: (context, index) {
                                    final event = snapshot.data?[index];
                                    return Card(
                                      elevation: 3,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12.0),
                                      ),
                                      child: ListTile(
                                        title: Text(event!.date),
                                        onTap: () {
                                          setState(() {
                                            selectedEvent = event;
                                          });
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                 ),
                StreamBuilder<List<Session>>(
                  stream: _sessionsController.stream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No sessions found.'));
                    }

                    List<Session> activeSessions = snapshot.data!;
                    List<Session> sessionsForSelectedEvent = selectedEvent != null
                        ? activeSessions.where((session) =>
                        selectedEvent!.sessions.contains(session.id))
                        .toList()
                        : activeSessions.toList();

                    return Expanded(
                      child: SizedBox(
                        width: 300,
                        child: Column(
                          children: [
                            const Text('Sessions available:'),
                            if (selectedEvent != null)
                            SizedBox(
                              height: 400,
                              child: ListView.builder(
                                itemCount: sessionsForSelectedEvent.length,
                                itemBuilder: (context, index) {
                                  final session = sessionsForSelectedEvent[index];
                                  bool isSelected = selectedSession == session;
                                  return Card(
                                    elevation: 3,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    child: ListTile(
                                      title: Text(session.name),
                                      onTap: () {
                                        setState(() {
                                          if (widget.role == "Talent") {
                                            if (session.slotTal != 0) {
                                              if (isSelected) {
                                                selectedSession = null;
                                              } else {
                                                selectedSession = session;
                                              }
                                            } else {
                                              const snackBar = SnackBar(
                                                content: Text('Sorry! but the session is full'),
                                              );
                                              ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                            }
                                          } else if (widget.role == "Entrepreneur") {
                                            if (session.slotEnt != 0) {
                                              if (isSelected) {
                                                selectedSession = null;
                                              } else {
                                                selectedSession = session;
                                              }
                                            } else {
                                              const snackBar = SnackBar(
                                                content: Text('Sorry! but the session is full'),
                                              );
                                              ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                            }
                                          }

                                        });
                                      },
                                      tileColor: isSelected
                                          ? Colors.blue.withOpacity(0.1)
                                          : null,
                                      leading: isSelected
                                          ? const Icon(Icons.check_circle,
                                          color: chartColor1)
                                          : null,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('CLOSE'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          onPressed: selectedSession != null
              ? () async {
            bool userExists = await checkUserInSessions(widget.userId);
            if (!userExists) {
              if (widget.role == "Talent") {
                selectedSession!.slotTal--;
              } else if (widget.role == "Entrepreneur") {
                selectedSession!.slotEnt--;
              }

              Future.delayed(const Duration(seconds: 2), () async {
                addUserToSession(selectedSession!.name, widget.userId);
                updateSlots(selectedSession!.name, selectedSession!.slotTal, selectedSession!.slotEnt);
                Navigator.of(context).pop();
              });
            } else {
              Navigator.of(context).pop();
              const snackBar = SnackBar(
                content: Text('You are already registered in a session, wait for the admin to accept or refuse your request. Thank you for you patience'),
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            }
          }
              : null,
          child: const Text('SAVE'),
        ),
      ],
    );
  }
}
