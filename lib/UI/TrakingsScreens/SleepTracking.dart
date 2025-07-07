import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SleepTrackerScreen extends StatefulWidget {
  @override
  _SleepTrackerScreenState createState() => _SleepTrackerScreenState();
}

class _SleepTrackerScreenState extends State<SleepTrackerScreen> {
  DateTime? startTime;
  DateTime? endTime;
  List<Map<String, DateTime>> sleepData = [];
  String childAge = "0 weeks";


  @override
  void initState() {
    super.initState();

    fetchChildAge();
    fetchSleepData();
  }


  Future<void> fetchChildAge() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('babyProfiles')
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        final dob = data['dateOfBirth']?.toDate();

        if (dob != null) {
          setState(() {
            childAge = _calculateAge(dob);
          });
        }
      }
    } catch (e) {
      print("Error fetching child age: $e");
    }
  }

  String _calculateAge(DateTime dob) {
    final now = DateTime.now();
    final difference = now.difference(dob);

    if (difference.inDays >= 365) {
      final years = (difference.inDays / 365).floor();
      return "$years year${years > 1 ? 's' : ''}";
    } else if (difference.inDays >= 30) {
      final months = (difference.inDays / 30).floor();
      return "$months month${months > 1 ? 's' : ''}";
    } else {
      final weeks = (difference.inDays / 7).floor();
      return "$weeks week${weeks > 1 ? 's' : ''}";
    }
  }

  Future<void> fetchSleepData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('sleepRoutines')
          .orderBy('startTime', descending: true)
          .get();

      setState(() {
        sleepData = snapshot.docs.map((doc) {
          return {
            "start": (doc['startTime'] as Timestamp).toDate(),
            "end": (doc['endTime'] as Timestamp).toDate(),
          };
        }).toList();
      });
    } catch (e) {
      print("Error fetching sleep data: $e");
    }
  }

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

  Future<void> saveRoutine() async {
    if (startTime == null || endTime == null) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('sleepRoutines')
          .add({
        'startTime': startTime,
        'endTime': endTime,
        'createdAt': FieldValue.serverTimestamp(),
      });


      // Update local data
      setState(() {
        sleepData.add({"start": startTime!, "end": endTime!});
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sleep routine saved successfully!")),
      );

      // Navigate to chart screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SleepChartScreen(sleepData: sleepData),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving sleep routine: $e")),
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
                  onPressed: () => Navigator.pop(context),
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
              backgroundColor: Color(0xFF4A148C),
              padding: EdgeInsets.symmetric(horizontal: 60, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: Text("Save Routine", style: TextStyle(color: Colors.white, fontSize: 18)),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SleepChartScreen(sleepData: sleepData),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF4A148C),
              padding: EdgeInsets.symmetric(horizontal: 60, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: Text("View Sleep Chart", style: TextStyle(color: Colors.white, fontSize: 18)),
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: sleepData.length,
              itemBuilder: (context, index) {
                final record = sleepData[index];
                final duration = record["end"]!.difference(record["start"]!);
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: Icon(Icons.nightlight_round, color: Colors.purple),
                    title: Text(
                      "${record["start"]!.hour}:${record["start"]!.minute.toString().padLeft(2, '0')} - "
                          "${record["end"]!.hour}:${record["end"]!.minute.toString().padLeft(2, '0')}",
                    ),
                    subtitle: Text(
                      "${duration.inHours}h ${duration.inMinutes.remainder(60)}m",
                    ),
                    trailing: Text(
                      "${record["start"]!.day}/${record["start"]!.month}/${record["start"]!.year}",
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SleepChartScreen extends StatelessWidget {
  final List<Map<String, DateTime>> sleepData;

  SleepChartScreen({required this.sleepData});

  int _getDayIndex(DateTime date) {
    return date.weekday - 1;
  }

  String _calculateAverageSleep() {
    if (sleepData.isEmpty) return "No data";

    double totalHours = 0;
    int validDays = 0;
    final dayTotals = List.filled(7, 0.0);
    final dayCounts = List.filled(7, 0);

    for (var record in sleepData) {
      final dayIndex = _getDayIndex(record["start"]!);
      final duration = record["end"]!.difference(record["start"]!);
      final hours = duration.inMinutes / 60;

      dayTotals[dayIndex] += hours;
      dayCounts[dayIndex]++;
      totalHours += hours;
      validDays++;
    }

    final avgHours = validDays > 0 ? totalHours / validDays : 0;
    return "${avgHours.toStringAsFixed(1)} hours";
  }

  @override
  Widget build(BuildContext context) {
    final weeklyData = List.generate(7, (index) => <Map<String, DateTime>>[]);
    for (var record in sleepData) {
      final dayIndex = _getDayIndex(record["start"]!);
      weeklyData[dayIndex].add(record);
    }

    final currentWeekDates = List.generate(7, (index) {
      return DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1)).add(Duration(days: index));
    });

    return Scaffold(
      appBar: AppBar(title: const Text("Sleep Chart")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "${currentWeekDates.first.day} ${_monthName(currentWeekDates.first.month)} - "
                  "${currentWeekDates.last.day} ${_monthName(currentWeekDates.last.month)} ${currentWeekDates.last.year}",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Text("Weekly Sleep Summary", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Text("Average Sleep", style: TextStyle(fontSize: 12)),
                            Text(_calculateAverageSleep(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Column(
                          children: [
                            Text("Records", style: TextStyle(fontSize: 12)),
                            Text("${sleepData.length}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            Container(
              height: 400,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: 24,
                  gridData: FlGridData(
                    show: true,
                    horizontalInterval: 2,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withOpacity(0.3),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: 2,
                        getTitlesWidget: (value, meta) {
                          String text;
                          switch (value.toInt()) {
                            case 0: text = '12 AM'; break;
                            case 2: text = '2 AM'; break;
                            case 4: text = '4 AM'; break;
                            case 6: text = '6 AM'; break;
                            case 8: text = '8 AM'; break;
                            case 10: text = '10 AM'; break;
                            case 12: text = '12 PM'; break;
                            case 14: text = '2 PM'; break;
                            case 16: text = '4 PM'; break;
                            case 18: text = '6 PM'; break;
                            case 20: text = '8 PM'; break;
                            case 22: text = '10 PM'; break;
                            case 24: text = '12 AM'; break;
                            default: return Container();
                          }
                          return Text(text, style: TextStyle(fontSize: 12));
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          if (value >= 0 && value < currentWeekDates.length) {
                            final date = currentWeekDates[value.toInt()];
                            return Column(
                              children: [
                                Text("${date.day}/${date.month}", style: TextStyle(fontSize: 12)),
                              ],
                            );
                          }
                          return Container();
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: weeklyData.asMap().entries.map((entry) {
                        if (entry.value.isEmpty) return FlSpot(entry.key.toDouble(), 0);
                        final time = entry.value.first["start"]!;
                        final hour = time.hour + (time.minute / 60);
                        return FlSpot(entry.key.toDouble(), hour);
                      }).toList(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: Colors.blue,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(show: false),
                    ),
                    LineChartBarData(
                      spots: weeklyData.asMap().entries.map((entry) {
                        if (entry.value.isEmpty) return FlSpot(entry.key.toDouble(), 0);
                        final time = entry.value.first["end"]!;
                        final hour = time.hour + (time.minute / 60);
                        return FlSpot(entry.key.toDouble(), hour);
                      }).toList(),
                      isCurved: true,
                      color: Colors.red,
                      barWidth: 3,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: Colors.red,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(show: false),
                    ),
                    LineChartBarData(
                      spots: weeklyData.asMap().entries.expand((entry) {
                        if (entry.value.isEmpty) return <FlSpot>[];
                        final start = entry.value.first["start"]!;
                        final end = entry.value.first["end"]!;
                        return [
                          FlSpot(entry.key.toDouble() - 0.3, start.hour + (start.minute / 60)),
                          FlSpot(entry.key.toDouble(), (start.hour + end.hour) / 2 + (start.minute + end.minute) / 120),
                          FlSpot(entry.key.toDouble() + 0.3, end.hour + (end.minute / 60)),
                        ];
                      }).toList(),
                      isCurved: true,
                      color: Colors.transparent,
                      barWidth: 0,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            Colors.purple.withOpacity(0.3),
                            Colors.purple.withOpacity(0.1),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Sleep Details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 10),
                    ...weeklyData.asMap().entries.map((entry) {
                      if (entry.value.isEmpty) return const SizedBox();
                      final day = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][entry.key];
                      final start = entry.value.first["start"]!;
                      final end = entry.value.first["end"]!;
                      final duration = end.difference(start);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(day, style: TextStyle(fontWeight: FontWeight.w500)),
                            Text(
                              "${start.hour}:${start.minute.toString().padLeft(2, '0')} - ${end.hour}:${end.minute.toString().padLeft(2, '0')}",
                              style: TextStyle(fontSize: 12),
                            ),
                            Text(
                              "${duration.inHours}h ${duration.inMinutes.remainder(60)}m",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            Wrap(
              alignment: WrapAlignment.center,
              spacing: 20,
              runSpacing: 10,
              children: [
                _buildLegendItem(Colors.blue, "Bedtime"),
                _buildLegendItem(Colors.red, "Wake-up"),
                _buildLegendItem(Colors.purple, "Sleep Duration"),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return months[month - 1];
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 12)),
      ],
    );
  }
}