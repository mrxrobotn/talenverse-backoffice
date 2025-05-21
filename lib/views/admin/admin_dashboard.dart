import 'package:Netinfo_Metaverse/views/admin/components/rooms_list.dart';
import 'package:flutter/material.dart';
import '../../responsive_layout.dart';
import '/components/appbar.dart';
import '/components/drawer.dart';
import '/views/admin/components/requests_list.dart';
import '/views/admin/components/users_list.dart';
import '/views/admin/components/events_page.dart';
import '/views/admin/components/sessions_page.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  late Widget currentWidget;

  @override
  void initState() {
    super.initState();
    currentWidget = const UsersList();
  }

  void updateContent(Widget widget) {
    setState(() {
      currentWidget = widget;
    });
  }

  Widget buildDashboardLayout({required bool isDesktop}) {
    final drawer = MyDrawer(
      displayRequests: () => updateContent(const RequestsList()),
      displayUsers: () => updateContent(const UsersList()),
      displayEvents: () => updateContent(const EventsPage()),
      displaySessions: () => updateContent(const SessionsPage()),
      displayRooms: () => updateContent(const RoomsList()),
    );

    final content = SingleChildScrollView(child: currentWidget);

    if (isDesktop) {
      return Row(
        children: [
          drawer,
          Expanded(child: content),
        ],
      );
    } else {
      return Scaffold(
        appBar: const PreferredSize(
          preferredSize: Size.fromHeight(80),
          child: MyAppBar(),
        ),
        drawer: drawer,
        body: content,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      child: ResponsiveLayout(
        phone: buildDashboardLayout(isDesktop: false),
        tablet: buildDashboardLayout(isDesktop: false),
        computer: Scaffold(
          body: buildDashboardLayout(isDesktop: true),
        ),
      ),
    );
  }
}
