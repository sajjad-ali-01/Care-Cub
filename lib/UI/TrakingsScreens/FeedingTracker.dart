import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class FeedingTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Feeding Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
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
  bool _isSaving = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  void startLeftTimer() {
    if (!isLeftTimerRunning) {
      setState(() {
        isLeftTimerRunning = true;
        isRightTimerRunning = false;
        rightTimer?.cancel();
        rightDuration = Duration.zero;
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
        isLeftTimerRunning = false;
        leftTimer?.cancel();
        leftDuration = Duration.zero;
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

  Future<void> saveRoutine() async {
    if (leftDuration.inSeconds == 0 && rightDuration.inSeconds == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please record feeding time first')),
      );
      return;
    }

    setState(() => _isSaving = true);
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please sign in to save data')),
      );
      return;
    }

    try {
      final now = DateTime.now();
      final batch = _firestore.batch();

      if (leftDuration.inSeconds > 0) {
        final leftRef = _firestore
            .collection('trackers')
            .doc(user.uid)
            .collection('feedings')
            .doc();
        batch.set(leftRef, {
          'side': 'left',
          'duration': leftDuration.inSeconds,
          'date': now,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      if (rightDuration.inSeconds > 0) {
        final rightRef = _firestore
            .collection('trackers')
            .doc(user.uid)
            .collection('feedings')
            .doc();
        batch.set(rightRef, {
          'side': 'right',
          'duration': rightDuration.inSeconds,
          'date': now,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();

      // Navigate to FeedChartScreen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FeedChartScreen(userId: user.uid),
        ),
      );

      // Reset timers
      setState(() {
        leftDuration = Duration.zero;
        rightDuration = Duration.zero;
        isLeftTimerRunning = false;
        isRightTimerRunning = false;
      });
      leftTimer?.cancel();
      rightTimer?.cancel();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving feeding data: $e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    leftTimer?.cancel();
    rightTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String time = TimeOfDay.now().format(context);
    String date = "${DateTime.now().day} ${_getMonthName(DateTime.now().month)}";

    return Scaffold(
      appBar: AppBar(
        title: Text("Feeding Tracker"),
        actions: [
          IconButton(
            icon: Icon(Icons.bar_chart),
            onPressed: () {
              final user = _auth.currentUser;
              if (user != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FeedChartScreen(userId: user.uid),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please sign in to view charts')),
                );
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
          Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Today",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBreastSideCard(
              context,
              side: "Left",
              duration: leftDuration,
              isRunning: isLeftTimerRunning,
              color: Colors.orange,
              onTap: () {
                stopRightTimer();
                isLeftTimerRunning ? stopLeftTimer() : startLeftTimer();
              },
            ),
            _buildBreastSideCard(
              context,
              side: "Right",
              duration: rightDuration,
              isRunning: isRightTimerRunning,
              color: Colors.pink,
              onTap: () {
                stopLeftTimer();
                isRightTimerRunning ? stopRightTimer() : startRightTimer();
              },
            ),
          ],
        ),
        SizedBox(height: 30),
        ElevatedButton(
          onPressed: _isSaving ? null : saveRoutine,
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            )
          ),
            child: _isSaving
                ? CircularProgressIndicator(color: Colors.white)
                : Text(
              "Save Session",
              style: TextStyle(fontSize: 18),
            ),
          ),
          SizedBox(height: 20),
          Text(
            "Tip: Tap one side to start timing. The other side will automatically reset.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
          ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreastSideCard(
      BuildContext context, {
        required String side,
        required Duration duration,
        required bool isRunning,
        required Color color,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        color: isRunning ? color.withOpacity(0.2) : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.4,
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                side == "Left" ? Icons.arrow_back : Icons.arrow_forward,
                size: 40,
                color: color,
              ),
              SizedBox(height: 10),
              Text(
                side,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              SizedBox(height: 15),
              Text(
                formatDuration(duration),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: isRunning ? color : Colors.grey,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                  isRunning ? "Stop" : "Start",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const monthNames = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return monthNames[month - 1];
  }
}

class FeedChartScreen extends StatefulWidget {
  final String userId;

  FeedChartScreen({required this.userId});

  @override
  _FeedChartScreenState createState() => _FeedChartScreenState();
}

class _FeedChartScreenState extends State<FeedChartScreen> {
  late Stream<QuerySnapshot> _feedStream;

  @override
  void initState() {
    super.initState();
    _feedStream = FirebaseFirestore.instance
        .collection('trackers')
        .doc(widget.userId)
        .collection('feedings')
        .orderBy('date', descending: true)
        .snapshots();
  }

  int _getDayIndex(DateTime date) {
    return date.weekday - 1;
  }

  String _calculateAverageFeed(List<Map<String, dynamic>> feedData) {
    if (feedData.isEmpty) return "No data";

    double totalMinutes = 0;
    int validFeeds = 0;

    for (var record in feedData) {
      final minutes = (record["duration"] as int) ~/ 60;
      totalMinutes += minutes;
      validFeeds++;
    }

    final avgMinutes = validFeeds > 0 ? totalMinutes / validFeeds : 0;
    return "${avgMinutes.toStringAsFixed(0)} minutes";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Feeding History"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _feedStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "No feeding data available",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final feedData = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return {
              'side': data['side'] as String,
              'duration': Duration(seconds: data['duration'] as int),
              'date': (data['date'] as Timestamp).toDate(),
            };
          }).toList();

          final weeklyData = List.generate(7, (index) => <Map<String, dynamic>>[]);
          for (var record in feedData) {
            //final dayIndex = _getDayIndex(record["date"]!);
            //weeklyData[dayIndex].add(record);
          }

          final currentWeekDates = List.generate(7, (index) {
            return DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1)).add(Duration(days: index));
          });

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  "${_getMonthName(currentWeekDates.first.month)} ${currentWeekDates.first.day}-${currentWeekDates.last.day}, ${currentWeekDates.first.year}",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          "Weekly Summary",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Text("Average Feed", style: TextStyle(fontSize: 12)),
                                Text(
                                  _calculateAverageFeed(feedData),
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text("Total Sessions", style: TextStyle(fontSize: 12)),
                                Text(
                                  "${feedData.length}",
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
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
                  height: 300,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 60, // Max 60 minutes
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final day = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][group.x.toInt()];
                            final leftMinutes = weeklyData[group.x.toInt()]
                                .where((feed) => feed["side"] == "left")
                                .fold<int>(0, (sum, feed) => feed["duration"].inMinutes + sum);
                            final rightMinutes = weeklyData[group.x.toInt()]
                                .where((feed) => feed["side"] == "right")
                                .fold<int>(0, (sum, feed) => feed["duration"].inMinutes + sum);
                            return BarTooltipItem(
                              '$day\nLeft: ${leftMinutes}m\nRight: ${rightMinutes}m',
                              TextStyle(color: Colors.white),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            interval: 10,
                            getTitlesWidget: (value, meta) {
                              return Text("${value.toInt()}m", style: TextStyle(fontSize: 12));
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (value, meta) {
                              if (value >= 0 && value < currentWeekDates.length) {
                                return Text(
                                  ['M', 'T', 'W', 'T', 'F', 'S', 'S'][value.toInt()],
                                  style: TextStyle(fontSize: 12),
                                );
                              }
                              return Container();
                            },
                          ),
                        ),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 10,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Colors.grey.withOpacity(0.3),
                            strokeWidth: 1,
                          );
                        },
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(color: Colors.grey.withOpacity(0.3)),
                      ),
                      barGroups: weeklyData.asMap().entries.map((entry) {
                        final leftMinutes = entry.value
                            .where((feed) => feed["side"] == "left")
                            .fold<int>(0, (sum, feed) => feed["duration"].inMinutes + sum);
                        final rightMinutes = entry.value
                            .where((feed) => feed["side"] == "right")
                            .fold<int>(0, (sum, feed) => feed["duration"].inMinutes + sum);

                        return BarChartGroupData(
                          x: entry.key,
                          barRods: [
                            BarChartRodData(
                              toY: leftMinutes.toDouble(),
                              color: Colors.orange,
                              width: 16,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(4),
                                topRight: Radius.circular(4),
                              ),
                            ),
                            BarChartRodData(
                              toY: rightMinutes.toDouble(),
                              color: Colors.pink,
                              width: 16,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(4),
                                topRight: Radius.circular(4),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Daily Details",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...weeklyData.asMap().entries.map((entry) {
                          if (entry.value.isEmpty) return const SizedBox();
                          final day = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][entry.key];
                          final leftFeeds = entry.value.where((feed) => feed["side"] == "left").length;
                          final rightFeeds = entry.value.where((feed) => feed["side"] == "right").length;
                          final leftDuration = entry.value
                              .where((feed) => feed["side"] == "left")
                              .fold(Duration.zero, (sum, feed) => sum + feed["duration"]);
                          final rightDuration = entry.value
                              .where((feed) => feed["side"] == "right")
                              .fold(Duration.zero, (sum, feed) => sum + feed["duration"]);

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  day,
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: Colors.orange,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text("Left:", style: TextStyle(fontSize: 12)),
                                      ],
                                    ),
                                    Text("$leftFeeds sessions", style: TextStyle(fontSize: 12)),
                                    Text(
                                      "${leftDuration.inMinutes}m",
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: Colors.pink,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text("Right:", style: TextStyle(fontSize: 12)),
                                      ],
                                    ),
                                    Text("$rightFeeds sessions", style: TextStyle(fontSize: 12)),
                                    Text(
                                      "${rightDuration.inMinutes}m",
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Divider(height: 16, thickness: 0.5),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getMonthName(int month) {
    const monthNames = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return monthNames[month - 1];
  }
}
