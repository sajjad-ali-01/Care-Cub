import 'package:flutter/material.dart';
import 'DayCareDetails.dart';

class DayCarelisting extends StatelessWidget {
  final List<Map<String, String>> dayCareCenters = [
    {
      'name': 'Little Stars DayCare',
      'location': 'Lake City Downtown',
      'image': 'assets/images/daycareCenter1.webp',
    },
    {
      'name': 'Happy Kids Care',
      'location': 'Green Town',
      'image': 'assets/images/daycareCenter3.webp',
    },
    {
      'name': 'Bright Future DayCare',
      'location': 'City Housing',
      'image': 'assets/images/daycareCenter2.webp',
    },
    {
      'name': 'Tiny Tots Haven',
      'location': 'DHA',
      'image': 'assets/images/daycareCenter3.webp',
    },
    {
      'name': 'Sunny Smiles DayCare',
      'location': 'Bahria Town',
      'image': 'assets/images/daycareCenter1.webp',
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
      backgroundColor: Color(0xFFFFEBFF),
      appBar: AppBar(
        backgroundColor: Colors.deepOrange.shade500,
        title: Text('DayCare Centers',style: TextStyle(color: Color(0xFFFFEBFF))),
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
                    builder: (context) => DayCareDetailScreen(
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