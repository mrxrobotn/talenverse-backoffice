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

  const MyDrawer({
    Key? key,
    required this.displayRequests,
    required this.displayUsers,
    required this.displayEvents,
    required this.displaySessions,
  }) : super(key: key);

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  late Future<List<User>> users;

  @override
  void initState() {
    super.initState();
    users = fetchData();
  }

  Future<List<User>> fetchData() async {
    try {
      return await fetchUsers();
    } catch (error) {
      // Handle errors appropriately
      print('Error fetching data: $error');
      rethrow;
    }
  }

  void _handleLogout() {
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pushReplacementNamed(context, '/login');
      Provider.of<AdminProvider>(context, listen: false).logout(context);
    });
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
                accountName: const Text(
                  "Welcome Admin",
                  style: TextStyle(fontSize: 18),
                ),
                accountEmail: const Text('production@dall4all.org'),
                currentAccountPictureSize: const Size.square(60),
                currentAccountPicture: Image.asset("assets/Backgrounds/logo_metaverse.png"),
              ),
            ),
            const SizedBox(height: 40),
            ListTile(
              leading: const Icon(Icons.home, color: backgroundColorLight),
              title: const Text(' Home ' ,style: TextStyle(color: backgroundColorLight)),
              onTap: widget.displayUsers,
            ),
            FutureBuilder<List<User>>(
              future: users,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Error or No users found.'));
                }

                List<User> usersWithoutAccess = snapshot.data!.where((user) => !user.isAuthorized).toList();

                return ListTile(
                  leading: const Icon(Icons.people, color: backgroundColorLight),
                  title: const Text(' Requests ',style: TextStyle(color: backgroundColorLight)),
                  onTap: widget.displayRequests,
                  trailing: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Text(
                      usersWithoutAccess.length.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.event, color: backgroundColorLight),
              title: const Text(' Events ' ,style: TextStyle(color: backgroundColorLight)),
              onTap: widget.displayEvents,
            ),
            ListTile(
              leading: const Icon(Icons.event, color: backgroundColorLight),
              title: const Text(' Sessions ' ,style: TextStyle(color: backgroundColorLight)),
              onTap: widget.displaySessions,
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: backgroundColorLight),
              title: const Text(' Logout ',style: TextStyle(color: backgroundColorLight)),
              onTap: _handleLogout,
            ),
          ],
        ),
      ),
    );
  }
}
