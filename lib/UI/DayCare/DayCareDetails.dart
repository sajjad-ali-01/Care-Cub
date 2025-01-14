import 'package:flutter/material.dart';
import 'BookingScreen.dart';

class DayCareDetailScreen extends StatelessWidget {
  final String name;
  final String location;

  DayCareDetailScreen({required this.name, required this.location});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFEBFF),
      appBar: AppBar(
        backgroundColor: Colors.deepOrange.shade500,
        title: Text(name,style: TextStyle(color: Color(0xFFFFEBFF)),),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Daycare Name
            Text(
              name,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepOrange.shade800),
            ),
            SizedBox(height: 10),
            Text(
              'Welcome to $name! We provide a safe and nurturing environment for your little ones.',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            SizedBox(height: 20),
            Text(
              'Activities',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepOrange.shade800),
            ),
            SizedBox(height: 10),
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  activityImage('assets/images/activities1.PNG'),
                  SizedBox(width: 10),
                  activityImage('assets/images/activiteis2.PNG'),
                  SizedBox(width: 10),
                  activityImage('assets/images/activities3.PNG'),
                  SizedBox(width: 10),
                  activityImage('assets/images/activities4.PNG'),
                ],
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade300,
                padding: EdgeInsets.symmetric(
                    vertical: 10, horizontal: 30),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ActivitiesScreen()),
                );
              },
              child: Text('View ALL Activities',style: TextStyle(color: Color(0xFFFFEBFF)),),
            ),
            SizedBox(height: 20,),
            // Location with Map Image
            Text(
              '$location',
              style: TextStyle(fontSize: 18, color: Colors.deepOrange.shade800),
            ),
            SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/images/Map.PNG',
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 20),
            // Images of Activities

            SizedBox(height: 20),

            // Book Now Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookingScreen(
                        daycareName: name,
                        daycareImage: 'assets/images/daycareCenter2.webp',
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade300,
                  padding: EdgeInsets.symmetric(
                      vertical: 10, horizontal: 110),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
                child: Text(
                  'Book Now',
                  style: TextStyle(fontSize: 18,color: Color(0xFFFFEBFF)),
                ),
              )

            ),
          ],
        ),
      ),
    );
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
