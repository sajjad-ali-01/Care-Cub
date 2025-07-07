import 'package:carecub/UI/DayCare/Daycarecenter/report_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class DaycareAppointments extends StatefulWidget {
  @override
  _DaycareAppointmentsState createState() => _DaycareAppointmentsState();
}

class _DaycareAppointmentsState extends State<DaycareAppointments> {
  late String daycareId;
  String searchQuery = "";
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    daycareId = user!.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointments',style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.deepOrange.shade400,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: "Search by Child Name",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(width: 2,color: Colors.black)
                      ),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: firestore
                    .collection('DaycareBookings')
                    .where('daycareId', isEqualTo: daycareId)
                    .where('status', isEqualTo: 'confirmed')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator(color: Colors.deepOrange));
                  }

                  final bookings = snapshot.data?.docs ?? [];

                  final filteredBookings = bookings.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final childName = data['childName']?.toString().toLowerCase() ?? '';
                    return childName.contains(searchQuery.toLowerCase());
                  }).toList();

                  if (filteredBookings.isEmpty) {
                    return Center(
                      child: Text(
                        searchQuery.isEmpty
                            ? 'No confirmed daycare bookings found'
                            : 'No matching bookings found',
                        style: TextStyle(fontSize: 16),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: filteredBookings.length,
                    itemBuilder: (context, index) {
                      final doc = filteredBookings[index];
                      final booking = doc.data() as Map<String, dynamic>;
                      final bookingId = doc.id;

                      List<Color> tileColors = [
                        Colors.yellow.shade100,
                        Colors.green.shade100,
                        Colors.orange.shade100,
                        Colors.teal.shade100,
                        Colors.purple.shade100,
                      ];

                      Color tileColor = tileColors[index % tileColors.length];

                      return Card(
                        color: tileColor,
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.deepOrange.shade100,
                            child: Icon(Icons.child_care, color: Colors.deepOrange),
                          ),
                          title: Text(booking['childName'] ?? 'No Name'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Start Date: ${booking['startDate'] ?? 'N/A'}"),
                              Text("Time: ${booking['preferredTime'] ?? 'N/A'}"),
                            ],
                          ),
                          trailing: Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DaycareBookingDetailPage(
                                  booking: booking,
                                  bookingId: bookingId,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DaycareBookingDetailPage extends StatelessWidget {
  final Map<String, dynamic> booking;
  final String bookingId;

  const DaycareBookingDetailPage({
    required this.booking,
    required this.bookingId,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = booking['status']?.toString().toLowerCase() == 'completed';

    return Scaffold(
      appBar: AppBar(title: Text("Booking Details")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.deepOrange.shade100,
                  child: Icon(Icons.child_care, size: 50, color: Colors.deepOrange),
                ),
              ),
              SizedBox(height: 20),

              buildDetailRow("Child Name", booking['childName'] ?? 'Not specified'),
              buildDetailRow("Gender", booking['childGender'] ?? 'Not specified'),
              buildDetailRow("Parent Name", booking['userName'] ?? 'Not specified'),
              buildDetailRow("Parent Contact", booking['parentContact'] ?? 'Not specified'),
              buildDetailRow("Start Date", booking['startDate'] ?? 'Not specified'),
              buildDetailRow("Preferred Time", booking['preferredTime'] ?? 'Not specified'),
              buildDetailRow("Confirmed At", formatDateTime(booking['confirmedAt'])),
              SizedBox(height: 16),
              buildDetailSection("Special Notes", booking['specialNotes'] ?? 'No special notes provided'),

              // Add Complete Booking button
              if (!isCompleted)
                Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context)=>ReportPage(
                        childName: booking['childName'],
                        childAge: booking['childAge'] ?? 'Not specified',
                        parentName: booking['userName'],
                        bookingId: bookingId,)));},
                      child: Text(
                        'Mark as Completed',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              if (isCompleted)
                Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        'Booking Completed',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.green.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> completeBooking(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Completion'),
        content: Text('Are you sure you want to mark this daycare booking as completed?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text('Complete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Center(child: CircularProgressIndicator()),
        );

        await FirebaseFirestore.instance
            .collection('DaycareBookings')
            .doc(bookingId)
            .update({
          'status': 'completed',
          'completedAt': FieldValue.serverTimestamp(),
        });

        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Daycare booking marked as completed'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
      } catch (e) {
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to complete booking: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDetailSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(content),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  String formatDateTime(Timestamp? timestamp) {
    if (timestamp == null) return 'Not available';
    return DateFormat('MMMM dd, yyyy - hh:mm a').format(timestamp.toDate());
  }
}

