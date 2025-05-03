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
  Future<void> getprefs() async{
    prefs = await SharedPreferences.getInstance();
    isCommunityJoined = await prefs.getBool("isCommunityJoined")??false;
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
            isCommunityJoined ? CommunityHomePage():CommunityPage(),
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
          //.orderBy('date')
          //.orderBy('time')
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

                      // Clinic information
                      Row(
                        children: [
                          Icon(Icons.medical_services, color: Colors.green),
                          SizedBox(width: 10),
                          Text(
                            data['clinicName'] ?? 'Clinic Name',
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