import 'package:Netinfo_Metaverse/views/admin/components/admin_provider.dart';
import 'package:Netinfo_Metaverse/views/admin/components/sessions_page.dart';
import 'package:provider/provider.dart';
import 'views/admin/admin_dashboard.dart';
import 'views/admin/admin_login_screen.dart';
import 'package:flutter/material.dart';
import 'views/home_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AdminProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TalentVerse',
      initialRoute: '/home',
      routes: {
        '/home': (context) => const HomeScreen(),
        '/login': (context) => const AdminPage(),
        '/dashboard': (context) => Consumer<AdminProvider>(
          builder: (context, userProvider, _) {
            return userProvider.admin.isLoggedIn ? const AdminDashboard() : const AdminPage();
          },
        ),
        '/sessions': (context) => Consumer<AdminProvider>(
          builder: (context, userProvider, _) {
            return userProvider.admin.isLoggedIn ? const SessionsPage() : const AdminPage();
          },
        ),
      },
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFEEF1F8),
        primarySwatch: Colors.blue,
        fontFamily: "Intel",
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          errorStyle: TextStyle(height: 0),
          border: defaultInputBorder,
          enabledBorder: defaultInputBorder,
          focusedBorder: defaultInputBorder,
          errorBorder: defaultInputBorder,
        ),
      ),
      home:  const HomeScreen(),
    );
  }
}

const defaultInputBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(16)),
  borderSide: BorderSide(
    color: Color(0xFFDEE3F2),
    width: 1,
  ),
);


