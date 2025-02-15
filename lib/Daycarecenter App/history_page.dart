import 'package:flutter/material.dart';
import 'appointment_details_page.dart';

class ApprovedAppointmentsPage extends StatelessWidget {
  final List<Map<String, String>> approvedAppointments;

  const ApprovedAppointmentsPage({Key? key, required this.approvedAppointments}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold( // ✅ Ensures proper UI structure
      body: approvedAppointments.isEmpty
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
                      isApproved: true,
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

class HistoryPage extends StatefulWidget {
  final List<Map<String, String>> approvedAppointments;

  const HistoryPage({Key? key, required this.approvedAppointments}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("History"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Approved"),
              Tab(text: "Reports"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ApprovedAppointmentsPage(approvedAppointments: widget.approvedAppointments), // ✅ Shows approved appointments
            Scaffold(
              body: Center(child: Text("Reports coming soon...")), // ✅ Ensures proper UI structure
            ),
          ],
        ),
      ),
    );
  }
}
