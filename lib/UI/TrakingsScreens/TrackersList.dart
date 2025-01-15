import 'package:flutter/material.dart';
import 'SleepTracking.dart';
import 'FeedingTracker.dart';
import 'VaccinationTracker.dart';
class TrackersList extends StatelessWidget {
  // List of activities
  final List<Map<String, String>> activities = [
    {
      'title': 'Sleep Tracking',
      'description': 'Monitor and track your sleep patterns.',
      'image': 'assets/images/sleep_tracking.jpg',
    },
    {
      'title': 'Feeding',
      'description': 'Keep track of feeding schedules and nutrition.',
      'image': 'assets/images/feeding.jpg',
    },
    {
      'title': 'Vaccination',
      'description': 'Stay updated with vaccination schedules.',
      'image': 'assets/images/vaccination.jpg',
    },
  ];

  // List of tile colors
  final List<Color> tileColors = [
    Colors.lightBlue.shade50,
    Colors.lightGreen.shade50,
    Colors.amber.shade50,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trackers'),
      ),
      body: ListView.builder(
        itemCount: activities.length,
        itemBuilder: (context, index) {
          final activity = activities[index];
          final tileColor = tileColors[index % tileColors.length]; // Rotate colors
          return Card(
            margin: const EdgeInsets.all(8.0),
            color: tileColor,
            child: ListTile(
              leading: Image.asset(
                activity['image']!,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
              title: Text(
                activity['title']!,
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              subtitle: Text(activity['description']!),
              trailing: const Icon(Icons.arrow_forward, color: Colors.grey),
              onTap: () {
                // Navigate to specific activity
                if (activity['title'] == 'Sleep Tracking') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SleepTrackerScreen()),
                  );
                } else if (activity['title'] == 'Feeding') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FeedingTrackerScreen()),
                  );
                } else if (activity['title'] == 'Vaccination') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => VaccinationTrackerScreen()),
                  );
                } else {
                  // Show a dialog with activity details for other activities
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(activity['title']!),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            activity['image']!,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(height: 8.0),
                          Text(activity['description']!),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }
}
