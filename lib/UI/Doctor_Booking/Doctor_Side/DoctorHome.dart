import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Community/Community.dart';
import 'PatientHistory.dart';
import 'DoctorProfile.dart';
import 'package:intl/intl.dart';

class DoctorDashboard extends StatefulWidget {
  @override
  _DoctorDashboardState createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late String doctorId;
  late SharedPreferences prefs;
  late bool isCommunityJoined;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    doctorId = user!.uid;
    getprefs();
  }

  Future<void> getprefs() async {
    prefs = await SharedPreferences.getInstance();
    isCommunityJoined = await prefs.getBool("isCommunityJoined") ?? false;
  }

  Future<void> acceptAppointment(String appointmentId) async {
    try {
      await firestore.collection('Bookings').doc(appointmentId).update({
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
                  await firestore.collection('Bookings').doc(appointmentId).update({
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
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          title: Text('Doctor Dashboard', style: TextStyle(color: Colors.white)),
          bottom: TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey.shade100,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
            tabs: [
              Tab(icon: Icon(Icons.home), text: 'Requests'),
              Tab(icon: Icon(Icons.history), text: 'Patients'),
              Tab(icon: Icon(Icons.group), text: 'Community'),
              Tab(icon: Icon(Icons.person), text: 'Profile'),
            ],
          ),
          backgroundColor: Colors.deepOrange.shade500,
        ),
        body: TabBarView(
          children: [
            DoctorAppointmentsPage(doctorId: doctorId, onAccept: acceptAppointment, onDecline: declineAppointment),
            PatientHistoryPage(),
            CommunityPage(),
            DoctorProfilePage(),
          ],
        ),
      ),
    );
  }
}

class DoctorAppointmentsPage extends StatelessWidget {
  final String doctorId;
  final Function(String) onAccept;
  final Function(String) onDecline;

