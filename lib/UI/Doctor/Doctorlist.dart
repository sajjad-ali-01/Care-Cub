import 'package:flutter/material.dart';

import '../Doctor/BookingScreen.dart';
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
        //automaticallyImplyLeading: false,
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
              child: ListView(
                children: [
                  DoctorCard(
                    name: "Dr. Ayesha Khan",
                    specialization: "Pediatrician, Neonatologist",
                    qualification: "M.B.B.S, FCPS (Pediatrics)",
                    experience: "10 Years",
                    rating: "98% (350 Satisfied)",
                    fee: "Rs. 1,800",
                    locations: [
                      "Sunshine Children's Hospital - Rs. 1,800",
                      "Shrif Medical Complex - Rs. 1,700",
                    ],
                    image: "assets/images/doctor.jpg",
                  ),
                  SizedBox(height: 15),
                  DoctorCard(
                    name: "Dr. Usman Sheikh",
                    specialization: "Child Specialist, Pediatrician",
                    qualification: "M.B.B.S, MCPS (Pediatrics)",
                    experience: "12 Years",
                    rating: "95% (420 Satisfied)",
                    fee: "Rs. 2,000",
                    locations: [
                      "Happy Kids Clinic - Rs. 2,000",
                    ],
                    image: "assets/images/doctor.jpg",
                  ),
                  SizedBox(height: 15),
                  DoctorCard(
                    name: "Dr. Hina Batool",
                    specialization: "Pediatrician, Child Nutrition Expert",
                    qualification: "M.B.B.S, FCPS (Pediatrics)",
                    experience: "8 Years",
                    rating: "97% (310 Satisfied)",
                    fee: "Rs. 1,500",
                    locations: [
                      "Kids Care Medical Center - Rs. 1,500",
                      "Adil Pediatric Clinic - Rs. 1,600",
                    ],
                    image: "assets/images/doctor.jpg",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DoctorCard extends StatelessWidget {
  final String name;
  final String specialization;
  final String qualification;
  final String experience;
  final String rating;
  final String fee;
  final String image;
  final List<String> locations;

  DoctorCard({
    required this.name,
    required this.specialization,
    required this.qualification,
    required this.experience,
    required this.rating,
    required this.fee,
    required this.image,
    required this.locations,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DoctorProfile(
              doctor: {
                'name': name,
                'specialization': specialization,
                'qualification': qualification,
                'experience': experience,
                'rating': rating,
                'fee': fee,
                'locations': locations,
                'image': image,
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
                    backgroundImage: AssetImage(image),
                    radius: 30,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                        Text(specialization, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                        Text(qualification, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Experience: $experience", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  Text(rating, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                ],
              ),
              SizedBox(height: 10),
              Container(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: locations.map((location) {
                    // Split the location string into hospital name and price
                    final parts = location.split(' - ');
                    final hospitalName = parts[0].trim();
                    final hospitalPrice = parts.length > 1 ? parts[1].trim() : fee;

                    return Container(
                      width: 250,
                      margin: EdgeInsets.symmetric(horizontal: 5),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade600,width: 1),
                    gradient: LinearGradient(
                    colors: [Colors.blue.shade50, Colors.grey.shade50],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,

                      )
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.local_hospital_sharp, color: Colors.deepOrange, size: 20),
                              SizedBox(width: 8),
                              Text(
                                hospitalName, // Use the parsed hospital name
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.access_time, color: Colors.grey, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Available tomorrow',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                hospitalPrice, // Use the parsed hospital price
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
                      if (locations.length > 1) {
                        _showHospitalSelection(context);
                      } else {
                        // Directly navigate if only one hospital
                        final parts = locations[0].split(' - ');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookingScreen(
                              name: name,
                              Image: image,
                              Specialization: specialization,
                              locations: 'Ahsan mumtaz Hospital',

                            ),
                          ),
                        );
                      }
                    },
                    icon: Icon(Icons.calendar_today_sharp, size: 18,color: Colors.teal.shade100,),
                    label: Text("Book Appointment",style: TextStyle(fontSize: 17,color: Colors.white),),
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
      )
    );
  }
  void _showHospitalSelection(BuildContext context) {
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
                itemCount: locations.length,
                separatorBuilder: (context, index) => Divider(height: 20),
                itemBuilder: (context, index) {
                  final parts = locations[index].split(' - ');
                  final hospitalName = parts[0].trim();
                  final hospitalPrice = parts.length > 1 ? parts[1].trim() : fee;

                  return InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookingScreen(
                            name: name,
                            Image: image,
                            Specialization: specialization,
                            locations: 'Ahsan mumtaz Hospital',
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          Icon(Icons.local_hospital,
                              color: Colors.deepOrange.shade400),
                          SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  hospitalName,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  hospitalPrice,
                                  style: TextStyle(
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right,
                              color: Colors.grey.shade600),
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
}
