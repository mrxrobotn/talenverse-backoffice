import 'dart:async';
import 'package:Netinfo_Metaverse/controllers/event_controller.dart';
import 'package:Netinfo_Metaverse/controllers/mailer_controller.dart';
import 'package:Netinfo_Metaverse/controllers/user_controller.dart';
import 'package:Netinfo_Metaverse/models/session.dart';
import 'package:flutter/material.dart';
import '../../../constants.dart';
import '../../../controllers/session_controller.dart';
import '../../../models/event.dart';


class SessionsPage extends StatefulWidget {
  const SessionsPage({super.key});

  @override
  State<SessionsPage> createState() => _SessionsPageState();
}

class _SessionsPageState extends State<SessionsPage> {

  late StreamController<List<Session>> _sessionsController;
  late TextEditingController searchController;
  late List<Session> allSessions;

  @override
  void initState() {
    super.initState();
    _sessionsController = StreamController<List<Session>>.broadcast();
    searchController = TextEditingController();
    fetchSessions().then((sessions) {
      allSessions = sessions;
      _updateSessionsList();
    });
  }

  @override
  void dispose() {
    _sessionsController.close();
    super.dispose();
  }

  void _updateSessionsList() {
    String searchInput = searchController.text.toLowerCase();
    List<Session> activeSession = allSessions.toList();
    if (searchInput.isNotEmpty) {
      activeSession = activeSession.where((session) =>
          session.name.toLowerCase().contains(searchInput) )
          .toList();
    }
    _sessionsController.add(activeSession);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white70),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Row(
              children: [
                Text(
                  '/',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Sessions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search by Name',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    _updateSessionsList();
                  },
                ),
              ),
              onChanged: (value) {
                _updateSessionsList();
              },
            ),
            const SizedBox(height: 8),
            StreamBuilder<List<Session>>(
              stream: _sessionsController.stream,
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text('No sessions found.')
                  );
                }

                List<Session> activeSession = snapshot.data!;
                return SizedBox(
                  width: double.infinity,
                  child: SingleChildScrollView(
                    child: PaginatedDataTable(
                      columnSpacing: 56,
                      horizontalMargin: 20.0,
                      rowsPerPage: 15,
                      availableRowsPerPage: const [5, 10, 20],
                      onPageChanged: (pageIndex) {
                        print('Page changed to $pageIndex');
                      },
                      columns: const [
                        DataColumn(
                            label: Row(
                              children: [
                                Icon(Icons.account_box, color: Colors.green),
                                SizedBox(width: 5),
                                Text('Name',
                                    style: TextStyle(fontWeight: FontWeight.bold))
                              ],
                            )),
                        DataColumn(
                            label: Row(
                              children: [
                                Icon(Icons.event_available, color: Colors.orange),
                                SizedBox(width: 5),
                                Text('Talents Slots Available', style: TextStyle(fontWeight: FontWeight.bold))
                              ],
                            )
                        ),
                        DataColumn(
                            label: Row(
                              children: [
                                Icon(Icons.event_available),
                                SizedBox(width: 5),
                                Text('Entrepreneurs Slots Available', style: TextStyle(fontWeight: FontWeight.bold))
                              ],
                            )
                        ),
                        DataColumn(
                            label: Row(
                              children: [
                                Icon(Icons.supervisor_account_sharp),
                                SizedBox(width: 5),
                                Text('Users', style: TextStyle(fontWeight: FontWeight.bold))
                              ],
                            )
                        ),
                        DataColumn(
                            label: Row(
                              children: [
                                Icon(Icons.notifications_active),
                                SizedBox(width: 5),
                                Text('Status', style: TextStyle(fontWeight: FontWeight.bold))
                              ],
                            )
                        ),
                        DataColumn(
                            label: Row(
                              children: [
                                Icon(Icons.lock_outlined, color: chartColor1),
                                SizedBox(width: 5),
                                Text('Action', style: TextStyle(fontWeight: FontWeight.bold))
                              ],
                            )),
                      ],
                      source: _UsersDataSource(
                        sessions: activeSession.toList(),
                        context: context,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _UsersDataSource extends DataTableSource {

  final List<Session> _sessions;
  final BuildContext context;

  List<String> rolesFilter = ['All', 'Entrepreneur', 'Talent', 'Visitor'];

  _UsersDataSource({
    required List<Session> sessions,
    required this.context,
  }) : _sessions = sessions;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController room = TextEditingController();
  TextEditingController newSessionId = TextEditingController();

  @override
  DataRow getRow(int index) {
    final session = _sessions[index];
    return DataRow(cells: [
      DataCell(Text(session.name)),
      DataCell(Text('${session.slotTal.toString()} / 12')),
      DataCell(Text('${session.slotEnt.toString()} / 8')),
      DataCell(
        Row(
          children: [
            TextButton(
              onPressed: () async {
                List<dynamic> usersList = await getUsersDataInSession(session.name);

                _showUsersPopup(session.name, session.slotTal, session.slotEnt, session.isActive, session.users, usersList, rolesFilter, session.id );
              },
              child: const Text('Show users'),
            ),
            const Text(' | '),
            TextButton(
              onPressed: () async {
                List<dynamic> usersList = await getUsersDataInSession(session.name);

                _showMarksPopup(session.name, session.id, usersList, _sessions);
              },
              child: const Text('Show marks'),
            )
          ],
        )
      ),
      DataCell(
        ElevatedButton.icon(
          onPressed: () {
            showDialog<void>(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Confirmation'),
                  content: Text(session.isActive
                      ? 'Are you sure you want to desactivate the session: ${session.name}?'
                      : 'Are you sure you want to activate the session: ${session.name}?'),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('Yes'),
                      onPressed: () {
                        updateSession(session.name, session.slotTal, session.slotEnt, !session.isActive, session.users, false);
                        Navigator.of(context).pop();
                        const snackBar = SnackBar(
                          content:
                          Text('Session updated with success'),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      },
                    ),
                    TextButton(
                      child: const Text('No'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: session.isActive ? chartColor2 : chartColor1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          icon: Icon(
              session.isActive ? Icons.lock_outline : Icons.lock_open_outlined,
              color: backgroundColorLight),
          label: Text(
            session.isActive ? 'Desactivate' : 'Activate',
            style: const TextStyle(fontSize: 12, color: backgroundColorLight),
          ),
        ),
      ),
      DataCell(
        ElevatedButton.icon(
          onPressed: () {
            showDialog<void>(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Confirmation'),
                  content: const Text('Are you sure you want to delete this session?'),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('Yes'),
                      onPressed: () {
                        deleteSession(session.name);
                        Navigator.of(context).pop();
                        const snackBar = SnackBar(
                          content:
                          Text('Session deleted'),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      },
                    ),
                    TextButton(
                      child: const Text('No'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: chartColor2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          icon: const Icon(Icons.delete,
              color: backgroundColorLight),
          label: const Text( 'Delete',
            style: TextStyle(fontSize: 12, color: backgroundColorLight),
          ),
        ),
      ),
    ]);
  }

  @override
  int get rowCount => _sessions.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;

  void _showUsersPopup(String name, int slotTal, int slotEnt, bool isActive, List<String> users, List<dynamic> usersList, List<String> roles, String sessionId) {
    String selectedRoleFilter = 'All';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Users in $name',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Filter by role: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      DropdownButton<String>(
                        value: selectedRoleFilter,
                        items: roles.map((role) {
                          return DropdownMenuItem<String>(
                            value: role,
                            child: Text(role),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedRoleFilter = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(color: Colors.grey),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              const Text('Pending Users:'),
                              SizedBox(
                                width: MediaQuery.sizeOf(context).width,
                                height: MediaQuery.sizeOf(context).height,
                                child: ListView.builder(
                                  itemCount: usersList.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    final user = usersList[index];
                                    if(user['room'] == "0") {
                                      return Card(
                                        elevation: 2,
                                        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                        child: ListTile(
                                          contentPadding: const EdgeInsets.all(16),
                                          leading: const CircleAvatar(
                                            radius: 24,
                                            backgroundColor: Colors.blue,
                                            child: Icon(Icons.person),
                                          ),
                                          title: Text(
                                            user['name'],
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          subtitle: Text(user['role']),
                                          trailing: const Icon(
                                            Icons.arrow_forward,
                                            color: Colors.grey,
                                          ),
                                          onTap: () {
                                            showDialog<void>(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: Text('Allow this user to join session $name?'),
                                                  content: Form(
                                                      key: _formKey,
                                                      child: SingleChildScrollView(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            const Text(
                                                              "Assign a room number*",
                                                              style: TextStyle(color: Colors.black54),
                                                            ),
                                                            Padding(
                                                              padding: const EdgeInsets.only(top: 8.0, bottom: 16),
                                                              child: TextFormField(
                                                                controller: room,
                                                                keyboardType: TextInputType.number,
                                                                enabled: user['role'] == 'Talent',
                                                                validator: (value) {

                                                                  RegExp numberPattern = RegExp(r'^(1[0-2]|[1-9])$');

                                                                  if (user['role'] == 'Talent') {
                                                                    if (value!.isEmpty) {
                                                                      return "Please enter a number";
                                                                    }

                                                                    if (!numberPattern.hasMatch(value)) {
                                                                      return 'Please enter a number between 1 and 12';
                                                                    }
                                                                  }
                                                                  return null;
                                                                },
                                                                decoration: const InputDecoration(
                                                                  prefixIcon: Padding(
                                                                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                                                                    child: Icon(Icons.numbers),
                                                                  ),
                                                                  errorStyle: TextStyle(
                                                                    color: chartColor2,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () async {
                                                        if (_formKey.currentState!.validate()) {
                                                          String? eventId = await findEventBySessionId(sessionId);
                                                          List<String> events = List<String>.from(user['events'] ?? []);
                                                          events.add(eventId);

                                                          if (user['role'] == 'Talent') {
                                                            updateUser(user['epicGamesId'], events, [sessionId], room.text, true, user['isAuthorized'], user['enableRoomCreator']);
                                                            slotTal--;
                                                            /*sendEmail(
                                                                toEmail: user['email'],
                                                                toName: user['name'],
                                                                subject: 'Room N°${room.text}',
                                                                htmlContent: htmlSecondContent
                                                            );*/
                                                          } else {
                                                            updateUser(user['epicGamesId'], events, [sessionId], "Entrepreneur", true, user['isAuthorized'], user['enableRoomCreator']);
                                                            slotEnt--;
                                                            /*sendEmail(
                                                                toEmail: user['email'],
                                                                toName: user['name'],
                                                                subject: 'TalentVerse',
                                                                htmlContent: htmlThirdContent
                                                            );*/
                                                          }
                                                          setState(() {
                                                            usersList[index];
                                                            // Update other data as needed
                                                          });
                                                          room .text = "";
                                                          updateSession(name, slotTal, slotEnt, isActive, users, true);

                                                          Navigator.of(context).pop();

                                                          const snackBar = SnackBar(
                                                            content: Text('The user has been accepted'),
                                                          );
                                                          ScaffoldMessenger.of(context).showSnackBar(snackBar);

                                                        }
                                                      },
                                                      child: const Text('Accept'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        deleteUserFromSession(name, user['_id']);
                                                        Navigator.of(context).pop();
                                                        const snackBar = SnackBar(
                                                          content: Text('The user has been rejected'),
                                                        );
                                                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                                      },
                                                      child: const Text('Reject'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context).pop();
                                                      },
                                                      child: const Text('Close'),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      );
                                    }
                                    else {
                                      return Container();
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const VerticalDivider(color: Colors.grey),
                        Expanded(
                          child: Column(
                            children: [
                              const Text('Accepted Users'),
                              SizedBox(
                                width: MediaQuery.sizeOf(context).width,
                                height: MediaQuery.sizeOf(context).height,
                                child: ListView.builder(
                                  itemCount: usersList.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    final user = usersList[index];
                                    if (selectedRoleFilter == 'All' || user['role'] == selectedRoleFilter) {
                                      if(user['room'] != "0") {
                                        return Card(
                                          elevation: 2,
                                          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                          child: ListTile(
                                            contentPadding: const EdgeInsets.all(16),
                                            leading: const CircleAvatar(
                                              radius: 24,
                                              backgroundColor: Colors.blue,
                                              child: Icon(Icons.person),
                                            ),
                                            title: Text(
                                              user['name'],
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            subtitle: Text(user['role']),
                                            trailing: Column(
                                              children: [
                                                const Text("Room",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15
                                                  ),
                                                ),
                                                Text(user['room'],
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                )
                                              ],
                                            ),
                                            onTap: () {
                                              /*final eventId = await findEventBySessionId(sessionId);
                                              final eventdata = await getEventDataById(eventId);
                                              String session1id = eventdata?["sessions"][0];
                                              String session2id = eventdata?["sessions"][1];
                                              int selectedIndex = -1;*/

                                              showDialog<void>(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return AlertDialog(
                                                    title: const Text('Update user'),
                                                    content: Form(
                                                        key: _formKey,
                                                        child: SingleChildScrollView(
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              const Text(
                                                                "New room number*",
                                                                style: TextStyle(color: Colors.black54),
                                                              ),
                                                              Padding(
                                                                padding: const EdgeInsets.only(top: 8.0, bottom: 16),
                                                                child: TextFormField(
                                                                  controller: room,
                                                                  keyboardType: TextInputType.number,
                                                                  enabled: user['role'] == 'Talent',
                                                                  validator: (value) {

                                                                    RegExp numberPattern = RegExp(r'^(1[0-2]|[1-9])$');

                                                                    if (user['role'] == 'Talent') {

                                                                      if (!numberPattern.hasMatch(value!)) {
                                                                        return 'Please enter a number between 1 and 12';
                                                                      }
                                                                    }
                                                                    return null;
                                                                  },
                                                                  decoration: const InputDecoration(
                                                                    prefixIcon: Padding(
                                                                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                                                                      child: Icon(Icons.numbers),
                                                                    ),
                                                                    errorStyle: TextStyle(
                                                                      color: chartColor2,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              const Text(
                                                                "New Session ID",
                                                                style: TextStyle(color: Colors.black54),
                                                              ),
                                                              Padding(
                                                                padding: const EdgeInsets.only(top: 8.0, bottom: 16),
                                                                child: TextFormField(
                                                                  controller: newSessionId,
                                                                  decoration: const InputDecoration(
                                                                    prefixIcon: Padding(
                                                                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                                                                      child: Icon(Icons.numbers),
                                                                    ),
                                                                    errorStyle: TextStyle(
                                                                      color: chartColor2,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () async {
                                                          if (_formKey.currentState!.validate()) {

                                                            List<String> events = (user['events'] as List<dynamic>).cast<String>();
                                                            List<String> sessions = (user['sessions'] as List<dynamic>).cast<String>();

                                                            if (room.text.isNotEmpty) {
                                                              updateUser(user['epicGamesId'], events, sessions, room.text, true, user['isAuthorized'], user['enableRoomCreator']);
                                                            }

                                                            if (newSessionId.text.isNotEmpty) {
                                                              Map<String, dynamic> newSessionData = await getSessionById(newSessionId.text);
                                                              moveUserToAnotherSession(sessionId, newSessionId.text, user['_id']);
                                                              int newSessionSlotTal = newSessionData['slotTal'];
                                                              int newSessionSlotEnt = newSessionData['slotEnt'];

                                                              if (user['role'] == 'Talent') {
                                                                slotTal++;
                                                                newSessionSlotTal--;
                                                              }
                                                              else {
                                                                slotEnt++;
                                                                newSessionSlotEnt--;
                                                              }
                                                              updateSession(name, slotTal, slotEnt, isActive, users, false);
                                                              updateSession(newSessionData['name'], newSessionSlotTal, newSessionSlotEnt, newSessionData['isActive'], newSessionData['users'], false);
                                                            }

                                                            Navigator.of(context).pop();

                                                            newSessionId.text = "";
                                                            room .text = "";

                                                            const snackBar = SnackBar(
                                                              content: Text('The user has been updated'),
                                                            );
                                                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                                          }
                                                        },
                                                        child: const Text('Update'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {

                                                          if (user['role'] == 'Talent') {
                                                            slotTal++;
                                                          } else {
                                                            slotEnt++;
                                                          }
                                                          updateUser(user['epicGamesId'], [], [], "0", false, true, user['enableRoomCreator']);
                                                          deleteUserFromSession(name, user['_id']);
                                                          updateSession(name, slotTal, slotEnt, isActive, users, true);

                                                          Navigator.of(context).pop();
                                                          const snackBar = SnackBar(
                                                            content: Text('The user has been deleted'),
                                                          );
                                                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                                        },
                                                        child: const Text('Delete'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context).pop();
                                                        },
                                                        child: const Text('Close'),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                        );
                                      }
                                    }
                                    return Container();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showMarksPopup(String name, String sessionId, List<dynamic> usersList, List<Session> sessions) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Talents in session $name',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              content: Container(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Users Marks'),
                      FutureBuilder(
                        future: getTalentsWithMarksInSession(sessionId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            List<Map<String, dynamic>> talentsWithMarks = snapshot.data!;

                            return ListView.builder(
                              shrinkWrap: true,
                              itemCount: talentsWithMarks.length,
                              itemBuilder: (context, index) {
                                final talentId = talentsWithMarks[index]['talentId'];
                                final mark = talentsWithMarks[index]['mark'];

                                return ListTile(
                                  title: Text('Talent: $talentId'),
                                  subtitle: Text('Mark: $mark'),
                                );
                              },
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }


}

