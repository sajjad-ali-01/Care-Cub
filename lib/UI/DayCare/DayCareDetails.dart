import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:intl/intl.dart';

import '../Doctor_Booking/Parents_side/Doctor details.dart';
import 'BookingScreen.dart';

class DaycareDetailScreen extends StatefulWidget {
  final Map<String, dynamic> daycare;

  DaycareDetailScreen({Key? key, required this.daycare}) : super(key: key);

  @override
  _DaycareDetailScreenState createState() => _DaycareDetailScreenState();
}

class _DaycareDetailScreenState extends State<DaycareDetailScreen> {
  void _showFullScreenImage(String imageUrl, {bool isAsset = false}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              color: Colors.black,
              child: Center(
                child: PhotoView(
                  imageProvider: isAsset
                      ? AssetImage(imageUrl) as ImageProvider
                      : NetworkImage(imageUrl),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 3,
                  initialScale: PhotoViewComputedScale.contained * 1.0, // Start with fitted height
                  basePosition: Alignment.center,
                  heroAttributes: PhotoViewHeroAttributes(tag: imageUrl),
                  filterQuality: FilterQuality.high,
                  enableRotation: true,
                  backgroundDecoration: BoxDecoration(color: Colors.black),
                  loadingBuilder: (context, event) {
                    if (event == null || event.expectedTotalBytes == null) {
                      return Center(child: CircularProgressIndicator());
                    }
                    return Center(
                      child: CircularProgressIndicator(
                        value: event.cumulativeBytesLoaded / event.expectedTotalBytes!,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Icon(Icons.broken_image, color: Colors.white, size: 50),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                backgroundColor: Colors.deepOrange.shade400,
                flexibleSpace: FlexibleSpaceBar(
                  background: widget.daycare['image'].startsWith('http')
                      ? Image.network(
                    widget.daycare['image'],
                    fit: BoxFit.cover,
                  )
                      : Image.asset(
                    widget.daycare['image'],
                    fit: BoxFit.cover,
                  ),
                  title: Text(
                    widget.daycare['name'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [Shadow(color: Colors.black, blurRadius: 10)],
                    ),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  buildOverviewSection(),
                  buildFacilitiesSection(),
                  buildSafetyFeatures(),
                  buildProgramsSection(),
                  buildGallerySection(),
                  ReviewCard(),
                  buildHoursSection(),
                  buildContactSection(),
                  SizedBox(height: 80), // Space for the fixed button
                ]),
              ),
            ],
          ),
          // Fixed bottom button
          Positioned(
            bottom: 5,
            left: 20,
            right: 20,
            child: buildBookButton(),
          ),
        ],
      ),
    );
  }

  Widget buildOverviewSection() {
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: Colors.blue),
                SizedBox(width: 10),
                Text('Overview', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 10),
            Text(
              widget.daycare['description'],
              style: TextStyle(color: Colors.grey.shade700, height: 1.5,fontSize: 16),
            ),
            SizedBox(height: 15),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildInfoChip(Icons.child_care, 'Ages: ${widget.daycare['ageRange']}'),
                _buildInfoChip(Icons.access_time, 'Hours: ${widget.daycare['hours']}'),
                _buildInfoChip(Icons.payment, '${widget.daycare['price']}'),
                _buildInfoChip(Icons.star, widget.daycare['rating']),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildFacilitiesSection() {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: ExpansionTile(
        leading: Icon(Icons.emoji_food_beverage, color: Colors.orange),
        title: Text('Facilities & Amenities', style: TextStyle(fontWeight: FontWeight.bold)),
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: widget.daycare['facilities'].map<Widget>((facility) => Chip(
                label: Text(facility),
                backgroundColor: Colors.blue.shade50,
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSafetyFeatures() {
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.security, color: Colors.green),
                SizedBox(width: 10),
                Text('Safety Features', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 10),
            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 3,
              children: widget.daycare['safetyFeatures'].map<Widget>((feature) => Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 20),
                  SizedBox(width: 5),
                  Text(feature, style: TextStyle(fontSize: 14)),
                ],
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildProgramsSection() {
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.school, color: Colors.purple),
                SizedBox(width: 10),
                Text('Programs Offered', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 10),
            ...widget.daycare['programs'].map<Widget>((program) => Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: Icon(Icons.circle, size: 10, color: Colors.deepOrange),
                title: Text(program['name'], style: TextStyle(fontWeight: FontWeight.w500)),
                subtitle: Text("Ages ${program['ageRange']}: ${program['description']}"),
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget buildGallerySection() {
    final gallery = widget.daycare['gallery'] as List<dynamic>;
    if (gallery.isEmpty) return SizedBox.shrink();

    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.photo_library, color: Colors.amber),
                SizedBox(width: 10),
                Text('Gallery', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 10),
            Container(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: gallery.length,
                itemBuilder: (context, index) {
                  final imageUrl = gallery[index].toString();
                  final isAssetImage = !imageUrl.startsWith('http');

                  return Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTap: () => _showFullScreenImage(imageUrl, isAsset: isAssetImage),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: isAssetImage
                            ? Image.asset(
                          imageUrl,
                          width: 200,
                          fit: BoxFit.cover,
                        )
                            : Image.network(
                          imageUrl,
                          width: 200,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: 200,
                              color: Colors.grey.shade200,
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 200,
                              color: Colors.grey.shade200,
                              child: Center(
                                child: Icon(Icons.broken_image, color: Colors.grey),
                              ),
                            );
                          },
                        ),
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

  Widget ReviewCard() {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('DaycareReviews')
          .where('daycareId', isEqualTo: widget.daycare['id'])
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
          doctorRatingTotal += (data['daycareRating'] as num).toDouble();
          clinicRatingTotal += (data['facilitiesRating'] as num).toDouble();
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
                          "${widget.daycare['name']}'s Reviews",
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
                        RatingRow("DayCare Center", "${avgDoctorRating.toStringAsFixed(1)}/5"),
                        RatingRow("facilities Rating", "${avgClinicRating.toStringAsFixed(1)}/5"),
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
                        builder: (context) => DaycareReviewsScreen(
                          daycareId: widget.daycare['id'],
                          daycareName: widget.daycare['name'],
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

  Widget buildHoursSection() {
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.access_time, color: Colors.deepOrange),
                SizedBox(width: 10),
                Text('Hours of Operation', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 10),
            ..._buildScheduleTable(),
            ExpansionTile(
              title: Text('View Full Schedule'),
              initiallyExpanded: isExpanded,
              onExpansionChanged: (expanded) => setState(() => isExpanded = expanded),
              children: [SizedBox.shrink()], // Empty because we're using the expansion for display only
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildScheduleTable() {
    // Get operating days from the daycare data
    final operatingDays = widget.daycare['operatingDays'] as List<dynamic>? ?? [];
    final hours = widget.daycare['hours'] as String? ?? 'Not specified';

    // Group consecutive days
    List<Widget> scheduleWidgets = [];

    if (operatingDays.isEmpty) {
      // If no operating days specified, show the general hours
      scheduleWidgets.add(
          _buildScheduleRow('Operating Hours', hours)
      );
    } else {
      // Sort days in order
      const dayOrder = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      operatingDays.sort((a, b) => dayOrder.indexOf(a).compareTo(dayOrder.indexOf(b)));

      // Group consecutive days
      List<List<String>> dayGroups = [];
      List<String> currentGroup = [];

      for (var day in operatingDays) {
        if (currentGroup.isEmpty) {
          currentGroup.add(day);
        } else {
          final lastDayIndex = dayOrder.indexOf(currentGroup.last);
          if (dayOrder.indexOf(day) == lastDayIndex + 1) {
            currentGroup.add(day);
          } else {
            dayGroups.add(List.from(currentGroup));
            currentGroup = [day];
          }
        }
      }
      if (currentGroup.isNotEmpty) {
        dayGroups.add(currentGroup);
      }

      // Create schedule rows for each day group
      for (var group in dayGroups) {
        if (group.length == 1) {
          scheduleWidgets.add(_buildScheduleRow(group[0], hours));
        } else {
          scheduleWidgets.add(
              _buildScheduleRow('${group.first} - ${group.last}', hours)
          );
        }
      }

      // Add closed days if not in operating days
      if (!operatingDays.contains('Sunday')) {
        scheduleWidgets.add(_buildScheduleRow('Sunday', 'Closed'));
      }
    }

    // Add expanded content if needed
    if (isExpanded) {
      scheduleWidgets.addAll([
        _buildScheduleRow('Holidays', 'Special hours apply'),
        _buildScheduleRow('Emergency Care', '24/7 on-email service'),
      ]);
    }

    return scheduleWidgets;
  }

  Widget _buildScheduleRow(String day, String time) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(day, style: TextStyle(color: Colors.grey.shade700)),
          Text(time, style: TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget buildContactSection() {
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.contact_page, color: Colors.green),
                SizedBox(width: 10),
                Text('Contact Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 15),
            _buildContactItem(Icons.location_on, widget.daycare['address']),
            _buildContactItem(Icons.email, widget.daycare['email']),
            SizedBox(height: 10),
            InkWell(
              onTap: () {}, // Open map
              child: Row(
                children: [
                  Icon(Icons.map, color: Colors.blue),
                  SizedBox(width: 10),
                  Text('View on Map', style: TextStyle(color: Colors.blue)),
                ],
              ),
            ),
            SizedBox(height: 8),
            Image.asset("assets/images/Map.jpg")
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          SizedBox(width: 15),
          Expanded(child: Text(text, style: TextStyle(fontSize: 15))),
        ],
      ),
    );
  }

  Widget buildBookButton() {
    return ElevatedButton.icon(
      icon: Icon(Icons.calendar_today),
      label: Text('Book a Tour', style: TextStyle(fontSize: 18)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepOrange.shade400,
        foregroundColor: Colors.white,
        minimumSize: Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DaycareBookingScreen(
              image: widget.daycare['image'],
              name: widget.daycare['name'],
              type: widget.daycare['type'],
              location: widget.daycare['address'],
              price: widget.daycare['price'],
              daycareId: widget.daycare['id'],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(text),
      backgroundColor: Colors.grey.shade200,
    );
  }
}

class DaycareReviewsScreen extends StatelessWidget {
  final String daycareId;
  final String daycareName;

  const DaycareReviewsScreen({
    required this.daycareId,
    required this.daycareName,
  }) : super();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$daycareName'+'reviews'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('DaycareReviews')
            .where('daycareId', isEqualTo: daycareId)
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
                              review['parentName']?.toString() ?? 'Anonymous',
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
                            if (review['facilitiesRating'] != null)
                              Chip(
                                label: Text(
                                  'Facilities Ratings: ${review['facilitiesRating'].toStringAsFixed(1)}',
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.blue,
                              ),
                            if (review['staffRating'] != null)
                              Chip(
                                label: Text(
                                  'Staff Rating: ${review['staffRating'].toStringAsFixed(1)}',
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.green,
                              ),
                            if (review['daycareRating'] != null)
                              Chip(
                                label: Text(
                                  'Day Care Reviews: ${review['daycareRating'].toStringAsFixed(1)}',
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.purple,
                              ),
                            if (review['safetyRating'] != null)
                              Chip(
                                label: Text(
                                  'Safety: ${review['safetyRating'].toStringAsFixed(1)}',
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