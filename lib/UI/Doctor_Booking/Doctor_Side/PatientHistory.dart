import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class PatientHistoryPage extends StatefulWidget {
  @override
  _PatientHistoryPageState createState() => _PatientHistoryPageState();
}

class _PatientHistoryPageState extends State<PatientHistoryPage> {
  late String doctorId;
  String searchQuery = "";
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    doctorId = user!.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: "Search by Patient Name",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                ),
              ),
              SizedBox(width: 10),
              IconButton(
                icon: Icon(Icons.history, size: 30),
                tooltip: 'View Complete History',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HistoryScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('Bookings')
                  .where('doctorId', isEqualTo: doctorId)
                  .where('status', isEqualTo: 'confirmed')
                  //.orderBy('date')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: Colors.deepOrange));
                }
                //
                // if (snapshot.hasError) {
                //   return Center(child: Text('Error loading bookings', style: TextStyle(color: Colors.red)));
                // }

                final bookings = snapshot.data?.docs ?? [];

                // Filter by search query
                final filteredBookings = bookings.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final patientName = data['childName']?.toString().toLowerCase() ?? '';
                  return patientName.contains(searchQuery.toLowerCase());
                }).toList();

                if (filteredBookings.isEmpty) {
                  return Center(
                    child: Text(
                      searchQuery.isEmpty
                          ? 'No confirmed appointments found'
                          : 'No matching appointments found',
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredBookings.length,
                  itemBuilder: (context, index) {
                    final doc = filteredBookings[index];
                    final appointment = doc.data() as Map<String, dynamic>;
                    final appointmentId = doc.id;

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
                          backgroundImage: AssetImage("assets/images/profile_pic.png"),
                        ),
                        title: Text(appointment['childName'] ?? 'No Name'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Date: ${_formatDate(appointment['date'])}"),
                            Text("Time: ${appointment['time']}"),
                          ],
                        ),
                        trailing: Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PatientDetailPage(
                                appointment: appointment,
                                appointmentId: appointmentId,
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
    );
  }

  String _formatDate(Timestamp timestamp) {
    return DateFormat('MMM dd, yyyy').format(timestamp.toDate());
  }
}
class PatientDetailPage extends StatelessWidget {
  final Map<String, dynamic> appointment;
  final String appointmentId;

  const PatientDetailPage({
    required this.appointment,
    required this.appointmentId,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = appointment['status']?.toString().toLowerCase() == 'completed';

    return Scaffold(
      appBar: AppBar(title: Text("Patient Details")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: AssetImage("assets/images/profile_pic.png"),
                ),
              ),
              SizedBox(height: 20),

              _buildDetailRow("Patient Name", appointment['childName'] ?? 'Not specified'),
              _buildDetailRow("Gender", appointment['gender'] ?? 'Not specified'),
              _buildDetailRow("Age", appointment['age']?.toString() ?? 'Not specified'),
              _buildDetailRow("Contact", appointment['contactNumber'] ?? 'Not specified'),
              _buildDetailRow("Appointment Date", _formatDate(appointment['date'])),
              _buildDetailRow("Appointment Time", appointment['time'] ?? 'Not specified'),
              _buildDetailRow("Confirmed At", _formatDateTime(appointment['confirmedAt'])),
              SizedBox(height: 16),
              _buildDetailSection("Description", appointment['description'] ?? 'No description provided'),
              if (appointment['notes'] != null)
                _buildDetailSection("Doctor Notes", appointment['notes']),

              // Add Complete Appointment button
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
                      onPressed: () => _completeAppointment(context),
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
                        'Appointment Completed',
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

  Future<void> _completeAppointment(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Completion'),
        content: Text('Are you sure you want to mark this appointment as completed?'),
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
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Center(child: CircularProgressIndicator()),
        );

        // Update status in Firestore
        await FirebaseFirestore.instance
            .collection('Bookings')
            .doc(appointmentId)
            .update({
          'status': 'completed',
          'completedAt': FieldValue.serverTimestamp(),
        });

        // Close loading indicator
        Navigator.pop(context);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Appointment marked as completed'),
            backgroundColor: Colors.green,
          ),
        );

