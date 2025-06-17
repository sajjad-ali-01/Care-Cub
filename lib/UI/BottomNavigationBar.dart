import 'package:carecub/UI/Community/Community.dart';
import 'package:carecub/UI/Home.dart';
import 'package:flutter/material.dart';
import 'CryTranslation/cryUI.dart';
import 'Nutrition Guide/SelectDate.dart';
import 'TrakingsScreens/TrackersList.dart';

class Tabs extends StatefulWidget {
  const Tabs({super.key});

  @override
  State<Tabs> createState() => _TabsState();
}

class _TabsState extends State<Tabs> {
  int currentIndex = 0;

  final List<Widget> body = [
    Home(),
    CryCaptureScreen(),
    AgeSelectionScreen(),
    CommunityHomePage(),
    TrackersList(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: body[currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFFFFE3EC),
        currentIndex: currentIndex,
        selectedItemColor: Colors.deepOrange,
        unselectedItemColor: Colors.grey.shade700,
        onTap: (int newIndex) {
          setState(() {
            currentIndex = newIndex;
          });
        },
        items: const [
          BottomNavigationBarItem(
            label: "Home",
            icon: Icon(Icons.home),
          ),
          BottomNavigationBarItem(
            label: "Cry AI",
            icon: Icon(Icons.mic),
          ),
          BottomNavigationBarItem(
            label: "Nutrition AI",
            icon: Icon(Icons.apple),
          ),
          BottomNavigationBarItem(
            label: "Community",
            icon: Icon(Icons.comment),
          ),
          BottomNavigationBarItem(
            label: "Trackers",
            icon: Icon(Icons.format_list_numbered_rtl_outlined),
          ),
        ],
      ),
    );
  }
}
