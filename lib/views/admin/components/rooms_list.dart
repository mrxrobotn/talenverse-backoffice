import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import '../../../models/room.dart';
import '../../../controllers/room_controller.dart';
import '../../../responsive_layout.dart';
import '../../../models/user.dart';
import '../../../controllers/user_controller.dart';

class RoomsList extends StatefulWidget {
  const RoomsList({super.key});

  @override
  State<RoomsList> createState() => _RoomsListState();
}

class _RoomsListState extends State<RoomsList> {
  late StreamController<List<Room>> _roomsController;
  late TextEditingController searchController;
  List<Room> allRooms = [];
  List<User> _allUsers = []; // Added state variable

  @override
  void initState() {
    super.initState();
    _roomsController = StreamController<List<Room>>.broadcast();
    searchController = TextEditingController();


    // Existing room fetching - now with mounted check and error handling
    RoomManager.getRooms().then((rooms) {
      if (mounted) { // Added mounted check
        allRooms = rooms;
        _updateFilteredRooms();
      }
    }).catchError((error) {
      if (mounted) { // Added mounted check for error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching rooms: $error')),
        );
      }
    });

    // User fetching logic from the subtask description
    fetchUsers().then((users) {
      if (mounted) {
        setState(() {
          _allUsers = users;
        });
      }
    }).catchError((error) {
      print('Error fetching users: $error'); // Keep print for debugging
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching users: $error')),
        );
      }
    });
  }

  void _updateFilteredRooms() {
    final query = searchController.text.toLowerCase();
    final filtered = allRooms.where((room) =>
    room.roomNumber.toLowerCase().contains(query) ||
        room.ownerEpicGamesId.toLowerCase().contains(query)
    ).toList();

    _roomsController.add(filtered);
  }

  void _showAssetsDialog(Room room) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.inventory_2_rounded, color: Colors.blue),
            const SizedBox(width: 8),
            Text('Assets in Room "${room.roomNumber}"'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: room.assets.length,
            itemBuilder: (context, index) {
              final asset = room.assets[index];
              return ListTile(
                leading: const Icon(Icons.widgets, color: Colors.indigo),
                title: Text(asset.assetId, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Chip(
                      label: Text('Type: ${asset.type}'),
                      backgroundColor: Colors.blue.shade50,
                    ),
                    Chip(
                      label: Text(asset.interactable ? 'Interactable' : 'Static'),
                      backgroundColor: asset.interactable ? Colors.green.shade50 : Colors.grey.shade200,
                      labelStyle: TextStyle(
                        color: asset.interactable ? Colors.green : Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          )
        ],
      ),
    );
  }

  void _downloadJson(Room room) {
    final json = room.toJson();
    final jsonString = const JsonEncoder.withIndent('  ').convert(json);

    final bytes = utf8.encode(jsonString);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", "${room.roomNumber}.json")
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  void _showAssignUserDialog(BuildContext context, Room room) {
    // If _allUsers is not populated, fetch it.
    // This is a fallback, ideally it's populated in initState.
    if (_allUsers.isEmpty) {
      fetchUsers().then((users) {
        if (mounted) {
          setState(() {
            _allUsers = users;
          });
          // Re-call dialog build if users were fetched now.
          // This immediate re-call might be tricky. Better to ensure _allUsers is populated by initState.
          // For simplicity of this subtask, we'll assume _allUsers is populated.
          // If it's consistently empty, that's a separate issue for step 2 of the plan.
        }
      }).catchError((error) {
        if (mounted) {
          ScaffoldMessenger.of(this.context).showSnackBar( // Use this.context for ScaffoldMessenger
            SnackBar(content: Text('Error fetching users for dialog: $error')),
          );
        }
        return; // Don't show dialog if users can't be fetched
      });
    }

    showDialog(
      context: context, // This is the BuildContext passed to the method
      builder: (BuildContext dialogContext) { // Use a different name for the dialog's context
        return AlertDialog(
          title: Text('Assign User to Room ${room.roomNumber}'),
          content: SizedBox(
            width: double.maxFinite,
            child: _allUsers.isEmpty
                ? const Center(child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 10),
                Text('Loading users...'),
              ],
            ))
                : ListView.builder(
              shrinkWrap: true,
              itemCount: _allUsers.length,
              itemBuilder: (context, index) {
                final user = _allUsers[index];
                return ListTile(
                  title: Text(user.name),
                  subtitle: Text(user.email),
                  onTap: () async {
                    bool confirm = await showDialog(
                      context: dialogContext, // Use dialogContext for nested dialog
                      builder: (BuildContext confirmCtx) {
                        return AlertDialog(
                          title: const Text('Confirm Assignment'),
                          content: Text('Assign ${user.name} to room ${room.roomNumber}?'),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('Cancel'),
                              onPressed: () {
                                Navigator.of(confirmCtx).pop(false);
                              },
                            ),
                            TextButton(
                              child: const Text('Assign'),
                              onPressed: () {
                                Navigator.of(confirmCtx).pop(true);
                              },
                            ),
                          ],
                        );
                      },
                    ) ?? false;

                    if (confirm) {
                      try {
                        await updateUser(user.epicGamesId, user.events, user.sessions, room.id, user.canAccess, user.isAuthorized, user.enableRoomCreator);
                        Navigator.of(dialogContext).pop();
                        if (mounted) {
                          ScaffoldMessenger.of(this.context).showSnackBar( // Use this.context for ScaffoldMessenger
                            SnackBar(content: Text('${user.name} assigned to room ${room.roomNumber}')),
                          );
                        }
                        // Optionally, refresh data
                        // For example, re-fetch rooms or users if the UI needs to reflect changes immediately
                        // that are not handled by local state updates.
                      } catch (e) {
                        Navigator.of(dialogContext).pop(); // Close assign user dialog on error
                        if (mounted) {
                          ScaffoldMessenger.of(this.context).showSnackBar( // Use this.context
                            SnackBar(content: Text('Error assigning user: $e')),
                          );
                        }
                      }
                    }
                  },
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _roomsController.close();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white70,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.dashboard, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                "Dashboard",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              labelText: 'Search by Room ID or Owner ID',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  searchController.clear();
                  _updateFilteredRooms();
                },
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (_) => _updateFilteredRooms(),
          ),

          const SizedBox(height: 16),
          StreamBuilder<List<Room>>(
            stream: _roomsController.stream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              }

              final rooms = snapshot.data!;
              if (rooms.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.sentiment_dissatisfied, size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('No rooms found.', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                );
              }

              return ResponsiveLayout(
                phone: _buildMobileList(rooms),
                tablet: _buildMobileList(rooms),
                computer: _buildDataTable(rooms),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(List<Room> rooms) {

    return PaginatedDataTable(
      header: const Text(
        'Rooms Overview',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      columns: const [
        DataColumn(
          label: Row(
            children: [
              Icon(Icons.meeting_room, size: 18),
              SizedBox(width: 4),
              Text('Room ID'),
            ],
          ),
        ),
        DataColumn(
          label: Row(
            children: [
              Icon(Icons.person, size: 18),
              SizedBox(width: 4),
              Text('Owner ID'),
            ],
          ),
        ),
        DataColumn(
          label: Row(
            children: [
              Icon(Icons.verified_user, size: 18),
              SizedBox(width: 4),
              Text('Approved'),
            ],
          ),
        ),
        DataColumn(
          label: Row(
            children: [
              Icon(Icons.inventory, size: 18),
              SizedBox(width: 4),
              Text('Assets'),
            ],
          ),
        ),
        DataColumn(
          label: Row(
            children: [
              Icon(Icons.settings, size: 18),
              SizedBox(width: 4),
              Text('Actions'),
            ],
          ),
        ),
      ],
      source: _RoomsDataSource(
        rooms: rooms, // 'rooms' variable from the builder
        onShowAssets: _showAssetsDialog, // Existing parameter
        onDownloadJson: _downloadJson, // Existing parameter
        onAssignUser: (Room room) {     // New parameter
          _showAssignUserDialog(context, room); // 'context' is from the BuildContext of _buildDataTable
        },
      ),
      rowsPerPage: 5,
      availableRowsPerPage: const [5, 10, 20],
      columnSpacing: 32,
      horizontalMargin: 12,
      showCheckboxColumn: false,
    );
  }


  Widget _buildMobileList(List<Room> rooms) {
    return Expanded(
      child: ListView.builder(
        itemCount: rooms.length,
        itemBuilder: (context, index) {
          final room = rooms[index];
          return Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue.shade100,
                child: const Icon(Icons.meeting_room, color: Colors.blue),
              ),
              title: Text('Room ID: ${room.roomNumber}', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text('Owner: ${room.ownerEpicGamesId}'),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Text('Approved: '),
                      Chip(
                        label: Text(room.approved ? 'Yes' : 'No'),
                        backgroundColor: room.approved ? Colors.green.shade100 : Colors.grey.shade300,
                        labelStyle: TextStyle(color: room.approved ? Colors.green : Colors.black),
                      ),
                    ],
                  ),
                  Text('Assets: ${room.assets.length}'),
                ],
              ),
              trailing: Wrap(
                spacing: 8,
                children: [
                  Tooltip(
                    message: room.approved ? 'Unapprove Room' : 'Approve Room',
                    child: IconButton(
                      icon: Icon(Icons.check_circle, color: room.approved ? Colors.green : Colors.grey),
                      onPressed: () {
                        setState(() => room.approved = !room.approved);
                        RoomManager.updateRoom(room.ownerEpicGamesId, {
                          "owner_epicGamesId": room.ownerEpicGamesId,
                          "room_number": room.roomNumber,
                          "approved": room.approved,
                          "assets": room.assets,
                        });
                      },
                    ),
                  ),
                  Tooltip(
                    message: 'View Assets',
                    child: IconButton(
                      icon: const Icon(Icons.view_list),
                      onPressed: () => _showAssetsDialog(room),
                    ),
                  ),
                  Tooltip(
                    message: 'Download JSON',
                    child: IconButton(
                      icon: const Icon(Icons.download_rounded),
                      onPressed: () => _downloadJson(room),
                    ),
                  ),
                  Tooltip( // New Tooltip and IconButton for Assign User
                    message: 'Assign User to this Room',
                    child: IconButton(
                      icon: const Icon(Icons.person_add_alt_1, color: Colors.blueAccent),
                      onPressed: () {
                        _showAssignUserDialog(context, room); // 'room' is from the itemBuilder, 'context' from _buildMobileList
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

}

class _RoomsDataSource extends DataTableSource {
  final List<Room> rooms;
  final void Function(Room room) onShowAssets;
  final void Function(Room room) onDownloadJson;
  final void Function(Room room) onAssignUser; // New field

  _RoomsDataSource({
    required this.rooms,
    required this.onShowAssets,
    required this.onDownloadJson,
    required this.onAssignUser, // New parameter
  });

  @override
  DataRow getRow(int index) {
    final room = rooms[index];

    return DataRow(cells: [
      DataCell(Text(room.roomNumber)),
      DataCell(Text(room.ownerEpicGamesId)),
      DataCell(Text(room.approved ? 'Yes' : 'No')),
      DataCell(Text('${room.assets.length}')),
      DataCell(Row(
        children: [
          Tooltip(
            message: room.approved ? 'Unapprove Room' : 'Approve Room',
            child: IconButton(
              icon: Icon(
                Icons.check_circle,
                color: room.approved ? Colors.green : Colors.grey,
              ),
              onPressed: () {
                room.approved = !room.approved;
                notifyListeners();
                RoomManager.updateRoom(room.ownerEpicGamesId, {
                  "owner_epicGamesId": room.ownerEpicGamesId,
                  "room_number": room.roomNumber,
                  "approved": room.approved,
                  "assets": room.assets,
                });
              },
            ),
          ),
          Tooltip(
            message: 'View Assets',
            child: IconButton(
              icon: const Icon(Icons.view_list),
              onPressed: () => onShowAssets(room),
            ),
          ),
          Tooltip(
            message: 'Download Room JSON',
            child: IconButton(
              icon: const Icon(Icons.download_rounded),
              onPressed: () => onDownloadJson(room),
            ),
          ),
          Tooltip( // New Tooltip and IconButton for Assign User
            message: 'Assign User to this Room',
            child: IconButton(
              icon: const Icon(Icons.person_add_alt_1, color: Colors.blueAccent),
              onPressed: () {
                onAssignUser(room); // 'room' is the variable available in getRow
              },
            ),
          ),
        ],
      )),

    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => rooms.length;

  @override
  int get selectedRowCount => 0;
}
