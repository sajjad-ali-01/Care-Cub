import 'package:flutter/material.dart';
import '../../Community/Community.dart';
import 'PatientHistory.dart';
import 'DoctorProfile.dart';

class DoctorDashboard extends StatefulWidget {
  @override
  _DoctorDashboardState createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  List<Map<String, dynamic>> appointments = [
    {
      'name': 'Sajjad Ali',
      'gender': 'Male',
      'age': 2,
      'contact': '2343242432',
      'time': '10:00 AM',
      'description': 'Follow-up for growth and development check.'
    },
    {
      'name': 'Faseeh',
      'gender': 'Male',
      'age': 5,
      'contact': '34543543445',
      'time': '11:30 AM',
      'description': 'General consultation and flu symptoms.'
    },
    {
      'name': 'Ayesha',
      'gender': 'Female',
      'age': 7,
      'contact': '45435435344',
      'time': '1:00 PM',
      'description': 'Follow-up for asthma management.'
    },
  ];

  List<Map<String, dynamic>> history = [];

  void acceptAppointment(int index) {
    setState(() {
      history.add(appointments[index]);
      appointments.removeAt(index);
    });
  }

  void declineAppointment(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Decline"),
          content: Text("Are you sure you want to decline this appointment?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  appointments.removeAt(index);
                });
                Navigator.pop(context);
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
          title: Text('Doctor Dashboard',style: TextStyle(color: Colors.white),),
          bottom: TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey.shade100,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
            tabs: [
              Tab(icon: Icon(Icons.home), text: 'Appointments'),
              Tab(icon: Icon(Icons.history), text: 'Patient History'),
              Tab(icon: Icon(Icons.group), text: 'Community'),
              Tab(icon: Icon(Icons.person), text: 'Profile'),
            ],
          ),
          backgroundColor: Colors.deepOrange.shade500
        ),
        body: TabBarView(
          children: [
            HomePage(appointments, acceptAppointment, declineAppointment),
            PatientHistoryPage(history),
            CommunityPage(),
            DoctorProfilePage(),
          ],
        ),
      ),
    );
  }
}

// 🏠 **Home Page**
class HomePage extends StatelessWidget {
  final List<Map<String, dynamic>> appointments;
  final Function(int) acceptAppointment;
  final Function(int) declineAppointment;

  HomePage(this.appointments, this.acceptAppointment, this.declineAppointment);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          final appointment = appointments[index];
          List<Color> tileColors = [
            Colors.yellow.shade100,
            Colors.green.shade100,
            Colors.orange.shade100,
            Colors.teal.shade100,
            Colors.purple.shade100,

          ];

          Color tileColor = tileColors[index % tileColors.length];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AppointmentDetailPage(
                    appointment: appointment,
                    onAccept: () => acceptAppointment(index),
                    onDecline: () => declineAppointment(index),
                  ),
                ),
              );
            },
            child: Card(
              color: tileColor,
              margin: EdgeInsets.symmetric(vertical: 8.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage('assets/images/profile_pic.png'),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appointment['name'],
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text("Time: ${appointment['time']}"),
                          Text("Description: ${appointment['description']}"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
class AppointmentDetailPage extends StatelessWidget {
  final Map<String, dynamic> appointment;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  AppointmentDetailPage({required this.appointment, required this.onAccept, required this.onDecline});

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
            Text(appointment['name'], style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text("Gender: ${appointment['gender']}"),
            Text("Age: ${appointment['age']}"),
            Text("Contact: ${appointment['contact']}"),
            Text("Time: ${appointment['time']}"),
            SizedBox(height: 10),
            Text("Description:", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(appointment['description']),
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
                  child: Text("Accept",style: TextStyle(color: Colors.white),),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () {
                    onDecline();
                  },
                  child: Text("Decline",style: TextStyle(color: Colors.white),),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CommunityPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context)=>Community()));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Joined Community!")),

          );
        },
        style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange.shade400),
        child: Text("Join Community",style: TextStyle(color: Colors.white),),
      ),
    );
  }
}
