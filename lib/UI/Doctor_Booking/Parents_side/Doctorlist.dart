import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../Database/DataBaseReadServices.dart';
import '../../../Database/DatabaseServices.dart';
import 'BookingScreen.dart';
import 'Doctor details.dart';
import 'MyBookings.dart';

class Doctorlist extends StatefulWidget {
  @override
  _DoctorListState createState() => _DoctorListState();
}

class _DoctorListState extends State<Doctorlist> {
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.deepOrange.shade400,
        elevation: 1,
        leading: isSearching
            ? null
            : IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: isSearching
            ? Container(
          width: double.infinity,
          child: TextField(
            controller: searchController,
            onSubmitted: (value) {
              setState(() {
                isSearching = false;
              });
            },
            decoration: InputDecoration(
              hintText: "Search Doctor",
              hintStyle: TextStyle(color: Colors.white),
              suffixIcon: IconButton(
                icon: Icon(Icons.send_outlined, color: Colors.white),
                onPressed: () {
                  setState(() {
                    isSearching = false;
                  });
                },
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: Colors.white, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: Colors.white, width: 2),
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
            ),
            style: TextStyle(color: Colors.white),
          ),
        )
            : Center(
          child: Text(
            "Doctor List",
            style: TextStyle(color: Colors.white),
          ),
        ),
        actions: isSearching
            ? null
            : [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () {
              setState(() {
                isSearching = true;
              });
            },
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>BookingsScreen()));
                    },
                    child: Text("My Bookings", style: TextStyle(fontSize: 15)),
                    style: OutlinedButton.styleFrom(shape: StadiumBorder()),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    child: Text("Doctors Near Me", style: TextStyle(fontSize: 15)),
                    style: OutlinedButton.styleFrom(shape: StadiumBorder()),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('Doctors').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No doctors found.'));
                  } else {
                    return ListView(
                      children: snapshot.data!.docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return DoctorCard(
                          name: data['name'] ?? 'No Name',
                          title: data['title'] ?? 'No Title',
                          specialization: data['Primary_specialization'] ?? 'No Specialization',
                          secondary_specialization: data['Secondary_specialization'] ?? 'No Secondary Specialization',
                          qualification: data['Degree'] ?? 'No Qualification',
                          experience: data['experience'] ?? 'No Experience',
                          rating: '98% (350 Satisfied)',
                          fee: '1800',
                          image: data['photoUrl'] ?? 'assets/images/doctor.jpg',
                          uid: doc.id,
                          services: List<String>.from(data['Service_Offered'] ?? []),
                          conditions: List<String>.from(data['Condition'] ?? []),
                        );
                      }).toList(),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DoctorCard extends StatefulWidget {
  final String name;
  final String title;
  final String specialization;
  final String secondary_specialization;
  final String qualification;
  final String experience;
  final String rating;
  final String fee;
  final String image;
  final String uid;
  final List<String> services;
  final List<String> conditions;


  DoctorCard({
    required this.name,
    required this.specialization,
    required this.qualification,
    required this.experience,
    required this.rating,
    required this.fee,
    required this.image,
    required this.title,
    required this.secondary_specialization,
    required this.uid,
    required this.services,
    required this.conditions,
  });

  @override
  _DoctorCardState createState() => _DoctorCardState();
}

class _DoctorCardState extends State<DoctorCard> {
  List<Map<String, dynamic>> clinics = [];
  bool isLoading = true;
  String dataRowToString(DataRow row) {
    return row.cells.map((cell) => (cell.child as Text).data).join(", ");
  }

