import 'package:flutter/material.dart';

class AppointmentDetailsPage extends StatefulWidget {
  final Map<String, String> appointment;
  final bool isApproved;

  AppointmentDetailsPage({required this.appointment, required this.isApproved});

  @override
  _AppointmentDetailsPageState createState() => _AppointmentDetailsPageState();
}

class _AppointmentDetailsPageState extends State<AppointmentDetailsPage> {
  String status = "Pending";

  @override
  void initState() {
    super.initState();
    if (widget.isApproved) {
      status = "Accepted"; // ✅ Automatically set status if already approved
    }
  }

  void acceptAppointment() {
    setState(() {
      status = "Accepted";
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Appointment Accepted!")),
    );

    Future.delayed(Duration(milliseconds: 500), () {
      Navigator.pop(context, true); // ✅ Return true to remove from Appointments
    });
  }

  void declineAppointment() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Decline Appointment"),
        content: Text("Are you sure you want to decline this appointment?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                status = "Declined";
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Appointment Declined!")),
              );
            },
            child: Text("Decline", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Appointment Details")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Child Name: ${widget.appointment["child_name"]}", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text("Parent Name: ${widget.appointment["parent_name"]}", style: TextStyle(fontSize: 18)),
            Text("Parent Contact: ${widget.appointment["parent_contact"]}", style: TextStyle(fontSize: 18)),
            Text("Parent Email: ${widget.appointment["parent_email"]}", style: TextStyle(fontSize: 18)),
            Text("Child Age: ${widget.appointment["child_age"]}", style: TextStyle(fontSize: 18)),
            Text("Duration: ${widget.appointment["duration"]}", style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),

            Row(
              children: [
                Text("Status: ", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text(status, style: TextStyle(fontSize: 20, color: status == "Accepted" ? Colors.green : status == "Declined" ? Colors.red : Colors.orange)),
              ],
            ),

            SizedBox(height: 30),

            // ✅ Show buttons ONLY if the appointment is NOT approved
            if (!widget.isApproved) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: status == "Pending" ? acceptAppointment : null,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: Text("Accept", style: TextStyle(color: Colors.white)),
                  ),
                  ElevatedButton(
                    onPressed: status == "Pending" ? declineAppointment : null,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: Text("Decline", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
