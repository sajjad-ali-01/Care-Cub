import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../Database/DataBaseReadServices.dart';
import 'BookingScreen.dart';
import 'package:intl/intl.dart';


class DoctorProfile extends StatefulWidget {
  final Map<String, dynamic> doctor;
  final List<String> EDU_Info;

  DoctorProfile({Key? key, required this.doctor,required this.EDU_Info,}) : super(key: key);

  @override
  _DoctorProfileState createState() => _DoctorProfileState();
}

class _DoctorProfileState extends State<DoctorProfile> {
  List<Map<String, dynamic>> clinics = [];
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
            backgroundColor: Colors.deepOrange.shade600,
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
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(widget.EDU_Info.isNotEmpty
                                ? widget.EDU_Info.join(", ")  + ", "+ widget.doctor['specialization']
                                : 'No education info available',
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
                qualification: widget.EDU_Info.isNotEmpty
                    ? widget.EDU_Info.join(", ")  // Combine list items into a comma-separated string
                    : 'No education info available',
                doctorId: widget.doctor['doctorId'],
              ),
              Services(),
              ReviewCard(),
             // Education(),
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
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('doctor_reviews')
          .where('doctorId', isEqualTo: widget.doctor['uid'])
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error loading reviews'));
        }

        final reviews = snapshot.data?.docs ?? [];
        final totalReviews = reviews.length;

        // Calculate average ratings
        double doctorRatingTotal = 0;
        double clinicRatingTotal = 0;
        double staffRatingTotal = 0;

        for (var review in reviews) {
          final data = review.data() as Map<String, dynamic>;
          doctorRatingTotal += (data['doctorRating'] as num).toDouble();
          clinicRatingTotal += (data['clinicRating'] as num).toDouble();
          staffRatingTotal += (data['staffRating'] as num).toDouble();
        }

        final avgDoctorRating = totalReviews > 0 ? (doctorRatingTotal / totalReviews) : 0;
        final avgClinicRating = totalReviews > 0 ? (clinicRatingTotal / totalReviews) : 0;
        final avgStaffRating = totalReviews > 0 ? (staffRatingTotal / totalReviews) : 0;
        final overallRating = totalReviews > 0
            ? ((avgDoctorRating + avgClinicRating + avgStaffRating) / 3)
            : 0;

            // Get latest 2 reviews for display
            final latestReviews = reviews.take(2).toList();

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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                       // Icon(Icons.star, color: Colors.blueAccent.shade700),
                        SizedBox(width: 10),
                        Text(
                          "Dr. ${widget.doctor['name']}'s Reviews",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.blueAccent.shade700, size: 24),
                        SizedBox(width: 4),
                        Text(
                          overallRating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,

                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.black,
                          child: Text(
                            "${(overallRating * 20).toStringAsFixed(0)}%",
                            style: TextStyle(color: Colors.white, fontSize: 25),
                          ),
                        ),
                        Text(
                          "Satisfied out of ($totalReviews)",
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
                        RatingRow("Doctor Checkup", "${avgDoctorRating.toStringAsFixed(1)}/5"),
                        RatingRow("Clinic Environment", "${avgClinicRating.toStringAsFixed(1)}/5"),
                        RatingRow("Staff Behaviour", "${avgStaffRating.toStringAsFixed(1)}/5"),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20),
                if (latestReviews.isNotEmpty)
                  ...latestReviews.map((review) {
                    final data = review.data() as Map<String, dynamic>;
                    final date = (data['createdAt'] as Timestamp).toDate();
                    final formattedDate = DateFormat('MMM d, y').format(date);

                    return Container(
                      padding: EdgeInsets.all(12),
                      margin: EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '"${data['feedback'] ?? 'No feedback provided'}"',
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.grey[800],
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Verified patient: ${_obscureName(data['patientName'] ?? 'Anonymous')} · $formattedDate',
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.grey[500],
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.orangeAccent.shade700, size: 16),
                              Text(
                                ' ${data['overallRating']?.toStringAsFixed(1) ?? '0'}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orangeAccent.shade700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DoctorReviewsScreen(
                          doctorId: widget.doctor['uid'],
                          doctorName: widget.doctor['name'],
                        ),
                      ),
                    );
                  },
                  child: Text("See All Reviews", style: TextStyle(fontSize: 15)),
                  style: OutlinedButton.styleFrom(shape: StadiumBorder()),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _obscureName(String name) {
    if (name.isEmpty || name == 'Anonymous') return 'Anonymous';
    final parts = name.split(' ');
    if (parts.length == 1) return '${parts[0][0]}***';
    return '${parts[0][0]}*** ${parts.last[0]}***';
  }

  Widget RatingRow(String label, String rating) {
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
            rating,
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
            Image.asset("assets/images/Map.jpg")
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
  final String doctorId;

  ClinicDetails({
    required this.doctorName,
    required this.doctorImage,
    required this.specialization,
    required this.clinics,
    required this.isLoading,
    required this.Secondary_Specialization,
    required this.qualification,
    required this.doctorId,
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
        final DataRow todayRow = buildAvailabilityRow('Today', todayDay, availability);
        final DataRow tomorrowRow = buildAvailabilityRow('Tomorrow', tomorrowDay, availability);
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
                          doctorId: widget.doctorId,
                          name: widget.doctorName,
                          Image: widget.doctorImage,
                          Specialization: widget.specialization,
                          locations: clinic['Location'],
                          clinicName: clinic['ClinicName'],
                          Address: clinic['Address'], // Add this line
                          Secondary_Specialization: widget.Secondary_Specialization,
                          qualification: widget.qualification,
                          availability: clinic['Availability'],
                        //  initialClinicId: clinic['id'],
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
  DataRow buildAvailabilityRow(String label, String day, Map<String, dynamic> availability) {
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
class DoctorReviewsScreen extends StatelessWidget {
  final String doctorId;
  final String doctorName;

  const DoctorReviewsScreen({
    required this.doctorId,
    required this.doctorName,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reviews for Dr. $doctorName'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('doctor_reviews')
            .where('doctorId', isEqualTo: doctorId)
            //.orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading reviews: ${snapshot.error.toString()}',
                style: TextStyle(color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No reviews yet',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final reviews = snapshot.data!.docs;

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              try {
                final review = reviews[index].data() as Map<String, dynamic>;
                final date = review['createdAt'] != null
                    ? (review['createdAt'] as Timestamp).toDate()
                    : DateTime.now();
                final formattedDate = DateFormat('MMM d, y').format(date);

                return Card(
                  margin: EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              review['patientName']?.toString() ?? 'Anonymous',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              formattedDate,
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 16),
                            Text(
                              ' ${(review['overallRating']?.toStringAsFixed(1)) ?? '0.0'}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        if (review['feedback'] != null && review['feedback'].toString().isNotEmpty)
                          Text(
                            review['feedback'].toString(),
                            style: TextStyle(fontSize: 16),
                          ),
                        SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [
                            if (review['doctorRating'] != null)
                              Chip(
                                label: Text(
                                  'Doctor: ${review['doctorRating'].toStringAsFixed(1)}',
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.blue,
                              ),
                            if (review['clinicRating'] != null)
                              Chip(
                                label: Text(
                                  'Clinic: ${review['clinicRating'].toStringAsFixed(1)}',
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.green,
                              ),
                            if (review['staffRating'] != null)
                              Chip(
                                label: Text(
                                  'Staff: ${review['staffRating'].toStringAsFixed(1)}',
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.orange,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              } catch (e) {
                return Card(
                  margin: EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Error loading review: ${e.toString()}',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}