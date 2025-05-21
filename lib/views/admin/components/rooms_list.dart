import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import '../../../models/room.dart';
import '../../../controllers/room_controller.dart';
import '../../../responsive_layout.dart';

class RoomsList extends StatefulWidget {
  const RoomsList({super.key});

  @override
  State<RoomsList> createState() => _RoomsListState();
}

class _RoomsListState extends State<RoomsList> {
  late StreamController<List<Room>> _roomsController;
  late TextEditingController searchController;
  List<Room> allRooms = [];

  @override
  void initState() {
    super.initState();
    _roomsController = StreamController<List<Room>>.broadcast();
    searchController = TextEditingController();


    RoomManager.getRooms().then((rooms) {
      allRooms = rooms;
      _updateFilteredRooms();
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
        rooms: rooms,
        onShowAssets: _showAssetsDialog,
        onDownloadJson: _downloadJson,
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
                        RoomManager.updateRoom(room.roomNumber, {
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

  _RoomsDataSource({
    required this.rooms,
    required this.onShowAssets,
    required this.onDownloadJson,
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
                RoomManager.updateRoom(room.roomNumber, {
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
