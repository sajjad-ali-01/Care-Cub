import 'package:flutter/material.dart';
import 'dashboard_page.dart';
import 'appointments_page.dart';
import 'history_page.dart';
import 'profile_page.dart';

void main() {
  runApp(DaycareApp());
}

class DaycareApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Daycare Center',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  List<Map<String, String>> approvedAppointments = [];

  void updateApprovedAppointments(Map<String, String> appointment) {
    setState(() {
      approvedAppointments.add(appointment);
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      DashboardPage(),
      AppointmentsPage(onApprove: updateApprovedAppointments), // ✅ Pass function
      HistoryPage(approvedAppointments: approvedAppointments), // ✅ Pass approved list
      ProfilePage(),
    ];

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Appointments"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