  const DoctorAppointmentsPage({
    required this.doctorId,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Bookings')
          .where('doctorId', isEqualTo: doctorId)
          .where('status', isEqualTo: 'pending')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error loading appointments'));
        }

        if (snapshot.data?.docs.isEmpty ?? true) {
          return Center(child: Text('No pending appointments found'));
        }

        final appointments = snapshot.data!.docs;

        return Padding(
          padding: EdgeInsets.all(16.0),
          child: ListView.builder(
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appointment = appointments[index];
              final data = appointment.data() as Map<String, dynamic>;
              final appointmentId = appointment.id;
              final isPaid = data['paymentStatus']?.toString().toLowerCase() == 'paid';

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
                      // Header with patient name and status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              data['childName'] ?? 'Patient Name',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepOrange,
                              ),
                            ),
                          ),
                          Chip(
                            label: Text(
                              data['status']?.toUpperCase() ?? 'PENDING',
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

                      // Payment status
                      if (isPaid)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Icon(Icons.payment, color: Colors.green, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Payment completed',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (data['paidAt'] != null)
                                Text(
                                  ' on ${formatDateTime(data['paidAt'])}',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        ),

                      // Clinic information
                      Row(
                        children: [
                          Icon(Icons.medical_services, color: Colors.green),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              data['clinicName'] ?? 'Clinic Name',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade800,
                              ),
                              maxLines: 2,  // Allow text to span up to 2 lines
                              overflow: TextOverflow.ellipsis,  // Show ellipsis if text is still too long
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.red),
                          SizedBox(width: 10),
                          Text(
                            data['clinicAddress'] ?? 'Clinic Address',
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

                      // Patient information
                      Row(
                        children: [
                          Icon(Icons.person, size: 18, color: Colors.deepOrange),
                          SizedBox(width: 8),
                          Text(
                            'Patient: ${data['childName'] ?? 'N/A'}',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                          SizedBox(width: 16),
                          Icon(Icons.family_restroom_sharp, size: 18, color: Colors.deepOrange),
                          SizedBox(width: 8),
                          Text(
                            data['gender'] ?? 'N/A',
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
                            'Contact: ${data['contactNumber'] ?? 'N/A'}',
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
                                  'Appointment Date',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  formatDate(data['date']),
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
                                  'Appointment Time',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  data['time'] ?? 'N/A',
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

                      // Payment amount
                      Row(
                        children: [
                          Icon(Icons.attach_money, size: 18, color: Colors.deepOrange),
                          SizedBox(width: 8),
                          Text(
                            'Amount: PKR ${data['fees'] ?? 'N/A'}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),

                      // Description
                      if (data['description'] != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Reason:',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              data['description'],
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

                      // Created at information
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Booked on ${formatDateTime(data['createdAt'])}',
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
          ),
        );
      },
    );
  }

  String formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    final date = timestamp.toDate();
    return DateFormat.yMMMMd().format(date);
  }

  String formatDateTime(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    final date = timestamp.toDate();
    return DateFormat('yMMMd – hh:mm a').format(date);
  }
}

class AppointmentDetailPage extends StatelessWidget {
  final Map<String, dynamic> appointment;
  final String appointmentId;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const AppointmentDetailPage({
    required this.appointment,
    required this.appointmentId,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Appointment Details")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/images/profile_pic.png'),
            ),
            SizedBox(height: 16),
            Text(
              appointment['childName'] ?? 'No Name',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text("Gender: ${appointment['gender'] ?? 'Not specified'}"),
            Text("Age: ${appointment['age'] ?? 'Not specified'}"),
            Text("Contact: ${appointment['contactNumber'] ?? 'Not specified'}"),
            Text("Date: ${formatDate(appointment['date'])}"),
            Text("Time: ${appointment['time']}"),
            SizedBox(height: 10),
            Text("Description:", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(appointment['description'] ?? 'No description provided'),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    onAccept();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: Text("Accept", style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () {
                    onDecline();
                  },
                  child: Text("Decline", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String formatDate(Timestamp timestamp) {
    return DateFormat('MMM dd, yyyy').format(timestamp.toDate());
  }
}

class CommunityPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          Navigator.push(context, MaterialPageRoute(builder: (context) => CommunityHomePage()));
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setBool("isCommunityJoined", true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Joined Community!")),
          );
        },
        style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange.shade400),
        child: Text("Join Community", style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

class PatientHistoryPage extends StatefulWidget {
  @override
  _PatientHistoryPageState createState() => _PatientHistoryPageState();
}

class _PatientHistoryPageState extends State<PatientHistoryPage> {
  late String doctorId;
  String searchQuery = "";
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

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
              stream: firestore
                  .collection('Bookings')
                  .where('doctorId', isEqualTo: doctorId)
                  .where('status', isEqualTo: 'confirmed')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: Colors.deepOrange));
                }

                final bookings = snapshot.data?.docs ?? [];

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
                    final isPaid = appointment['paymentStatus']?.toString().toLowerCase() == 'paid';

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
                            Text("Date: ${formatDate(appointment['date'])}"),
                            Text("Time: ${appointment['time']}"),
                            if (isPaid)
                              Row(
                                children: [
                                  Icon(Icons.payment, size: 16, color: Colors.green),
                                  SizedBox(width: 4),
                                  Text(
                                    'Paid: PKR ${appointment['fees'] ?? '0'}',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
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

  String formatDate(Timestamp timestamp) {
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
    final isPaid = appointment['paymentStatus']?.toString().toLowerCase() == 'paid';

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

              buildDetailRow("Patient Name", appointment['childName'] ?? 'Not specified'),
              buildDetailRow("Gender", appointment['gender'] ?? 'Not specified'),
              buildDetailRow("Age", appointment['age']?.toString() ?? 'Not specified'),
              buildDetailRow("Contact", appointment['contactNumber'] ?? 'Not specified'),
              buildDetailRow("Appointment Date", formatDate(appointment['date'])),
              buildDetailRow("Appointment Time", appointment['time'] ?? 'Not specified'),
              buildDetailRow("Confirmed At", formatDateTime(appointment['confirmedAt'])),

              // Payment information
              buildDetailRow("Payment Status", isPaid ? 'Paid' : 'Not Paid'),
              if (isPaid) ...[
                buildDetailRow("Amount", 'PKR ${appointment['fees'] ?? '0'}'),
                buildDetailRow("Payment Date", formatDateTime(appointment['paidAt'])),
              ],

              SizedBox(height: 16),
              buildDetailSection("Description", appointment['description'] ?? 'No description provided'),
              if (appointment['notes'] != null)
                buildDetailSection("Doctor Notes", appointment['notes']),

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
                      onPressed: () => completeAppointment(context),
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

  Future<void> completeAppointment(BuildContext context) async {
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
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Center(child: CircularProgressIndicator()),
        );

        await FirebaseFirestore.instance
            .collection('Bookings')
            .doc(appointmentId)
            .update({
          'status': 'completed',
          'completedAt': FieldValue.serverTimestamp(),
        });

        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Appointment marked as completed'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
      } catch (e) {
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to complete appointment: ${e.toString()}'),
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

  String formatDate(Timestamp timestamp) {
    return DateFormat('MMMM dd, yyyy').format(timestamp.toDate());
  }

  String formatDateTime(Timestamp? timestamp) {
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
              final doc = historyBookings[index];
              final booking = doc.data() as Map<String, dynamic>;
              final isPaid = booking['paymentStatus']?.toString().toLowerCase() == 'paid';

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
                            booking['childName'] ?? 'Patient Name',
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

                      // Payment status
                      if (isPaid)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Icon(Icons.payment, color: Colors.green, size: 16),
                              SizedBox(width: 8),
                              Text(
                                'Payment completed',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (booking['paidAt'] != null)
                                Text(
                                  ' on ${formatDateTime(booking['paidAt'])}',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        ),

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
                          Text(
                            booking['clinicAddress'] ?? 'Clinic Address',
                            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),

                      // Decline reason (only for declined bookings)
                      if (booking['status']?.toString().toLowerCase() == 'declined' &&
                          booking['declineReason'] != null)
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
                            'Date: ${formatDate(booking['date'])}',
                            style: TextStyle(fontSize: 14),
                          ),
                          Text(
                            'Time: ${booking['time'] ?? 'N/A'}',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),

                      // Payment amount
                      Row(
                        children: [
                          Icon(Icons.attach_money, size: 18, color: Colors.deepOrange),
                          SizedBox(width: 8),
                          Text(
                            'Amount: PKR ${booking['fees'] ?? 'N/A'}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),

                      // Created at and declined/cancelled at
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Booked on ${formatDateTime(booking['createdAt'])}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          if (booking['status']?.toString().toLowerCase() == 'declined' &&
                              booking['declinedAt'] != null)
                            Text(
                              'Declined on ${formatDateTime(booking['declinedAt'])}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.red,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          if (booking['status']?.toString().toLowerCase() == 'cancelled' &&
                              booking['cancelledAt'] != null)
                            Text(
                              'Cancelled on ${formatDateTime(booking['cancelledAt'])}',
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
            },
          );
        },
      ),
    );
  }

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

  String formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    final date = timestamp.toDate();
    return DateFormat.yMMMMd().format(date);
  }

  String formatDateTime(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    final date = timestamp.toDate();
    return DateFormat('yMMMd – hh:mm a').format(date);
  }
}