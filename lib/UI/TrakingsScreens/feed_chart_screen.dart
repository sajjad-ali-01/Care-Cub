import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class FeedChartScreen extends StatelessWidget {
  final List<Map<String, dynamic>> feedData; // {side: 'left'/'right', duration: Duration}

  FeedChartScreen({required this.feedData});

  int _getDayIndex(DateTime date) {
    return date.weekday - 1;
  }

  String _calculateAverageFeed() {
    if (feedData.isEmpty) return "No data";

    double totalMinutes = 0;
    int validFeeds = 0;
    final dayTotals = List.filled(7, 0.0);
    final dayCounts = List.filled(7, 0);

    for (var record in feedData) {
      final dayIndex = _getDayIndex(record["date"]!);
      final minutes = record["duration"].inMinutes;

      dayTotals[dayIndex] += minutes;
      dayCounts[dayIndex]++;
      totalMinutes += minutes;
      validFeeds++;
    }

    final avgMinutes = validFeeds > 0 ? totalMinutes / validFeeds : 0;
    return "${avgMinutes.toStringAsFixed(0)} minutes";
  }

  @override
  Widget build(BuildContext context) {
    final weeklyData = List.generate(7, (index) => <Map<String, dynamic>>[]);
    for (var record in feedData) {
      final dayIndex = _getDayIndex(record["date"]!);
      weeklyData[dayIndex].add(record);
    }

    final currentWeekDates = List.generate(7, (index) {
      return DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1)).add(Duration(days: index));
    });

    return Scaffold(
      appBar: AppBar(title: const Text("Feeding Chart")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "${_getMonthName(currentWeekDates.first.month)} ${currentWeekDates.first.day}-${currentWeekDates.last.day}, ${currentWeekDates.first.year}",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Text("Weekly Feeding Summary", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Text("Average Feed", style: TextStyle(fontSize: 12)),
                            Text(_calculateAverageFeed(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Column(
                          children: [
                            Text("Sessions", style: TextStyle(fontSize: 12)),
                            Text("${feedData.length}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Feeding Details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(day, style: TextStyle(fontWeight: FontWeight.w500)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Left side:", style: TextStyle(fontSize: 12)),
                                Text("$leftFeeds sessions", style: TextStyle(fontSize: 12)),
                                Text(
                                  "${leftDuration.inMinutes}m",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Right side:", style: TextStyle(fontSize: 12)),
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

            Wrap(
              alignment: WrapAlignment.center,
              spacing: 20,
              runSpacing: 10,
              children: [
                _buildLegendItem(Colors.orange, "Left side"),
                _buildLegendItem(Colors.pink, "Right side"),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
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

  String _getMonthName(int month) {
    const monthNames = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return monthNames[month - 1];
  }
}
