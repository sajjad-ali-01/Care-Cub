import 'package:flutter/material.dart';
import 'appointment_details_page.dart';

class AppointmentsPage extends StatefulWidget {
  final Function(Map<String, String>) onApprove; // ✅ Callback function

  AppointmentsPage({required this.onApprove}); // ✅ Constructor updated

  @override
  _AppointmentsPageState createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  List<Map<String, String>> appointments = [
    {
      "child_name": "Alice",
      "parent_name": "John Doe",
      "parent_contact": "123456789",
      "parent_email": "john@example.com",
      "child_age": "5",
      "duration": "10:00 - 11:00 AM" // ✅ Fixed format
    },
    {
      "child_name": "Bob",
      "parent_name": "Jane Doe",
      "parent_contact": "987654321",
      "parent_email": "jane@example.com",
      "child_age": "7",
      "duration": "11:00 - 12:00 PM" // ✅ Fixed format
    },
  ];

  void removeAppointment(Map<String, String> appointment) {
    setState(() {
      appointments.remove(appointment);
    });
    widget.onApprove(appointment); // ✅ Pass approved appointment to MainScreen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Appointments")),
      body: appointments.isEmpty
          ? Center(child: Text("No appointments available."))
          : ListView.builder(
        padding: EdgeInsets.all(12),
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          final appointment = appointments[index];
          return Card(
            elevation: 4,
            margin: EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              title: Text("Child: ${appointment['child_name']}"),
              subtitle: Text("Duration: ${appointment['duration']}"), // ✅ Fixed
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
