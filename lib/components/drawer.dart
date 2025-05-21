import 'package:Netinfo_Metaverse/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/user_controller.dart';
import '../models/user.dart';
import '../views/admin/components/admin_provider.dart';

class MyDrawer extends StatefulWidget {
  final VoidCallback displayRequests;
  final VoidCallback displayUsers;
  final VoidCallback displayEvents;
  final VoidCallback displaySessions;
  final VoidCallback displayRooms;

  const MyDrawer({
    Key? key,
    required this.displayRequests,
    required this.displayUsers,
    required this.displayEvents,
    required this.displaySessions,
    required this.displayRooms,
  }) : super(key: key);

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  late Future<List<User>> users;

  @override
  void initState() {
    super.initState();
    users = fetchUsersSafely();
  }

  Future<List<User>> fetchUsersSafely() async {
    try {
      return await fetchUsers();
    } catch (e) {
      debugPrint('Error fetching users: $e');
      return [];
    }
  }

  void _handleLogout() {
    Future.delayed(const Duration(seconds: 1), () {
      Provider.of<AdminProvider>(context, listen: false).logout(context);
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: backgroundColorLight),
      title: Text(title, style: const TextStyle(color: backgroundColorLight)),
      onTap: onTap,
      trailing: trailing,
    );
  }

  Widget _buildRequestsTile(List<User> users) {
    final int requestCount = users.where((user) => !user.isAuthorized).length;

    return _buildListTile(
      icon: Icons.people,
      title: 'Requests',
      onTap: widget.displayRequests,
      trailing: requestCount > 0
          ? Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(6),
              ),
              constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
              child: Text(
                requestCount.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 10),
                textAlign: TextAlign.center,
              ),
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: backgroundColorDark,
        child: ListView(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: backgroundColorDark),
              child: UserAccountsDrawerHeader(
                decoration: const BoxDecoration(color: Colors.transparent),
                accountName:
                    const Text("Welcome Admin", style: TextStyle(fontSize: 18)),
                accountEmail: const Text('production@dall4all.org'),
                currentAccountPicture:
                    Image.asset("assets/Backgrounds/logo_metaverse.png"),
                currentAccountPictureSize: const Size.square(60),
              ),
            ),
            const SizedBox(height: 40),
            _buildListTile(
              icon: Icons.home,
              title: 'Home',
              onTap: widget.displayUsers,
            ),
            FutureBuilder<List<User>>(
              future: users,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const ListTile(
                    title: Text('Loading requests...',
                        style: TextStyle(color: Colors.grey)),
                    leading: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return const ListTile(
                    title: Text('Error loading requests',
                        style: TextStyle(color: Colors.red)),
                    leading: Icon(Icons.error, color: Colors.red),
                  );
                } else {
                  return _buildRequestsTile(snapshot.data ?? []);
                }
              },
            ),
            _buildListTile(
              icon: Icons.event,
              title: 'Events',
              onTap: widget.displayEvents,
            ),
            _buildListTile(
              icon: Icons.event_note_outlined,
              title: 'Sessions',
              onTap: widget.displaySessions,
            ),
            _buildListTile(
              icon: Icons.room_preferences_outlined,
              title: 'Rooms',
              onTap: widget.displayRooms,
            ),
            _buildListTile(
              icon: Icons.logout,
              title: 'Logout',
              onTap: _handleLogout,
            ),
          ],
        ),
      ),
    );
  }
}
