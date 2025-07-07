import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'MyBookings.dart';
import 'BookingScreen.dart';
import 'DayCareDetails.dart';

class DayCareList extends StatefulWidget {
  @override
  _DayCareListState createState() => _DayCareListState();
}

class _DayCareListState extends State<DayCareList> {
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _searchQuery = '';

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
        backgroundColor: Colors.deepOrange.shade400,
        elevation: 1,
        automaticallyImplyLeading: false,
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
            hintText: "Search DayCare Center",
            hintStyle: TextStyle(color: Colors.white),
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: Icon(Icons.send, color: Colors.white),
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
            "DayCare Centers",
            style: TextStyle(color: Colors.white),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.close : Icons.search, color: Colors.white),
            onPressed: () {
              setState(() {
                isSearching = !isSearching;
                if (!isSearching) {
                  searchController.clear();
                  _searchQuery = '';
                }
              });
            },
          ),
        ],
      ),
      body: _buildDaycareList(),
    );
  }

  Widget _buildDaycareList() {
    return Column(
      children: [
        // Add your two buttons here
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
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
                  onPressed: () {},
                  child: Text("Day Cares Near Me", style: TextStyle(fontSize: 15)),
                  style: OutlinedButton.styleFrom(shape: StadiumBorder()),
                ),
              ),
            ],
          ),
        ),
        // Your existing StreamBuilder
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _searchQuery.isEmpty
                ? _firestore.collection('DayCare').snapshots()
                : _firestore
                .collection('DayCare')
                .where('name', isGreaterThanOrEqualTo: _searchQuery)
                .where('name', isLessThan: _searchQuery + 'z')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Text(
                    _searchQuery.isEmpty
                        ? 'No daycare centers found'
                        : 'No results for "$_searchQuery"',
                    style: TextStyle(fontSize: 16),
                  ),
                );
              }

              return ListView(
                padding: EdgeInsets.symmetric(horizontal: 10,vertical: 0),
                children: snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return DaycareCard(
                    id: doc.id,
                    name: data['name'] ?? 'No Name',
                    type: data['isVerified'] ? "Verified Daycare" : "Daycare",
                    rating: "4.5 (120 reviews)",
                    price: "Rs. ${data['price'] ?? '800'}/day",
                    description: data['description'] ?? 'No description',
                    ageRange: data['ageRange'] ?? 'Not specified',
                    hours: data['hours'] ?? 'Not specified',
                    capacity: data['capacity'] ?? 'Not specified',
                    image: data['profileImageUrl'] ?? 'assets/images/daycareCenter1.webp',
                    location: data['address'] ?? 'No address',
                    features: [
                      data['ageRange'] ?? 'All ages',
                      data['hours'] ?? 'Flexible hours',
                      data['isVerified'] ? 'Verified' : 'Not verified'
                    ],
                    facilities: List<String>.from(data['facilities'] ?? []),
                    highlights: ['Safe Environment', 'Qualified Staff'],
                    safetyFeatures: List<String>.from(data['safetyFeatures'] ?? []),
                    programs: List<Map<String, String>>.from(
                        data['programs']?.map((p) => Map<String, String>.from(p)) ?? []),
                    gallery: List<String>.from(data['galleryImages'] ?? []),
                    address: data['address'] ?? 'No address',
                    phone: data['phone'] ?? 'No phone',
                    email: data['email'] ?? 'No email',
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }
  }
class DaycareCard extends StatelessWidget {
  final String id;
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
    required this.id,
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
                  'id': id,
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
                  'type': type,
                  'price': price,
                },
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 12),
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
                        image: NetworkImage(image),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                                size: 18, color: Colors.deepOrange.shade400),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                location,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 17,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            StreamBuilder<double>(
                              stream: getOverallRatingStream(id), // pass your actual daycareId here
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
                                  ],
                                );
                              },
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
              SizedBox(height: 10),
              Container(
                height: 110,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    if (facilities.isNotEmpty)
                      buildInfoCard(
                        title: "Facilities",
                        icon: Icons.emoji_food_beverage,
                        items: facilities.take(3).toList(),
                        color: Colors.blue.shade100,
                      ),
                    if (safetyFeatures.isNotEmpty)
                      buildInfoCard(
                        title: "Safety",
                        icon: Icons.security,
                        items: safetyFeatures.take(3).toList(),
                        color: Colors.green.shade100,
                      ),
                    buildInfoCard(
                      title: "Highlights",
                      icon: Icons.local_offer,
                      items: highlights.take(3).toList(),
                      color: Colors.orange.shade100,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DaycareBookingScreen(
                        image: image,
                        name: name,
                        type: type,
                        location: location,
                        price: price,
                        daycareId: id,
                      ),
                    ),
                  );
                },
                icon: Icon(Icons.calendar_today,
                    size: 18, color: Colors.tealAccent.shade200),
                label: Text(
                  "Book Now",
                  style: TextStyle(color: Colors.white, fontSize: 17),
                ),
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
  Stream<double> getOverallRatingStream(String daycareId) {
    return FirebaseFirestore.instance
        .collection('DaycareReviews')
        .where('daycareId', isEqualTo: daycareId)
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
}