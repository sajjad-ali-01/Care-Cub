import 'package:flutter/material.dart';
import 'BookingScreen.dart';
class DoctorDetail extends StatelessWidget {
  final String name;
  final String location;

  DoctorDetail({required this.name, required this.location});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFEBFF),
      appBar: AppBar(
        backgroundColor: Colors.deepOrange.shade500,
        title: Text(
          name,
          style: TextStyle(color: Color(0xFFFFEBFF)),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Doctor's Image
                    ClipOval(
                      child: Image.asset(
                        'assets/images/doctor.jpg', // Replace with your doctor's image
                        height: 60,
                        width: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 16),
                    // Doctor's Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ' $name', // Replace with dynamic name if needed
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrange.shade800,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Child  Specialist',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'MBBS, FCPS',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // Location
            Text(
              location,
              style: TextStyle(fontSize: 18, color: Colors.deepOrange.shade800),
            ),
            SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/images/Map.jpg',
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 20),

            // Book Appointment Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookingScreen(
                        doctorName: name,
                        doctorImage: 'assets/images/doctor.jpg',
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade300,
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 70),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text(
                  'Book Appointment',
                  style: TextStyle(fontSize: 18, color: Color(0xFFFFEBFF)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

  // Helper widget to display an activity image
  Widget activityImage(String imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.asset(
        imageUrl,
        height: 100,
        width: 260,
        fit: BoxFit.cover,
      ),
    );
  }

// Activities Screen with Activity Cards
class ActivitiesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text('Activities'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          activityCard(
            'Painting Class',
            'assets/images/Baby.png',
            'Let your child explore their creativity through painting.',
          ),
          SizedBox(height: 10),
          activityCard(
            'Music Lessons',
            'assets/images/Baby.png',
            'Fun music lessons to develop rhythm and melody.',
          ),
          SizedBox(height: 10),
          activityCard(
            'Outdoor Play',
            'assets/images/Baby.png',
            'Engage in healthy outdoor activities and games.',
          ),
          SizedBox(height: 10),
          activityCard(
            'Story Time',
            'assets/images/Baby.png',
            'Interactive storytelling sessions to spark imagination.',
          ),
        ],
      ),
    );
  }

  Widget activityCard(String title, String imageUrl, String description) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                imageUrl,
                height: 80,
                width: 80,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                  ),
                  SizedBox(height: 5),
                  Text(
                    description,
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
