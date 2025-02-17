import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

import 'BookingScreen.dart';
import 'DayCareDetails.dart';

class DayCareList extends StatefulWidget {
  @override
  _DayCareListState createState() => _DayCareListState();
}

class _DayCareListState extends State<DayCareList> {
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.deepOrange.shade400,
        elevation: 1,
        automaticallyImplyLeading: false,
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
              hintText: "Search DayCare Center",
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
            "DayCare Centers",
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
        padding: const EdgeInsets.all(12.0),
        child: ListView(
          children: [
            DaycareCard(
              name: "Sunshine Kids Academy",
              type: "Premium Daycare",
              rating: "4.8 (320 reviews)",
              price: "Rs. 800/day",
              description: "A premium childcare center offering...",
              ageRange: "1-5 years",
              hours: "Mon-Fri 8am-7pm, Sat 9am-4pm",
              capacity: "50 children",
              image: "assets/images/daycareCenter1.webp",
              location: "123 Green Valley Road, Downtown",
              features: ["Ages 1-5", "8am - 7pm", "Live CCTV Access"],
              facilities: ["Outdoor Play", "Art Studio", "Nap Rooms"],
              highlights: ["Free Trial Day", "Healthy Meals", "First Aid Certified"],
              safetyFeatures: ["24/7 CCTV", "Fire Safety", "First Aid Trained"],
              programs: [
                {
                  'name': "Toddler Program",
                  'ageRange': "1-3 yrs",
                  'description': "Focus on motor skills development..."
                },
                {
                  'name': "Infant Care",
                  'ageRange': "6-18 mos",
                  'description': "Gentle care program with sensory stimulation activities"
                },
                {
                  'name': "Montessori Primary",
                  'ageRange': "3-6 yrs",
                  'description': "Practical life skills and early academic preparation"
                }
              ],
              gallery: [
                "assets/images/daycareCenter1.webp",
                "assets/images/daycareCenter2.webp",
                "assets/images/daycareCenter3.webp",

              ],
              address: "123 Green Valley Road, Downtown",
              phone: "+92 300 123 4567",
              email: "info@sunshinekids.com",
            ),
            // Add more DaycareCard entries
          ],
        ),
      ),
    );
  }
}

class DaycareCard extends StatelessWidget {
  final String name;
  final String type;
  final String rating;
  final String price;
  final String description;
  final String ageRange;
  final String hours;
  final String capacity;
  final String image;
  final String location;
  final List<String> features;
  final List<String> facilities;
  final List<String> highlights;
  final List<String> safetyFeatures;
  final List<Map<String, String>> programs;
  final List<String> gallery;
  final String address;
  final String phone;
  final String email;

  DaycareCard({
    required this.name,
    required this.type,
    required this.rating,
    required this.price,
    required this.description,
    required this.ageRange,
    required this.hours,
    required this.capacity,
    required this.image,
    required this.location,
    required this.features,
    required this.facilities,
    required this.highlights,
    required this.safetyFeatures,
    required this.programs,
    required this.gallery,
    required this.address,
    required this.phone,
    required this.email,
  });
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: EdgeInsets.only(bottom: 20),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DaycareDetailScreen(
                daycare: {
                  'name': name,
                  'description': description,
                  'ageRange': ageRange,
                  'hours': hours,
                  'rating': rating,
                  'facilities': facilities,
                  'safetyFeatures': safetyFeatures,
                  'image': image,
                  'programs': programs,
                  'address': address,
                  'phone': phone,
                  'email': email,
                  'gallery': gallery,
                  // Include other necessary fields
                },
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: AssetImage(image),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                type,
                                style: TextStyle(
                                  color: Colors.orange.shade800,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.location_on,
                                size: 16,
                                color: Colors.deepOrange.shade400),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                location,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 18),
                            SizedBox(width: 4),
                            Text(
                              rating,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Spacer(),
                            Text(
                              price,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: features.map((feature) => Chip(
                  label: Text(feature),
                  backgroundColor: Colors.blue.shade50,
                  labelStyle: TextStyle(color: Colors.blue.shade800),
                )).toList(),
              ),
              SizedBox(height: 15),
              Container(
                height: 110,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    buildInfoCard(
                      title: "Facilities",
                      icon: Icons.emoji_food_beverage,
                      items: facilities,
                      color: Colors.blue.shade100,
                    ),
                    buildInfoCard(
                      title: "Safety Features",
                      icon: Icons.security,
                      items: safetyFeatures,
                      color: Colors.green.shade100,
                    ),
                    buildInfoCard(
                      title: "Special Offers",
                      icon: Icons.local_offer,
                      items: highlights,
                      color: Colors.orange.shade100,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>DaycareBookingScreen(
                    image: image,
                    name: name,
                    type: type,
                    location: location,
                    price: price,
                  )
                  ));
                },
                icon: Icon(Icons.calendar_today, size: 18,color: Colors.tealAccent.shade200,),
                label: Text("Book Now",style: TextStyle(color: Colors.white,fontSize: 17),),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange.shade400,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildInfoCard({
    required String title,
    required IconData icon,
    required List<String> items,
    required Color color,
  }) {
    return Container(
      width: 200,
      margin: EdgeInsets.only(right: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: Colors.deepOrange),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Expanded(
            child: ListView(
              physics: NeverScrollableScrollPhysics(),
              children: items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Row(
                  children: [
                    Icon(Icons.circle, size: 6, color: Colors.grey.shade600),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
