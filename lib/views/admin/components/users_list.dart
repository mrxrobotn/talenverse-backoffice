import 'dart:async';
import 'package:Netinfo_Metaverse/responsive_layout.dart';
import 'package:Netinfo_Metaverse/views/admin/components/stats_card.dart';
import 'package:flutter/material.dart';
import '../../../constants.dart';
import '../../../controllers/user_controller.dart';
import '../../../models/user.dart';

class UsersList extends StatefulWidget {
  const UsersList({super.key});

  @override
  _UsersListState createState() => _UsersListState();
}

class _UsersListState extends State<UsersList> {
  late StreamController<List<User>> _usersController;
  late TextEditingController searchController;
  late List<User> allUsers;

  List<String> rolesFilter = ['All', 'Entrepreneur', 'Talent', 'Visitor'];
  String selectedRoleFilter = 'All';

  @override
  void initState() {
    super.initState();
    _usersController = StreamController<List<User>>.broadcast();
    searchController = TextEditingController();
    fetchUsers().then((users) {
      allUsers = users;
      _updateUsersList();
    });
  }

  @override
  void dispose() {
    _usersController.close();
    super.dispose();
  }

  void _updateUsersList() {
    String searchInput = searchController.text.toLowerCase();
    List<User> usersWithAccess =
        allUsers.where((user) => user.isAuthorized).toList();
    if (searchInput.isNotEmpty) {
      usersWithAccess = usersWithAccess
          .where((user) =>
              user.name.toLowerCase().contains(searchInput) ||
              user.email.toLowerCase().contains(searchInput) ||
              user.epicGamesId.toLowerCase().contains(searchInput))
          .toList();
    }
    _usersController.add(usersWithAccess);
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
                  'Dashboard',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const StatsCard(),
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search by ID, Name or Email',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    _updateUsersList();
                  },
                ),
              ),
              onChanged: (value) {
                _updateUsersList();
              },
            ),
            StreamBuilder<List<User>>(
              stream: _usersController.stream,
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text('No users found.')
                  );
                }
                return ResponsiveLayout(
                  tiny: _buildMobileView(snapshot.data!),
                  phone: _buildMobileView(snapshot.data!),
                  tablet: _buildMobileView(snapshot.data!),
                  largeTablet: _buildLaptopView(snapshot.data!),
                  computer: _buildLaptopView(snapshot.data!),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLaptopView(List<User> usersWithAccess) {
    return SizedBox(
      width: double.infinity,
      child: PaginatedDataTable(
        header: Row(
          children: [
            const Text('Filter by Role: '),
            DropdownButton<String>(
              value: selectedRoleFilter,
              items: rolesFilter.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedRoleFilter = newValue!;
                });
              },
            ),
          ],
        ),
        columnSpacing: 56,
        horizontalMargin: 20.0,
        rowsPerPage: 12,
        availableRowsPerPage: const [5, 10, 20],
        onPageChanged: (pageIndex) {
          print('Page changed to $pageIndex');
        },
        columns: const [
          DataColumn(
              label: Row(
            children: [
              Icon(Icons.gamepad, color: Colors.green),
              SizedBox(width: 5),
              Text('Epic Games ID',
                  style: TextStyle(fontWeight: FontWeight.bold))
            ],
          )),
          DataColumn(
            label: Row(
              children: [
                Icon(Icons.person),
                SizedBox(width: 5),
                Text('Name', style: TextStyle(fontWeight: FontWeight.bold))
              ],
            )
          ),
          DataColumn(
            label: Row(
              children: [
                Icon(Icons.email, color: Colors.orange),
                SizedBox(width: 5),
                Text('Email', style: TextStyle(fontWeight: FontWeight.bold))
              ],
            )
          ),
          DataColumn(
              label: Row(
            children: [
              Icon(Icons.security, color: Colors.purple),
              SizedBox(width: 5),
              Text('Role', style: TextStyle(fontWeight: FontWeight.bold))
            ],
          )),
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
          users: usersWithAccess
              .where((user) =>
                  selectedRoleFilter == 'All' ||
                  user.role == selectedRoleFilter)
              .toList(),
          context: context,
          onUserRoleChanged: (user) {
            setState(() {
              print('User role changed: ${user.role}');
            });
          },
        ),
      ),
    );
  }

  Widget _buildMobileView(List<User> usersWithAccess) {
    return SingleChildScrollView(
      child: SizedBox(
        height: double.maxFinite,
        child: ListView.builder(
          itemCount: usersWithAccess.length,
          itemBuilder: (context, index) {
            User user = usersWithAccess[index];
            return Card(
              elevation: 3,
              child: ExpansionTile(
                title: ListTile(
                  leading: const Icon(Icons.person, color: Colors.blue),
                  title: Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                children: [
                  ListTile(
                    leading: const Icon(Icons.gamepad, color: Colors.green),
                    title: Text(
                      'Epic Games ID: ${user.epicGamesId}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.email, color: Colors.orange),
                    title: Text(
                      'Email: ${user.email}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.security, color: Colors.purple),
                    title: Row(
                      children: [
                        const Text('Role:', style: TextStyle(fontSize: 16)),
                        const SizedBox(
                            width: 10), // Add spacing between text and dropdown
                        DropdownButton<String>(
                          value: user.role,
                          items: roles.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              user.role = newValue!;
                              updateUserRole(user.epicGamesId, user.role);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    title: ElevatedButton.icon(
                      onPressed: () {
                        showDialog<void>(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Confirmation'),
                              content: Text(user.canAccess
                                  ? 'Are you sure you want to revoke access for the user ${user.name}?'
                                  : 'Are you sure you want to give access for the user ${user.name}?'),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('Yes'),
                                  onPressed: () {
                                    updateUserAccess(user.epicGamesId,
                                        !user.canAccess, user.isAuthorized);
                                    Navigator.of(context).pop();
                                    const snackBar = SnackBar(
                                      content: Text(
                                          'Permission has been revoked with success'),
                                    );
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackBar);
                                    Navigator.pushNamed(context, '/dashboard');
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
                        backgroundColor:
                            user.canAccess ? chartColor2 : chartColor1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      icon: Icon(
                          user.canAccess ? Icons.lock_outline : Icons.lock_open_outlined,
                          color: backgroundColorLight),
                      label: Text(
                        user.canAccess ? 'Revoke Access' : 'Grant Access',
                        style: const TextStyle(
                            fontSize: 12, color: backgroundColorLight),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _UsersDataSource extends DataTableSource {
  final List<User> _users;
  final BuildContext context;
  final Function(User) onUserRoleChanged;

  _UsersDataSource({
    required List<User> users,
    required this.context,
    required this.onUserRoleChanged,
  }) : _users = users;

  @override
  DataRow getRow(int index) {
    final user = _users[index];
    return DataRow(cells: [
      DataCell(Text(user.epicGamesId)),
      DataCell(Text(user.name)),
      DataCell(Text(user.email)),
      DataCell(
        DropdownButton<String>(
          value: user.role,
          items: roles.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            user.role = newValue!;
            onUserRoleChanged(user);
            updateUserRole(user.epicGamesId, user.role);
          },
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
                  content: Text(user.canAccess
                      ? 'Are you sure you want to revoke access for the user ${user.name}?'
                      : 'Are you sure you want to give access for the user ${user.name}?'),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('Yes'),
                      onPressed: () {
                        updateUserAccess(user.epicGamesId, !user.canAccess,
                            user.isAuthorized);
                        Navigator.of(context).pop();
                        const snackBar = SnackBar(
                          content:
                              Text('Permission has been changed with success'),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        Navigator.pushNamed(context, '/dashboard');
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
            backgroundColor: user.canAccess ? chartColor2 : chartColor1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          icon: Icon(
              user.canAccess ? Icons.lock_outline : Icons.lock_open_outlined,
              color: backgroundColorLight),
          label: Text(
            user.canAccess ? 'Revoke Access' : 'Grant Access',
            style: const TextStyle(fontSize: 12, color: backgroundColorLight),
          ),
        ),
      ),
    ]);
  }

  @override
  int get rowCount => _users.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
