import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../Database/DataBaseReadServices.dart';

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
  String _searchQuery = '';

  void _toggleSearch() {
    setState(() {
      isSearching = !isSearching;
      if (!isSearching) {
        searchController.clear();
        _searchQuery = '';
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.deepOrange.shade600,
        elevation: 1,
        leading: isSearching
            ? null
            : IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: isSearching
            ? TextField(
          controller: searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: "Search Doctor by Name",
            hintStyle: TextStyle(color: Colors.white),
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: Icon(Icons.search, color: Colors.white),
              onPressed: () {
                setState(() {
                  searchController.clear();
                  _searchQuery = '';
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
          onChanged: (value) {
            setState(() {
              _searchQuery = value.toLowerCase();
            });
          },
        )
            : Center(
          child: Text(
            "Doctor List",
            style: TextStyle(color: Colors.white),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.close : Icons.search, color: Colors.white),
            onPressed: _toggleSearch,
          ),
        ],
      ),
      body: _buildDoctorList(),
    );
  }

  Widget _buildDoctorList() {
    return Padding(
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
                    Navigator.push(context, MaterialPageRoute(builder: (context) => BookingsScreen()));
                  },
                  child: Text("My Bookings", style: TextStyle(fontSize: 15)),
                  style: OutlinedButton.styleFrom(shape: StadiumBorder()),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: _toggleSearch, // Use the toggle method here
                  child: Text("Search Doctor", style: TextStyle(fontSize: 15)),
                  style: OutlinedButton.styleFrom(shape: StadiumBorder()),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('Doctors')
                  .where('isVerified', isEqualTo: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ListView.builder(
                    itemCount: 3,
                    itemBuilder: (context, index) => ShimmerDoctorCard(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData) {
                  return Center(child: Text('No doctors found.'));
                }

                // Filter doctors locally based on search query
                final filteredDoctors = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String,dynamic>;
                  final name = data['name']?.toString().toLowerCase() ?? '';

                  // Return true if search query is empty or name matches
                  return _searchQuery.isEmpty ||
                      name.contains(_searchQuery.toLowerCase());
                }).toList();

                if (filteredDoctors.isEmpty && _searchQuery.isNotEmpty) {
                  return Center(child: Text('No results for "$_searchQuery"'));
                }

                return ListView(
                  children: filteredDoctors.map((doc) {
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
                      image: data['photoUrl'],
                      uid: doc.id,
                      services: List<String>.from(data['Service_Offered'] ?? []),
                      EDU_Info: List<String>.from(
                        (data['EDU_INFO'] as List<dynamic>? ?? []).map((e) {
                          final degree = e.toString()
                              .split(RegExp(r'[\(\-]'))[0]
                              .trim();
                          return degree;
                        }).toList(),
                      ),
                      conditions: List<String>.from(data['Condition'] ?? []),
                      doctorId: doc.id,
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ShimmerDoctorCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 20,
                          color: Colors.white,
                        ),
                        SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          height: 16,
                          color: Colors.white,
                        ),
                        SizedBox(height: 4),
                        Container(
                          width: double.infinity,
                          height: 16,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 120,
                    height: 16,
                    color: Colors.white,
                  ),
                  Container(
                    width: 120,
                    height: 16,
                    color: Colors.white,
                  ),
                ],
              ),
              SizedBox(height: 10),
              Container(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    Container(
                      width: 250,
                      margin: EdgeInsets.symmetric(horizontal: 5),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade600, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                color: Colors.white,
                              ),
                              SizedBox(width: 8),
                              Container(
                                width: 150,
                                height: 16,
                                color: Colors.white,
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                width: 15,
                                height: 15,
                                color: Colors.white,
                              ),
                              SizedBox(width: 8),
                              Container(
                                width: 180,
                                height: 14,
                                color: Colors.white,
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                width: 15,
                                height: 15,
                                color: Colors.white,
                              ),
                              SizedBox(width: 8),
                              Container(
                                width: 180,
                                height: 14,
                                color: Colors.white,
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 80,
                                height: 16,
                                color: Colors.white,
                              ),
                              Container(
                                width: 120,
                                height: 14,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Center(
                child: Container(
                  width: 280,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DoctorCard extends StatefulWidget {
  final String doctorId;
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
  final List<String> EDU_Info;

  const DoctorCard({
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
    required this.EDU_Info,
    required this.doctorId,
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
                'doctorId': widget.doctorId,
                'name': widget.name,
                'title': widget.title,
                'specialization': widget.specialization,
                'secondary_specialization': widget.secondary_specialization,
              //  'qualification': widget.qualification,
                'experience': widget.experience,
                'rating': widget.rating,
                'fee': widget.fee,
                'image': widget.image,
                'uid': widget.uid,
                'services': widget.services,
                'conditions': widget.conditions,
                'Address': clinics.isNotEmpty ? clinics[0]['Address'] : '',
               // "EDU_Info": widget.EDU_Info,
                "clinics":clinics,
                "doctorId": widget.doctorId,
              }, EDU_Info: widget.EDU_Info,
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
                    backgroundImage: NetworkImage(widget.image),
                    radius: 30,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title + " " + widget.name,
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          widget.EDU_Info.isNotEmpty
                              ? widget.EDU_Info.join(", ")  + ", "+widget.specialization
                              : 'No education info available',
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Experience: ${widget.experience}",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                  StreamBuilder<double>(
                    stream: getOverallRatingStream(widget.doctorId), // pass your actual daycareId here
                    builder: (context, snapshot) {
                      // Handle different states of the stream
                      if (snapshot.hasError) {
                        return Text('Error loading rating');
                      }

                      if (!snapshot.hasData) {
                        return const SizedBox(
                          width: 50, // approximate width of the rating display
                          child: LinearProgressIndicator(),
                        );
                      }

                      final rating = snapshot.data ?? 0.0;
                      final ratingText = rating.toStringAsFixed(1);

                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, color: Colors.blue.shade900, size: 18),
                          SizedBox(width: 4),
                          Text(
                            ratingText,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 8,),
                        ],
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: 10),
              Container(
                height: 120,
                child: isLoading
                    ? Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      Container(
                        width: 250,
                        margin: EdgeInsets.symmetric(horizontal: 5),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade600, width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 8),
                                Container(
                                  width: 150,
                                  height: 16,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  width: 15,
                                  height: 15,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 8),
                                Container(
                                  width: 180,
                                  height: 14,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  width: 15,
                                  height: 15,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 8),
                                Container(
                                  width: 180,
                                  height: 14,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
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
                              Expanded(
                                child: Text(
                                  clinic['ClinicName'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                  maxLines: 2,  // Allow text to span up to 2 lines
                                  overflow: TextOverflow.ellipsis,  // Show ellipsis if text is still too long
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(Icons.location_on, color: Colors.blue, size: 15),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  clinic['Address'],
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 13,
                                  ),
                                  maxLines: 2,  // Allow text to span up to 2 lines
                                  overflow: TextOverflow.ellipsis,  // Show ellipsis if text is still too long
                                ),
                              )


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
                                'Pay online & Get 10% OFF',
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
                      } else if (clinics.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookingScreen(
                              doctorId: widget.doctorId,
                              name: widget.name,
                              Image: widget.image,
                              Specialization: widget.specialization,
                              Secondary_Specialization: widget.secondary_specialization,
                               // Make sure this exists
                              Address: clinics[0]['Address'],
                              qualification: widget.EDU_Info.isNotEmpty
                                  ? widget.EDU_Info.join(", ")
                                  : 'No education info available',
                              availability: clinics[0]['Availability'],
                              clinicName: clinics[0]['ClinicName'],
                              fees: clinics[0]['Fees'],
                              clinicLocation: clinics[0]['Location'] as GeoPoint, // This is crucial
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
  Stream<double> getOverallRatingStream(String daycareId) {
    return FirebaseFirestore.instance
        .collection('doctor_reviews')
        .where('doctorId', isEqualTo: daycareId)
        .snapshots()
        .map((querySnapshot) {
      if (querySnapshot.docs.isEmpty) return 0.0;

      double totalRating = 0;
      int reviewCount = 0;

      for (var doc in querySnapshot.docs) {
        final rating = doc['overallRating'];
        if (rating != null) {
          totalRating += (rating as num).toDouble();
          reviewCount++;
        }
      }

      return reviewCount > 0 ? totalRating / reviewCount : 0.0;
    });
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
                  final clinic = clinics[index]; // Access clinic via index
                  return InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookingScreen(
                            doctorId: widget.doctorId,
                            name: widget.name,
                            Image: widget.image,
                            Specialization: widget.specialization,
                            Secondary_Specialization: widget.secondary_specialization,
                            Address: clinic['Address'],
                            qualification: widget.EDU_Info.isNotEmpty
                                ? widget.EDU_Info.join(", ")
                                : 'No education info available',
                            availability: clinic['Availability'],
                            clinicName: clinic['ClinicName'],
                            fees: clinic['Fees'],
                            clinicLocation: clinic['Location'], // This is crucial
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