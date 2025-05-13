import 'package:flutter/material.dart';
import 'detail_screen.dart';

class MilestonesScreen extends StatefulWidget {
  @override
  _MilestonesScreenState createState() => _MilestonesScreenState();
}

class _MilestonesScreenState extends State<MilestonesScreen> {
  final List<Map<String, dynamic>> milestones = [
    {'image': 'assets/images/baby1.jpg', 'title': '0 - 2mo', 'total': 11, 'completed': 0},
    {'image': 'assets/images/baby2.jpg', 'title': '2 - 4mo', 'total': 13, 'completed': 0},
    {'image': 'assets/images/baby3.jpg', 'title': '4 - 6mo', 'total': 12, 'completed': 0},
    {'image': 'assets/images/baby4.jpg', 'title': '6 - 9mo', 'total': 13, 'completed': 0},
    {'image': 'assets/images/baby5.jpg', 'title': '9 - 12mo', 'total': 10, 'completed': 0},
  ];

  // Helper function to get the progress bar color based on index
  Color getProgressColor(int index) {
    switch(index) {
      case 0: return Colors.yellow;
      case 1: return Colors.deepOrange;
      case 2: return Colors.lightGreen;
      case 3: return Colors.purple;
      case 4: return Colors.lightBlue;
      default: return Colors.deepOrange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'All Milestones',
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold
          ),
        ),
        backgroundColor: Colors.deepOrange.shade600,
        elevation: 0,
      ),
      backgroundColor: Colors.grey.shade100,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "From their first smile to their first word, your baby's milestones are important markers of their magical growth journey.",
              style: TextStyle(fontSize: 16, color: Colors.black), // Changed to black
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: milestones.length,
                itemBuilder: (context, index) {
                  final milestone = milestones[index];
                  return GestureDetector(
                    onTap: () async {
                      final updatedCount = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailScreen(
                            title: milestone['title'],
                            image: milestone['image'],
                            initialCompleted: milestone['completed'],
                            totalMilestones: milestone['total'],
                          ),
                        ),
                      );

                      if (updatedCount != null) {
                        setState(() {
                          milestones[index]['completed'] = updatedCount;
                        });
                      }
                    },
                    child: Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      color: Colors.white,
                      elevation: 2,
                      child: ListTile(
                        leading: Image.asset(
                          milestone['image'],
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                        title: Text(
                          milestone['title'],
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black // Changed to black
                          ),
                        ),
                        subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                            SizedBox(height: 5),
                        LinearProgressIndicator(
                          value: milestone['completed'] / milestone['total'],
                          backgroundColor: Colors.grey.shade300,
                          color: getProgressColor(index), // Custom color based on index
                        ),
                        SizedBox(height: 5),
                        Text(
                          '${milestone['completed']} / ${milestone['total']}',
                          style: TextStyle(color: Colors.black) // Changed to black
                        )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}