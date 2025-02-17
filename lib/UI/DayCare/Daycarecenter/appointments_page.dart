import 'package:flutter/material.dart';
import 'appointment_details_page.dart';

class AppointmentsPage extends StatefulWidget {
  final Function(Map<String, String>) onApprove;

  AppointmentsPage({required this.onApprove});

  @override
  _AppointmentsPageState createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  List<Map<String, String>> appointments = [
    {
      "child_name": "Ali",
      "parent_name": "Fatima",
      "parent_contact": "123456789",
      "parent_email": "Fatima@example.com",
      "child_age": "5",
      "duration": "10:00 - 11:00 AM"
    },
    {
      "child_name": "Ahmad",
      "parent_name": "Ali",
      "parent_contact": "987654321",
      "parent_email": "Ali@example.com",
      "child_age": "7",
      "duration": "11:00 - 12:00 PM"
    },
  ];

  void removeAppointment(Map<String, String> appointment) {
    setState(() {
      appointments.remove(appointment);
    });
    widget.onApprove(appointment);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Appointments",style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.deepOrange.shade400,
      ),
      body: appointments.isEmpty
          ? Center(child: Text("No appointments available."))
          : ListView.builder(
        padding: EdgeInsets.all(12),
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          final appointment = appointments[index];
          final List<Color> tileColors = [
            Colors.blue.shade100,
            Colors.green.shade100,
            Colors.orange.shade100,
            Colors.purple.shade100,
            Colors.red.shade100,
            Colors.teal.shade100,
          ];

          final color = tileColors[index % tileColors.length];

          return Card(
            elevation: 4,
            margin: EdgeInsets.symmetric(vertical: 8),
            color: color,
            child: ListTile(
              title: Text("Child: ${appointment['child_name']}"),
              subtitle: Text("Duration: ${appointment['duration']}"),
              onTap: () async {
                bool? isApproved = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AppointmentDetailsPage(
                      appointment: appointment,
                      isApproved: false,
                    ),
                  ),
                );

                if (isApproved == true) {
                  removeAppointment(appointment);
                }
              },
            ),
          );
        },
      ),
    );
  }
}
