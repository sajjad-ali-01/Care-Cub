import 'package:carecub/UI/Home.dart';
import 'package:flutter/material.dart';

class Tabs extends StatefulWidget {
  const Tabs({super.key});

  @override
  State<Tabs> createState() => _TabsState();
}

class _TabsState extends State<Tabs> {
  int current_Index = 0;
  List<Widget> body = [
    Home(),
    Icon(Icons.track_changes),
    Icon(Icons.account_circle),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: body[current_Index],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFFFFE3EC),
          currentIndex: current_Index,
          onTap: (int newIndex){
            setState(() {
              current_Index=newIndex;
            });
          },
        items: const [
          BottomNavigationBarItem(
              label: "Home",
            icon: Icon(Icons.home),
          ),
          BottomNavigationBarItem(
            label: "Home",
            icon: Icon(Icons.person_outline),
          ),
          BottomNavigationBarItem(
            label: "Home",
            icon: Icon(Icons.account_circle),
          ),
        ],
      ),
    );
  }
}
