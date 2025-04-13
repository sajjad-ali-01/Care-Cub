import 'package:flutter/material.dart';

class DaycareDetailScreen extends StatefulWidget {
  final Map<String, dynamic> daycare;

  DaycareDetailScreen({Key? key, required this.daycare}) : super(key: key);

  @override
  _DaycareDetailScreenState createState() => _DaycareDetailScreenState();
}

class _DaycareDetailScreenState extends State<DaycareDetailScreen> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: Colors.deepOrange.shade400,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.asset(
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
              buildReviewsSection(),
              buildHoursSection(),
              buildContactSection(),
              buildBookButton(),
              SizedBox(height: 30),
            ]),
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
                Text('Overview', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 10),
            Text(
              widget.daycare['description'],
              style: TextStyle(color: Colors.grey.shade700, height: 1.5),
            ),
            SizedBox(height: 15),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildInfoChip(Icons.child_care, 'Ages: ${widget.daycare['ageRange']}'),
                _buildInfoChip(Icons.access_time, 'Hours: ${widget.daycare['hours']}'),
                _buildInfoChip(Icons.people, 'Capacity: ${widget.daycare['capacity']}'),
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
                itemCount: widget.daycare['gallery'].length,
                itemBuilder: (context, index) => Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      widget.daycare['gallery'][index],
                      width: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildReviewsSection() {
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.reviews, color: Colors.blue),
                SizedBox(width: 10),
                Text('Parent Reviews', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 10),
            ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: 3,
              separatorBuilder: (context, index) => Divider(),
              itemBuilder: (context, index) => ListTile(
                leading: CircleAvatar(child: Text('P${index+1}')),
                title: Text('Excellent care!', style: TextStyle(fontWeight: FontWeight.w500)),
                subtitle: Text('My child loves coming here every day...'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    Text('4.8'),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            TextButton.icon(
              onPressed: () {},
              icon: Icon(Icons.arrow_forward),
              label: Text('See All Reviews'),
            ),
          ],
        ),
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
    return [
      _buildScheduleRow('Monday - Friday', '7:30 AM - 6:00 PM'),
      _buildScheduleRow('Saturday', '9:00 AM - 4:00 PM'),
      _buildScheduleRow('Sunday', 'Closed'),
      if(isExpanded) ...[
        _buildScheduleRow('Holidays', 'Special hours apply'),
        _buildScheduleRow('Emergency Care', '24/7 on-call service'),
      ],
    ];
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
            _buildContactItem(Icons.phone, widget.daycare['phone']),
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton.icon(
        icon: Icon(Icons.calendar_today),
        label: Text('Book a Tour', style: TextStyle(fontSize: 18)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepOrange.shade400,
          foregroundColor: Colors.white,
          minimumSize: Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {},
      ),
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