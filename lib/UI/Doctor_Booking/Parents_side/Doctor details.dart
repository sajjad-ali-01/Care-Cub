import 'package:flutter/material.dart';
import '../../../Database/DataBaseReadServices.dart';
import 'BookingScreen.dart';

class DoctorProfile extends StatefulWidget {
  final Map<String, dynamic> doctor;

  DoctorProfile({Key? key, required this.doctor}) : super(key: key);

  @override
  _DoctorProfileState createState() => _DoctorProfileState();
}

class _DoctorProfileState extends State<DoctorProfile> {
  List<Map<String, dynamic>> clinics = [];
  List<Map<String, dynamic>> educationList = [];
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    fetchClinics();
  }

  Future<void> fetchClinics() async {
    try {
      List<Map<String, dynamic>> fetchedClinics =
      await DataBaseReadServices.getDoctorClinics(widget.doctor['uid']);
      setState(() {
        clinics = fetchedClinics;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching clinics: $e");
      setState(() {
        isLoading = false;
      });
    }
  }
  Future<void> fetchEducationDetails() async {
    try {
      List<Map<String, dynamic>> fetchedEducation =
      await DataBaseReadServices.getDoctorEducation(widget.doctor['uid']);
      setState(() {
        educationList = fetchedEducation;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching education details: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 150,
            pinned: true,
            automaticallyImplyLeading: true,
            backgroundColor: Colors.deepOrange.shade400,
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back, color: Colors.white),
            ),
            flexibleSpace: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return FlexibleSpaceBar(
                  titlePadding: EdgeInsets.only(left: 40, bottom: 4),
                  title: Row(
                    children: [
                      CircleAvatar(
                        radius: 33,
                        backgroundImage: AssetImage(widget.doctor['image']),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.doctor['title']+" "+widget.doctor['name'],
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              widget.doctor['specialization'] + "," + widget.doctor['secondary_specialization'],
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade100,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              softWrap: true,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Header(),
              ClinicDetails(
                doctorImage: widget.doctor['image'],
                doctorName: widget.doctor['name'],
                specialization: widget.doctor['specialization'],
                Secondary_Specialization: widget.doctor['secondary_specialization'],
                clinics: clinics, // Pass clinics
                isLoading: isLoading,
                qualification: widget.doctor['qualification'],
              ),
              Services(),
              ReviewCard(),
              Education(),
              About(),
              Locations(), // Updated to display clinics
              SizedBox(height: 20),
            ]),
          ),
        ],
      ),
    );
  }

  Widget Header() {
    return Card(
      color: Colors.white,
      elevation: 4,
      margin: EdgeInsets.only(left: 16, right: 16, top: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.doctor['specialization'],
                style: TextStyle(color: Colors.grey.shade700)),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.verified, color: Colors.blue, size: 16),
                SizedBox(width: 4),
                Text('PMC Verified', style: TextStyle(color: Colors.blue)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget Services() {
    List<String> servicesList = List<String>.from(widget.doctor['services'] ?? []);

    return Card(
      color: Colors.white,
      elevation: 4,
      margin: EdgeInsets.only(left: 16, right: 16, top: 16),
      child: ExpansionTile(
        leading: Icon(Icons.medical_services, color: Colors.red),
        title: Text(
          'Services',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        children: servicesList.map((service) {
          return ListTile(
            title: Text(service.trim()),
          );
        }).toList(),
      ),
    );
  }


  Widget ReviewCard() {
    return Card(
      color: Colors.white,
      margin: EdgeInsets.only(left: 16, right: 16, top: 16),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.star, color: Colors.blueAccent.shade700),
                SizedBox(width: 10),
                Text(
                  "Dr. "+widget.doctor['name'] + "'s Reviews",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.black,
                      child: Text("100%",
                          style: TextStyle(color: Colors.white, fontSize: 25)),
                    ),
                    Text(
                      "Satisfied out of (340)",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 20),
                Column(
                  children: [
                    RatingRow("Doctor Checkup", "100%"),
                    RatingRow("Clinic Environment", "100%"),
                    RatingRow("Staff Behaviour", "100%"),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blueGrey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.doctor['name'] +
                        '"is highly professional and compassionate.'
                            'They listened to my concerns carefully and provided excellent treatment."',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[800],
                    ),
                  ),
                  Text(
                    '"I had a great experience with ${widget.doctor['name']} Their expertise and friendly approach made me feel comfortable and confident ',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '"Verified patient: A** ***a . 1 day ago',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            OutlinedButton(
              onPressed: () {},
              child: Text("See All Reviews", style: TextStyle(fontSize: 15)),
              style: OutlinedButton.styleFrom(shape: StadiumBorder()),
            ),
          ],
        ),
      ),
    );
  }

  Widget RatingRow(String label, String percentage) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          Text(
            percentage,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget Education() {
    return Card(
      elevation: 4,
      color: Colors.white,
      margin: EdgeInsets.only(left: 16, right: 16, top: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.school_sharp, color: Colors.black),
                SizedBox(width: 10),
                Text('Education',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            SizedBox(height: 8),
            Text('${widget.doctor['qualification']} - Institute of Medical Sciences, Pakistan, 2021'),
            Text(
                'MCPS (Dermatology) - College of Physicians and Surgeons, Pakistan, 2021'),
          ],
        ),
      ),
    );
  }

  Widget About() {
    return Card(
      color: Colors.white,
      elevation: 4,
      margin: EdgeInsets.only(left: 16, right: 16, top: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.info_sharp, color: Colors.blueGrey),
                SizedBox(width: 10),
                Text('About ' + widget.doctor['name'],
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            SizedBox(height: 8),
            Text(
                'Child Specialist with 5 years of experience practicing at CMA Hospital- Clinic & Farooq Hospital , Lahore'),
          ],
        ),
      ),
    );
  }

  Widget Locations() {
    return Card(
      color: Colors.white,
      elevation: 4,
      margin: EdgeInsets.only(left: 16, right: 16, top: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.location_on, color: Colors.redAccent),
                SizedBox(width: 10),
                Text('Practice Locations',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
class ClinicDetails extends StatefulWidget {
  final String doctorName;
  final String doctorImage;
  final String specialization;
  final String Secondary_Specialization;
  final String qualification;
  final List<Map<String, dynamic>> clinics;
  final bool isLoading;

  ClinicDetails({
    required this.doctorName,
    required this.doctorImage,
    required this.specialization,
    required this.clinics,
    required this.isLoading,
    required this.Secondary_Specialization,
    required this.qualification,
  });

  @override
  _ClinicDetailsState createState() => _ClinicDetailsState();
}

class _ClinicDetailsState extends State<ClinicDetails> {
  bool isExpanded = false;
  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Monday';
      case 2: return 'Tuesday';
      case 3: return 'Wednesday';
      case 4: return 'Thursday';
      case 5: return 'Friday';
      case 6: return 'Saturday';
      case 7: return 'Sunday';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.isLoading
        ? Center(child: CircularProgressIndicator())
        : widget.clinics.isEmpty
        ? Center(child: Text('No clinics found.'))
        : Column(
      children: widget.clinics.map((clinic) {
        final availability = clinic['Availability'] as Map<String, dynamic>? ?? {};
        final now = DateTime.now();
        final tomorrow = now.add(Duration(days: 1));
        final todayDay = _getDayName(now.weekday);
        final tomorrowDay = _getDayName(tomorrow.weekday);
        final DataRow todayRow = _buildAvailabilityRow('Today', todayDay, availability);
        final DataRow tomorrowRow = _buildAvailabilityRow('Tomorrow', tomorrowDay, availability);
        final List<DataRow> allAvailabilityRows = availability.entries.map((entry) {
          return DataRow(
            cells: [
              DataCell(Text(entry.key)),
              DataCell(Text('${entry.value['start']} - ${entry.value['end']}')),
            ],
          );
        }).toList();

        return Card(
          color: Colors.white,
          elevation: 4,
          margin: EdgeInsets.only(left: 16, right: 16, top: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Text(
                      clinic['ClinicName'],
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  'Fee: Rs. ${clinic['Fees']}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                SizedBox(height: 16),
                Text('Availability', style: TextStyle(fontWeight: FontWeight.bold)),
                DataTable(
                  columns: [
                    DataColumn(label: Text('Day')),
                    DataColumn(label: Text('Timing')),
                  ],
                  rows: isExpanded ? allAvailabilityRows : [todayRow, tomorrowRow],
                ),
                TextButton(
                  onPressed: () => setState(() => isExpanded = !isExpanded),
                  child: Text(isExpanded ? 'Show Less ▲' : 'View All Timings ▼'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookingScreen(
                          name: widget.doctorName,
                          Image: widget.doctorImage,
                          Specialization: widget.specialization,
                          locations: clinic['ClinicName'],
                          Secondary_Specialization: widget.Secondary_Specialization,
                          Address: clinic['Address'],
                          qualification: widget.qualification,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    'Book Appointment',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 40),
                    backgroundColor: Colors.red.shade400,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
  DataRow _buildAvailabilityRow(String label, String day, Map<String, dynamic> availability) {
    final timings = availability[day];
    return DataRow(
      cells: [
        DataCell(Text(label)),
        DataCell(Text(timings != null
            ? '${timings['start']} - ${timings['end']}'
            : 'Not available')),
      ],
    );
  }
}