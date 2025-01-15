import 'dart:async';
import 'package:flutter/material.dart';

class SleepTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sleep Tracker',
      debugShowCheckedModeBanner: false,
      home: SleepTrackerScreen(),
    );
  }
}

class SleepTrackerScreen extends StatefulWidget {
  @override
  _SleepTrackerScreenState createState() => _SleepTrackerScreenState();
}

class _SleepTrackerScreenState extends State<SleepTrackerScreen> {
  DateTime? startTime;
  DateTime? endTime;
  Duration sleepDuration = Duration.zero;
  bool isTimerRunning = false;
  Timer? timer;

  void startTimer() {
    if (!isTimerRunning) {
      setState(() {
        isTimerRunning = true;
        startTime = DateTime.now();
        endTime = null; // Clear end time when restarting
      });

      timer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          if (startTime != null) {
            sleepDuration = DateTime.now().difference(startTime!);
          }
        });
      });
    }
  }

  void stopTimer() {
    if (isTimerRunning) {
      setState(() {
        isTimerRunning = false;
        endTime = DateTime.now();
      });
      timer?.cancel();
    }
  }

  void resetTimer() {
    setState(() {
      startTime = null;
      endTime = null;
      sleepDuration = Duration.zero;
      isTimerRunning = false;
    });
    timer?.cancel();
  }

  String formatDuration(Duration duration) {
    return "${duration.inHours.toString().padLeft(2, '0')}h ${duration.inMinutes.remainder(60).toString().padLeft(2, '0')}m ${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}s";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFD6), // Light background color
      body: Column(
        children: [
          SizedBox(height: 50),
          // Title Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.arrow_back, color: Colors.black),
                ),
                Text(
                  "Sleep",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Icon(Icons.nightlight_round, color: Colors.black),
              ],
            ),
          ),
          SizedBox(height: 20),
          // Start and End Time Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(
                    "Start",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    startTime != null
                        ? "${TimeOfDay.fromDateTime(startTime!).format(context)}\n${startTime!.day} ${_monthName(startTime!.month)}"
                        : "Pick Start",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    "End",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    endTime != null
                        ? "${TimeOfDay.fromDateTime(endTime!).format(context)}\n${endTime!.day} ${_monthName(endTime!.month)}"
                        : "Pick End",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 20),
          // Timer Display
          Container(
            height: 250,
            width: 250,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                formatDuration(sleepDuration),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          // Start, Stop, and Reset Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: resetTimer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: CircleBorder(),
                  padding: EdgeInsets.all(20),
                ),
                child: Icon(Icons.refresh, color: Colors.orange),
              ),
              ElevatedButton(
                onPressed: isTimerRunning ? stopTimer : startTimer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: CircleBorder(),
                  padding: EdgeInsets.all(20),
                ),
                child: Icon(
                  isTimerRunning ? Icons.stop : Icons.play_arrow,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          // Save Routine Button
          ElevatedButton.icon(
            onPressed: () {
              if (sleepDuration.inSeconds > 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Routine saved successfully!")),
                );
              }
            },
            icon: Icon(Icons.check, color: Colors.white),
            label: Text("Save routine"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFB8A27D), // Matches the background
              padding: EdgeInsets.symmetric(horizontal: 60, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    return months[month - 1];
  }
}
