import 'dart:async';
import 'package:Netinfo_Metaverse/controllers/user_controller.dart';
import 'package:Netinfo_Metaverse/models/session.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import '../../../constants.dart';
import '../../../controllers/session_controller.dart';
import 'create_session.dart';

class SessionsPage extends StatefulWidget {
  const SessionsPage({super.key});

  @override
  State<SessionsPage> createState() => _SessionsPageState();
}

class _SessionsPageState extends State<SessionsPage> {

  bool isSignInDialogShown = false;

  late RiveAnimationController _btnAnimationController;

  late StreamController<List<Session>> _sessionsController;
  late TextEditingController searchController;
  late List<Session> allSessions;

  @override
  void initState() {
    super.initState();
    _btnAnimationController = OneShotAnimation("active", autoplay: false);
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
            Row(
              children: [
                const Text(
                  '/',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sessions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        _btnAnimationController.isActive = true;
                        Future.delayed(const Duration(milliseconds: 500), () {
                          setState(() {
                            isSignInDialogShown = true;
                          });
                          CreateSession(context, onClosed: (_) {
                            setState(() {
                              isSignInDialogShown = false;
                            });
                          });
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: backgroundColorDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      icon: const Icon(
                          Icons.add,
                          color: backgroundColorLight),
                      label: const Text('Create Session',
                        style: TextStyle(fontSize: 12, color: backgroundColorLight),
                      ),
                    ),
                  ],
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
                                Icon(Icons.date_range, color: Colors.purple),
                                SizedBox(width: 5),
                                Text('Date', style: TextStyle(fontWeight: FontWeight.bold))
                              ],
                            )
                        ),
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

  @override
  DataRow getRow(int index) {
    final session = _sessions[index];
    return DataRow(cells: [
      DataCell(Text(session.name)),
      DataCell(Text(session.date)),
      DataCell(Text('${session.slotTal.toString()} / 12')),
      DataCell(Text('${session.slotEnt.toString()} / 8')),
      DataCell(TextButton(
        onPressed: () async {
          List<dynamic> usersList = await getUsersInSession(session.name);
          _showUsersPopup(session.name, session.date, session.slotTal, session.slotEnt, session.isActive, session.users, usersList, rolesFilter);
        },
        child: const Text('Show users'),)),
      DataCell(
        Row(
          children: [
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
                            updateSession(session.name, session.date, session.slotTal, session.slotEnt, !session.isActive, session.users, false);
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
          ],
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

  void _showUsersPopup(String name, String date, int slotTal, int slotEnt, bool isActive, List<Map<String, dynamic>> users, List<dynamic> usersList, List<String> roles) {
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
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(color: Colors.grey),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 600,
                    height: 500,
                    child: ListView.builder(
                      itemCount: usersList.length,
                      itemBuilder: (BuildContext context, int index) {
                        final user = usersList[index];
                        if (selectedRoleFilter == 'All' || user['role'] == selectedRoleFilter) {
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
                                user['userId'],
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
                                      title: const Text('Confirmation'),
                                      content: Text('Allow this user to join $name?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            updateUserAccess(user['userId'], true, true);
                                            Navigator.of(context).pop();
                                            const snackBar = SnackBar(
                                              content: Text('The user has been accepted'),
                                            );
                                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                          },
                                          child: const Text('Accept'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            if (user['role'] == 'Talent') {
                                              slotTal++;
                                            } else {
                                              slotEnt++;
                                            }
                                            deleteUserFromSession(name, user['userId'], slotTal, slotEnt);
                                            Navigator.of(context).pop();
                                            const snackBar = SnackBar(
                                              content: Text('The user has been rejected'),
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
                        } else {
                          return Container();
                        }
                      },
                    ),
                  ),
                ],
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

