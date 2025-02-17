import 'dart:async';
import 'package:flutter/material.dart';

class FeedingTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Feeding Tracker',
      debugShowCheckedModeBanner: false,
      home: FeedingTrackerScreen(),
    );
  }
}

class FeedingTrackerScreen extends StatefulWidget {
  @override
  _FeedingTrackerScreenState createState() => _FeedingTrackerScreenState();
}

class _FeedingTrackerScreenState extends State<FeedingTrackerScreen> {
  Duration leftDuration = Duration.zero;
  Duration rightDuration = Duration.zero;
  bool isLeftTimerRunning = false;
  bool isRightTimerRunning = false;
  Timer? leftTimer;
  Timer? rightTimer;

  String formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "0h$minutes:$seconds";
  }

  void startLeftTimer() {
    if (!isLeftTimerRunning) {
      setState(() {
        isLeftTimerRunning = true;
      });

      leftTimer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          leftDuration += Duration(seconds: 1);
        });
      });
    }
  }

  void stopLeftTimer() {
    if (isLeftTimerRunning) {
      setState(() {
        isLeftTimerRunning = false;
      });
      leftTimer?.cancel();
    }
  }

  void startRightTimer() {
    if (!isRightTimerRunning) {
      setState(() {
        isRightTimerRunning = true;
      });

      rightTimer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          rightDuration += Duration(seconds: 1);
        });
      });
    }
  }

  void stopRightTimer() {
    if (isRightTimerRunning) {
      setState(() {
        isRightTimerRunning = false;
      });
      rightTimer?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    String time = TimeOfDay.now().format(context);
    String date = "${DateTime.now().day} Jan";

    return Scaffold(
      backgroundColor: Color(0xFFB3E5FC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xFFB3E5FC),
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            Spacer(),
            Text(
              "Feeding",
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Spacer(),
            Icon(Icons.local_dining, color: Colors.black),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () {
                  stopRightTimer();
                  isLeftTimerRunning ? stopLeftTimer() : startLeftTimer();
                },
                child: Column(
                  children: [
                    Text(
                      "Left",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      formatDuration(leftDuration),
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xFFFFAB91),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Text(
                        isLeftTimerRunning ? "Stop" : "Start",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  stopLeftTimer();
                  isRightTimerRunning ? stopRightTimer() : startRightTimer();
                },
                child: Column(
                  children: [
                    Text(
                      "Right",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      formatDuration(rightDuration),
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xFFFFAB91),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Text(
                        isRightTimerRunning ? "Stop" : "Start",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Save routine logic
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF4A148C),
              padding: EdgeInsets.symmetric(horizontal: 60, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              "Save routine",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}
