import 'dart:async';
import 'package:Netinfo_Metaverse/controllers/event_controller.dart';
import 'package:Netinfo_Metaverse/views/admin/components/create_event.dart';
import 'package:flutter/material.dart';
import '../../../constants.dart';
import '../../../controllers/session_controller.dart';
import '../../../controllers/user_controller.dart';
import '../../../models/event.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {

  late StreamController<List<Event>> _eventsController;
  late TextEditingController searchController;
  late List<Event> allEvents;

  @override
  void initState() {
    super.initState();
    _eventsController = StreamController<List<Event>>.broadcast();
    searchController = TextEditingController();
    fetchEvents().then((events) {
      allEvents = events;
      _updateEventsList();
    });
  }

  @override
  void dispose() {
    _eventsController.close();
    super.dispose();
  }

  void _updateEventsList() {
    String searchInput = searchController.text.toLowerCase();
    List<Event> activeEvent = allEvents.toList();
    if (searchInput.isNotEmpty) {
      activeEvent = activeEvent.where((session) =>
          session.name.toLowerCase().contains(searchInput) )
          .toList();
    }
    _eventsController.add(activeEvent);
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
                  'Events',
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
                        showDialog<void>(
                          context: context,
                          builder: (BuildContext context) {
                            return const CreateEvent();
                          },
                        );
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
                      label: const Text('Create Event',
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
                    _updateEventsList();
                  },
                ),
              ),
              onChanged: (value) {
                _updateEventsList();
              },
            ),
            const SizedBox(height: 8),
            StreamBuilder<List<Event>>(
              stream: _eventsController.stream,
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text('No events found.')
                  );
                }

                List<Event> activeEvent = snapshot.data!;
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
                                Text('Date', style: TextStyle(fontWeight: FontWeight.bold))
                              ],
                            )
                        ),
                        DataColumn(
                            label: Row(
                              children: [
                                Icon(Icons.event, color: Colors.orange),
                                SizedBox(width: 5),
                                Text('Session 1', style: TextStyle(fontWeight: FontWeight.bold))
                              ],
                            )
                        ),
                        DataColumn(
                            label: Row(
                              children: [
                                Icon(Icons.event, color: Colors.orange),
                                SizedBox(width: 5),
                                Text('Session 2', style: TextStyle(fontWeight: FontWeight.bold))
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
                      source: _DataSource(
                        events: activeEvent.toList(),
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

class _DataSource extends DataTableSource {

  final List<Event> _events;
  final BuildContext context;

  _DataSource({
    required List<Event> events,
    required this.context,
  }) : _events = events;

  @override
  DataRow getRow(int index) {
    final event = _events[index];
    return DataRow(cells: [
      DataCell(Text(event.name)),
      DataCell(Text(event.date)),
      DataCell(
        Row(
          children: [
            const Text('Session1: '),
            TextButton(
              onPressed: () async {
                Map<String, dynamic> session = await getSessionById(event.sessions[0]);
                _showSessionData(session['name'], session['slotTal'], session['slotEnt'], session['isActive']);
              },
              child: Text(event.sessions[0]),
            )
          ],
        ),
      ),
      DataCell(
        Row(
          children: [
            const Text('Session2: '),
            TextButton(
              onPressed: () async {
                Map<String, dynamic> session = await getSessionById(event.sessions[1]);
               _showSessionData(session['name'], session['slotTal'], session['slotEnt'], session['isActive']);
              },
              child: Text(event.sessions[1]),
            )
          ],
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
                  content: const Text('Are you sure you want to delete this event?'),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('Yes'),
                      onPressed: () {
                        Navigator.of(context).pop();
                        const snackBar = SnackBar(
                          content:
                          Text('Event deleted'),
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
  int get rowCount => _events.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;

  void _showSessionData(String name, int slotTal, int slotEnt, bool isActive) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(
                'Session Details',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(color: Colors.grey),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 600,
                    child: Column(
                      children: [
                        Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: const CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.blue,
                              child: Icon(Icons.format_list_bulleted),
                            ),
                            title: const Text(
                              'Name: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              name,
                            ),
                          ),
                        ),
                        Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: const CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.blue,
                              child: Icon(Icons.format_list_bulleted),
                            ),
                            title: const Text(
                              'Talents Slots Available',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              slotTal.toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: const CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.blue,
                              child: Icon(Icons.format_list_bulleted),
                            ),
                            title: const Text(
                              'Entrepreneurs Slots Available',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              slotEnt.toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: const CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.blue,
                              child: Icon(Icons.format_list_bulleted),
                            ),
                            title: const Text(
                              'Is active?',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              isActive.toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
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

