import 'package:flutter/material.dart';
import 'dashboard_page.dart';
import 'appointments_page.dart';
import 'history_page.dart';
import 'profile_page.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;
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
      AppointmentsPage(onApprove: updateApprovedAppointments),
      HistoryPage(approvedAppointments: approvedAppointments),
      DaycareProfileScreen(),
    ];

    return Scaffold(
      body: _pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        selectedItemColor: Colors.deepOrange,
        unselectedItemColor: Colors.grey.shade700,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFFFFE3EC),
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
