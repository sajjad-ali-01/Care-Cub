import 'package:flutter/material.dart';
import 'appointment_details_page.dart';

class ApprovedAppointmentsPage extends StatelessWidget {
  final List<Map<String, String>> approvedAppointments;

  const ApprovedAppointmentsPage({Key? key, required this.approvedAppointments}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return approvedAppointments.isEmpty
        ? Center(child: Text("No approved appointments yet.", style: TextStyle(fontSize: 16)))
        : ListView.builder(
      padding: EdgeInsets.all(12),
      itemCount: approvedAppointments.length,
      itemBuilder: (context, index) {
        final appointment = approvedAppointments[index];
        return Card(
          elevation: 4,
          margin: EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            title: Text("Child: ${appointment['child_name']}"),
            subtitle: Text("Duration: ${appointment['duration']}"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AppointmentDetailsPage(
                    appointment: appointment,
                    isApproved: true, // ✅ Approved, hide buttons
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