        // Close the detail page and return to previous screen
        Navigator.pop(context);
      } catch (e) {
        // Close loading indicator
        Navigator.pop(context);

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to complete appointment: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildDetailRow(String label, String value) {
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

  Widget _buildDetailSection(String title, String content) {
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

  String _formatDate(Timestamp timestamp) {
    return DateFormat('MMMM dd, yyyy').format(timestamp.toDate());
  }

  String _formatDateTime(Timestamp? timestamp) {
    if (timestamp == null) return 'Not available';
    return DateFormat('MMMM dd, yyyy - hh:mm a').format(timestamp.toDate());
  }
}
class HistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('History', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepOrange.shade400,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Bookings')
            .where('doctorId', isEqualTo: user?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error loading history'));
          }

          final bookings = snapshot.data?.docs ?? [];

          // Filter bookings - show only past appointments or completed/cancelled ones
          // In HistoryScreen, improve filtering:
          final historyBookings = bookings.where((doc) {
            final booking = doc.data() as Map<String, dynamic>;
            final status = booking['status']?.toString().toLowerCase();
            final bookingDate = booking['date']?.toDate() ?? DateTime.now();
            final isPast = bookingDate.isBefore(DateTime.now());

            return status == 'completed' ||
                status == 'cancelled' ||
                (status == 'declined');
          }).toList();

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: historyBookings.length,
            itemBuilder: (context, index) {
              final booking = historyBookings[index].data() as Map<String, dynamic>;
              return HistoryCard(booking: booking);
            },
          );
        },
      ),
    );
  }
}
class HistoryCard extends StatelessWidget {
  final Map<String, dynamic> booking;

  HistoryCard({required this.booking});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.purple;
      case 'declined':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDeclined = booking['status']?.toString().toLowerCase() == 'declined';

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor Name and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  booking['doctorName'] ?? 'Doctor Name',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                  ),
                ),
                Chip(
                  label: Text(
                    booking['status']?.toUpperCase() ?? 'STATUS',
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: _getStatusColor(booking['status'] ?? ''),
                ),
              ],
            ),
            SizedBox(height: 10),

            // Clinic
            Row(
              children: [
                Icon(Icons.medical_services, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  booking['clinicName'] ?? 'Clinic Name',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            SizedBox(height: 4),

            // Address
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.red),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    booking['clinicAddress'] ?? 'Clinic Address',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),

            // Decline reason (only for declined bookings)
            if (isDeclined && booking['declineReason'] != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Decline Reason:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.red.shade700,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Dr. says! ``${booking['declineReason']}``",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  SizedBox(height: 12),
                ],
              ),

            // Appointment date/time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Date: ${_formatDate(booking['date'])}',
                  style: TextStyle(fontSize: 14),
                ),
                Text(
                  'Time: ${booking['time'] ?? 'N/A'}',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
            SizedBox(height: 8),

            // Patient info
            Row(
              children: [
                Icon(Icons.person, size: 18, color: Colors.deepOrange),
                SizedBox(width: 8),
                Text(
                  'Patient: ${booking['childName'] ?? 'N/A'}',
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(width: 16),
                Icon(Icons.family_restroom_sharp, size: 18, color: Colors.deepOrange),
                SizedBox(width: 8),
                Text(
                  booking['gender'] ?? 'N/A',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
            SizedBox(height: 8),

            // Contact
            Row(
              children: [
                Icon(Icons.phone, size: 18, color: Colors.deepOrange),
                SizedBox(width: 8),
                Text(
                  'Contact: ${booking['contactNumber'] ?? 'N/A'}',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
            SizedBox(height: 12),
            // Created at and declined/cancelled at
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Booked on ${_formatDateTime(booking['createdAt'])}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                if (isDeclined && booking['declinedAt'] != null)
                  Text(
                    'Declined on ${_formatDateTime(booking['declinedAt'])}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                if (booking['status']?.toString().toLowerCase() == 'cancelled' &&
                    booking['cancelledAt'] != null)
                  Text(
                    'Cancelled on ${_formatDateTime(booking['cancelledAt'])}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.purple,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    final date = timestamp.toDate();
    return DateFormat.yMMMMd().format(date);
  }

  String _formatDateTime(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    final date = timestamp.toDate();
    return DateFormat('yMMMd – hh:mm a').format(date);
  }
}

