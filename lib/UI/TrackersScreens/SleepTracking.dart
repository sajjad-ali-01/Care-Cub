import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'SleepChartScreen.dart'; // Import the new screen

class SleepTrackerScreen extends StatefulWidget {
  @override
  _SleepTrackerScreenState createState() => _SleepTrackerScreenState();
}

class _SleepTrackerScreenState extends State<SleepTrackerScreen> {
  DateTime? startTime;
  DateTime? endTime;
  List<Map<String, DateTime>> sleepData = []; // Store sleep records

  Future<void> pickDateTime(bool isStartTime) async {
    DateTime now = DateTime.now();
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate == null) return;

    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime == null) return;

    DateTime selectedDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    setState(() {
      if (isStartTime) {
        startTime = selectedDateTime;
      } else {
        endTime = selectedDateTime;
      }
    });
  }

  void saveRoutine() {
    if (startTime != null && endTime != null) {
      setState(() {
        sleepData.add({"start": startTime!, "end": endTime!});
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Routine saved successfully!")),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SleepChartScreen(sleepData: sleepData),
        ),
      );
    }
  }

  String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return "Pick Time";
    return "${TimeOfDay.fromDateTime(dateTime).format(context)}\n${dateTime.day} ${_monthName(dateTime.month)}";
  }

  String _monthName(int month) {
    const months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFD6),
      body: Column(
        children: [
          SizedBox(height: 50),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.arrow_back, color: Colors.black),
                ),
                Text(
                  "Sleep Tracker",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                Icon(Icons.nightlight_round, color: Colors.black),
              ],
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text("Start", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  GestureDetector(
                    onTap: () => pickDateTime(true),
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.black),
                      ),
                      child: Text(
                        formatDateTime(startTime),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Text("End", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  GestureDetector(
                    onTap: () => pickDateTime(false),
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.black),
                      ),
                      child: Text(
                        formatDateTime(endTime),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: saveRoutine,
            style: ElevatedButton.styleFrom(
              primary: Color(0xFF4A148C),
              padding: EdgeInsets.symmetric(horizontal: 60, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: Text("Save Routine", style: TextStyle(color: Colors.white, fontSize: 18)),
          ),
        ],
      ),
    );
  }
}
