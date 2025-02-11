import 'package:flutter/material.dart';

class BookingsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> bookings = [
    {
      'doctorName': 'Dr. Ayesha Khan',
      'specialization': 'Pediatrician, Neonatologist',
      'date': '2025-10-25',
      'time': '03:00 PM',
      'location': 'Sunshine Children\'s Hospital',
    },
    {
      'doctorName': 'Dr. Usman Sheikh',
      'specialization': 'Child Specialist, Pediatrician',
      'date': '2025-10-26',
      'time': '11:00 AM',
      'location': 'Happy Kids Clinic',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Bookings'),
        backgroundColor: Colors.deepOrange.shade400,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return BookingCard(booking: booking);
        },
      ),
    );
  }
}

class BookingCard extends StatelessWidget {
  final Map<String, dynamic> booking;

  BookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              booking['doctorName'],
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              booking['specialization'],
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 16),

            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.deepOrange),
                SizedBox(width: 8),
                Text(
                  'Date: ${booking['date']}',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.deepOrange),
                SizedBox(width: 8),
                Text(
                  'Time: ${booking['time']}',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Location
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.deepOrange),
                SizedBox(width: 8),
                Text(
                  'Location: ${booking['location']}',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}