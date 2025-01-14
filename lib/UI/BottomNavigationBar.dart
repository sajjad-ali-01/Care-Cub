import 'package:carecub/UI/Home.dart';
import 'package:flutter/material.dart';

class Tabs extends StatefulWidget {
  const Tabs({super.key});

  @override
  State<Tabs> createState() => _TabsState();
}

class _TabsState extends State<Tabs> {
  int currentIndex = 0;

  // List of pages for navigation
  final List<Widget> body = [
    Home(),
    Icon(Icons.track_changes, size: 100),
    Icon(Icons.account_circle, size: 100),
    Icon(Icons.notifications, size: 100),
    Icon(Icons.settings, size: 100),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: body[currentIndex], // Display the selected page
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Ensures labels are always visible
        backgroundColor: const Color(0xFFFFE3EC), // Light pink
        currentIndex: currentIndex,
        selectedItemColor: Colors.deepOrange, // Highlighted item color
        unselectedItemColor: Colors.grey.shade700, // Non-selected item color
        onTap: (int newIndex) {
          setState(() {
            currentIndex = newIndex; // Update index on tap
          });
        },
        items: const [
          BottomNavigationBarItem(
            label: "Home",
            icon: Icon(Icons.home),
          ),
          BottomNavigationBarItem(
            label: "Tracker",
            icon: Icon(Icons.format_list_numbered_rtl_outlined),
          ),
          BottomNavigationBarItem(
            label: "Nutrition AI",
            icon: Icon(Icons.account_circle),
          ),
          BottomNavigationBarItem(
            label: "Ale",
            icon: Icon(Icons.notifications),
          ),
          BottomNavigationBarItem(
            label: "Settings",
            icon: Icon(Icons.settings),
          ),
        ],
      ),
    );
  }
}
