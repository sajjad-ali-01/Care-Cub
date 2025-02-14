import 'package:carecub/UI/Doctor/BookingScreen.dart';
import 'package:flutter/material.dart';
class DoctorProfile extends StatefulWidget {
final Map<String, dynamic> doctor;
DoctorProfile({Key? key, required this.doctor}) : super(key: key);

@override
_DoctorProfileState createState() => _DoctorProfileState();
}

class _DoctorProfileState extends State<DoctorProfile> {

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
                          backgroundImage:
                          AssetImage('assets/images/doctor.jpg'),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.doctor['name'],
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                widget.doctor['specialization'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade100,
                                ),
                                maxLines: 3, // Allow up to 2 lines
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
                
                ClinicDetails(doctorImage: widget.doctor['image'],doctorName: widget.doctor['name'],specialization: widget.doctor['specialization'],),
                Services(),
                ReviewCard(),
                Education(),
                //Experience(),
                //Memberships(),
                About(),
                //Fees(),
                Locations(),
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
      margin: EdgeInsets.only(left: 16,right:16,top: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.doctor['specialization'], style: TextStyle(color: Colors.grey.shade700)),
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
    return Card(
      color: Colors.white,
      elevation: 4,
      margin: EdgeInsets.only(left: 16,right:16,top: 16),
      child: ExpansionTile(
        leading: Icon(Icons.medical_services,color: Colors.red,),
        title: Text('Services', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17)),
        children: [
          ListTile(title: Text('Abdominal Pain')),
          ListTile(title: Text('Adolesent Medicine ')),
          ListTile(title: Text('Chest Disease In Children')),
          ListTile(title: Text('Child Dietary Consultation')),
          ListTile(title: Text('New Born Examination ')),
        ],
      ),
    );
  }

  Widget ReviewCard() {
    return Card(
      color: Colors.white,
      margin: EdgeInsets.only(left: 16,right:16,top: 16),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.star,color: Colors.blueAccent.shade700,),
                SizedBox(width: 10,),
                Text(
                  widget.doctor['name']+"'s Reviews",
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
                      child: Text("100%",style: TextStyle(color: Colors.white,fontSize: 25)),
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

                // Rating categories
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

            // Satisfied section
            SizedBox(height: 10),

            // Review text
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
                    widget.doctor['name']+'"is highly professional and compassionate.'
                        'They listened to my concerns carefully and provided excellent treatment."',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[800],
                    ),
                  ),
                  Text(
                    '"I had a great experience with Dr.Aaizah.Their expertise and friendly approach made me feel comfortable and confident ',
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
            SizedBox(height: 8,),
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

// Helper widget for review card
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
      margin: EdgeInsets.only(left: 16,right:16,top: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon((Icons.school_sharp),color: Colors.black,),
                SizedBox(width: 10,),
                Text('Education', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            SizedBox(height: 8),
            Text('MBBS - Institute of Medical Sciences, Pakistan, 2021'),
            Text('MCPS (Dermatology) - College of Physicians and Surgeons, Pakistan, 2021'),
          ],
        ),
      ),
    );
  }


// Widget Experience() {
//     return Card(
//       color: Colors.grey.shade300,
//       margin: EdgeInsets.only(left: 16,right:16,top: 16),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Experience', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//             SizedBox(height: 8),
//             Text(widget.doctor['name']+' has over 5 years of experience in Dermatology and Cosmetology.'),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget Memberships() {
//     return Card(
//       color: Colors.grey.shade300,
//       margin: EdgeInsets.only(left: 16,right:16,top: 16),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Professional Memberships', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//             SizedBox(height: 8),
//             Text('• Pakistan Medical Commission (PMC)'),
//           ],
//         ),
//       ),
//     );
//   }

  Widget About() {
    return Card(
      color: Colors.white,
      elevation: 4,
      margin: EdgeInsets.only(left: 16,right:16,top: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.info_sharp,color: Colors.blueGrey,),
                SizedBox(width: 10,),
                Text('About '+widget.doctor['name'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            SizedBox(height: 8),
            Text('Child Specialist with 5 years of experience practicing at CMA Hospital- Clinic & Farooq Hospital , Lahore'),
          ],
        ),
      ),
    );
  }

//   Widget Fees() {
//     return Card(
//       color: Colors.grey.shade300,
//       margin: EdgeInsets.only(left: 16,right:16,top: 16),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Fees', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//             SizedBox(height: 8),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text('Appointment Fee:'),
//                 Text('Rs. 1,500 - 2,000', style: TextStyle(fontWeight: FontWeight.bold)),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
Widget Locations() {
    return Card(
      color: Colors.white,
      elevation: 4,
      margin: EdgeInsets.only(left: 16,right:16,top: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.location_on,color: Colors.redAccent,),
                SizedBox(width: 10,),
                Text('Practice Locations',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            SizedBox(height: 8),
            Text('3rd Floor, 1 Canal Road, Mall 2,\nEden Canal Villas, Lahore'),
            TextButton(
              onPressed: () {},
              child: Text('View on map >'),
            ),
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

  ClinicDetails({required this.doctorName, required this.doctorImage,required this.specialization});
  @override
  _ClinicDetailsState createState() => _ClinicDetailsState();
}

class _ClinicDetailsState extends State<ClinicDetails> {
  bool isExpanded = false;

  final List<DataRow> collapsedTimings = [
    DataRow(
      cells: [
        DataCell(Text('Today')),
        DataCell(Text('03:00 PM - 08:00 PM')),
      ],
    ),
    DataRow(
      cells: [
        DataCell(Text('Tomorrow')),
        DataCell(Text('03:00 PM - 08:00 PM')),
      ],
    ),
  ];

  final List<DataRow> expandedTimings = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ].map((day) => DataRow(
    cells: [
      DataCell(Text(day)),
      DataCell(Text(day == 'Saturday' || day == 'Sunday' ? 'Off' : '03:00 PM - 08:00 PM')),
    ],
  )).toList();

  @override
  Widget build(BuildContext context) {
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
                  'Ahsan Mumtaz Hospital',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              'Fee: Rs. 2,000',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 16),
            Text('Available today', style: TextStyle(fontWeight: FontWeight.bold)),
            DataTable(
              columns: [
                DataColumn(label: Text('Day')),
                DataColumn(label: Text('Timing')),
              ],
              rows: isExpanded ? expandedTimings : collapsedTimings,
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
              child: Text(isExpanded ? 'Hide all timings ▼' : 'View all timings ✅'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>BookingScreen(name: widget.doctorName,Image: widget.doctorImage,Specialization: widget.specialization,locations: 'Ahsan Mumtaz Hospital',)));
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
  }
}