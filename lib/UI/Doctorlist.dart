import 'package:flutter/material.dart';
import 'Doctor details.dart';

class DoctorList extends StatelessWidget {
  final List<Map<String, String>> dayCareCenters = [
    {
      'name': 'Dr. Ali',
      'location': 'Lake City Downtown',
       'image': 'assets/images/doctor.jpg',
    },
    {
      'name': 'Dr. Alyan',
      'location': 'Green Town',
      'image': 'assets/images/doctor.jpg',
    },
    {
      'name': 'Dr. Usman',
      'location': 'City Housing',
      'image': 'assets/images/doctor.jpg',
    },
    {
      'name': 'Dr. Waqas',
      'location': 'DHA',
      'image': 'assets/images/doctor.jpg',
    },
    {
      'name': 'Dr. Adnan',
      'location': 'Bahria Town',
      'image': 'assets/images/doctor.jpg',
    },
  ];

  // List of tile colors
  final List<Color> tileColors = [
    Colors.lightBlue.shade50,
    Colors.lightGreen.shade50,
    Colors.amber.shade50,
    Colors.pink.shade50,
    Colors.cyan.shade50,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Doctor`s Appontment'),
      ),
      body: ListView.builder(
        itemCount: dayCareCenters.length,
        itemBuilder: (context, index) {
          final center = dayCareCenters[index];
          final tileColor = tileColors[index % tileColors.length]; // Rotate colors
          return Card(
            margin: EdgeInsets.all(8.0),
            color: tileColor,
            child: ListTile(
              leading: Image.asset(
                center['image']!,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
              title: Text(
                center['name']!,
                style: TextStyle(
                  fontSize: 18.0, // Increased font size for the title
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              subtitle: Text('Location: ${center['location']}'),
              trailing: Icon(Icons.arrow_forward, color: Colors.grey),
              onTap: () {
                // Navigate to the details screen with the selected daycare center
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DoctorDetail(
                      name: center['name']!,
                      location: center['location']!,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
