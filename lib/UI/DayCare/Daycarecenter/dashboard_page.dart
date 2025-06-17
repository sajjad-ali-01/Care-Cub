import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class DayCareDashboard extends StatefulWidget {
  @override
  _DayCareDashboardState createState() => _DayCareDashboardState();
}

class _DayCareDashboardState extends State<DayCareDashboard> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late String daycareId;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    daycareId = user!.uid;
  }

  Future<void> acceptAppointment(String appointmentId) async {
    try {
      await firestore.collection('DaycareBookings').doc(appointmentId).update({
        'status': 'confirmed',
        'confirmedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error accepting appointment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to accept appointment')),
      );
    }
  }

  Future<void> declineAppointment(String appointmentId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String declineReason = '';
        return AlertDialog(
          title: Text("Decline Appointment"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Are you sure you want to decline this appointment?"),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Reason for declining',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => declineReason = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await firestore.collection('DaycareBookings').doc(appointmentId).update({
                    'status': 'declined',
                    'declinedAt': FieldValue.serverTimestamp(),
                    'declineReason': declineReason,
                  });
                  Navigator.pop(context);
                } catch (e) {
                  print('Error declining appointment: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to decline appointment')),
                  );
                }
              },
              child: Text("Decline", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text('Day Care Dashboard', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepOrange.shade500,
      ),
      body: DaycareAppointmentsPage(
        daycareId: daycareId,
        onAccept: acceptAppointment,
        onDecline: declineAppointment,
      ),
    );
  }
}

class DaycareAppointmentsPage extends StatelessWidget {
  final String daycareId;
  final Function(String) onAccept;
  final Function(String) onDecline;

  const DaycareAppointmentsPage({
    required this.daycareId,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('DaycareBookings')
          .where('daycareId', isEqualTo: daycareId)
          .where('status', isEqualTo: 'pending')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          print('Error: ${snapshot.error}');
          return Center(child: Text('Error loading appointments: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          print('No documents found');
          return Center(child: Text('No pending appointments found'));
        }

        final appointments = snapshot.data!.docs;
        print('Found ${appointments.length} appointments');

        return ListView.builder(
          padding: EdgeInsets.all(16.0),
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            final appointment = appointments[index];
            final data = appointment.data() as Map<String, dynamic>;
            final appointmentId = appointment.id;

            print('Appointment data: $data');

            return Card(
              margin: EdgeInsets.only(bottom: 16),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with child name and status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            data['childName'] ?? 'Child Name',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrange,
                            ),
                          ),
                        ),
                        Chip(
                          label: Text(
                            (data['status'] ?? 'PENDING').toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          backgroundColor: Colors.orange,
                          shape: StadiumBorder(
                            side: BorderSide(color: Colors.white.withOpacity(0.2)),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),

                    // Daycare information
                    Row(
                      children: [
                        Icon(Icons.child_care, color: Colors.green),
                        SizedBox(width: 10),
                        Text(
                          data['daycareName'] ?? 'Daycare Name',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.red),
                        SizedBox(width: 10),
                        Text(
                          data['daycareLocation'] ?? 'Daycare Address',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),

                    // Divider
                    Divider(color: Colors.grey.shade300),
                    SizedBox(height: 12),

                    // Child information
                    Row(
                      children: [
                        Icon(Icons.person, size: 18, color: Colors.deepOrange),
                        SizedBox(width: 8),
                        Text(
                          'Child: ${data['childName'] ?? 'N/A'}',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        SizedBox(width: 16),
                        Icon(Icons.child_friendly, size: 18, color: Colors.deepOrange),
                        SizedBox(width: 8),
                        Text(
                          data['childGender'] ?? 'N/A',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),

                    // Contact information
                    Row(
                      children: [
                        Icon(Icons.phone, size: 18, color: Colors.deepOrange),
                        SizedBox(width: 8),
                        Text(
                          'Contact: ${data['parentContact'] ?? 'N/A'}',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),

                    // Divider
                    Divider(color: Colors.grey.shade300),
                    SizedBox(height: 12),

                    // Appointment details
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Start Date',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                data['startDate'] ?? 'N/A',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Preferred Time',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                data['preferredTime'] ?? 'N/A',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),

                    // Special Notes
                    if (data['specialNotes'] != null && data['specialNotes'].isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Special Notes:',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            data['specialNotes'],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 12),
                        ],
                      ),

                    // Accept/Decline buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => onAccept(appointmentId),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Accept',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => onDecline(appointmentId),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Decline',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Booking date information
                    if (data['bookingDate'] != null)
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Booked on ${_formatFirestoreTimestamp(data['bookingDate'])}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _formatFirestoreTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    if (timestamp is Timestamp) {
      return DateFormat('MMM d, yyyy hh:mm a').format(timestamp.toDate());
    }
    return 'N/A';
  }
}