  @override
  void initState() {
    super.initState();
    fetchClinics();
  }
  Future<void> fetchClinics() async {
    try {
      List<Map<String, dynamic>> fetchedClinics =
      await DataBaseReadServices.getDoctorClinics(widget.uid);
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

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DoctorProfile(
              doctor: {
                'name': widget.name,
                'title':widget.title,
                'specialization': widget.specialization,
                'secondary_specialization':widget.secondary_specialization,
                'qualification': widget.qualification,
                'experience': widget.experience,
                'rating': widget.rating,
                'fee': widget.fee,
                'image': widget.image,
                'uid': widget.uid,
                'services': widget.services,
                'conditions': widget.conditions,
                'Address':clinics[0]['Address'],
              },
            ),
          ),
        );
      },
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: AssetImage(widget.image),
                    radius: 30,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.title + " " +widget.name, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                        Text(widget.specialization+"," +widget.secondary_specialization, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                        Text(widget.qualification, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Experience: ${widget.experience} years", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  Text(widget.rating, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                ],
              ),
              SizedBox(height: 10),
              Container(
                height: 100,
                child: isLoading
                    ? Center(child: CircularProgressIndicator())
                    : clinics.isEmpty
                    ? Center(child: Text('No clinics found.'))
                    : ListView(
                  scrollDirection: Axis.horizontal,
                  children: clinics.map((clinic) {
                    final availability = clinic['Availability'] as Map<String, dynamic>? ?? {};
                    final now = DateTime.now();

                    final todayDay = getDayName(now.weekday);

                    final DataRow todayRow = buildAvailabilityRow('Today', todayDay, availability);
                    String todayRowString = dataRowToString(todayRow);
                    print(todayRowString);
                    return Container(
                      width: 250,
                      margin: EdgeInsets.symmetric(horizontal: 5),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade600, width: 1),
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade50, Colors.grey.shade50],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.local_hospital_sharp, color: Colors.deepOrange, size: 20),
                              SizedBox(width: 8),
                              Text(
                                clinic['ClinicName'],
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(Icons.location_on, color: Colors.blue, size: 15),
                              SizedBox(width: 8),
                              Text(
                                clinic['Address'],
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(Icons.access_time, color: Colors.green, size: 15),
                              SizedBox(width: 8),
                              Text(
                                todayRowString,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Fee: Rs. ${clinic['Fees']}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.deepOrange.shade400,
                                ),
                              ),
                              Text(
                                'Book online & Get 10% OFF',
                                style: TextStyle(
                                  color: Colors.green.shade600,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      if (clinics.length > 1) {
                        showHospitalSelection(context);
                      } else {

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookingScreen(
                              name: widget.name,
                              Image: widget.image,
                              Specialization: widget.specialization,
                              locations: clinics[0]['ClinicName'],
                              Address: clinics[0]['Address'],
                              Secondary_Specialization: widget.secondary_specialization,
                              qualification: widget.qualification,
                            ),
                          ),
                        );
                      }
                    },
                    icon: Icon(Icons.calendar_today_sharp, size: 18, color: Colors.teal.shade100),
                    label: Text("Book Appointment", style: TextStyle(fontSize: 17, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange.shade400,
                      minimumSize: Size(280, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showHospitalSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        height: MediaQuery.of(context).size.height * 0.5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 15),
            Text(
              'Select Hospital',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange.shade400,
              ),
            ),
            SizedBox(height: 15),
            Expanded(
              child: ListView.separated(
                itemCount: clinics.length,
                separatorBuilder: (context, index) => Divider(height: 20),
                itemBuilder: (context, index) {
                  final clinic = clinics[index];
                  return InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookingScreen(
                            name: widget.name,
                            Image: widget.image,
                            Specialization: widget.specialization,
                            Secondary_Specialization: widget.secondary_specialization,
                            locations: clinic['ClinicName'],
                            Address: clinic['Address'],
                            qualification: widget.qualification,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          Icon(Icons.local_hospital, color: Colors.deepOrange.shade400),
                          SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  clinic['ClinicName'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Fee: Rs. ${clinic['Fees']}',
                                  style: TextStyle(
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right, color: Colors.grey.shade600),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String getDayName(int weekday) {
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

  DataRow buildAvailabilityRow(String label, String day, Map<String, dynamic> availability) {
    final timings = availability[day];
    return DataRow(
      cells: [
        DataCell(Text(label)),
        DataCell(Text(timings != null ? '${timings['start']} - ${timings['end']}' : 'Not available')),
      ],
    );
  }
}