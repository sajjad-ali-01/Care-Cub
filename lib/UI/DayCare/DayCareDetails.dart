import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class DayCareDetailScreen extends StatelessWidget {
  final String name;
  final String location;

  DayCareDetailScreen({required this.name, required this.location});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFEBFF),
      appBar: AppBar(
        backgroundColor: Colors.deepOrange.shade500,
        title: Text(name,style: TextStyle(color: Color(0xFFFFEBFF)),),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Daycare Name
            Text(
              name,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepOrange.shade800),
            ),
            SizedBox(height: 10),
            Text(
              'Welcome to $name! We provide a safe and nurturing environment for your little ones.',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            SizedBox(height: 20),
            Text(
              'Activities',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepOrange.shade800),
            ),
            SizedBox(height: 10),
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  activityImage('assets/images/activities1.PNG'),
                  SizedBox(width: 10),
                  activityImage('assets/images/activiteis2.PNG'),
                  SizedBox(width: 10),
                  activityImage('assets/images/activities3.PNG'),
                  SizedBox(width: 10),
                  activityImage('assets/images/activities4.PNG'),
                ],
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade300,
                padding: EdgeInsets.symmetric(
                    vertical: 10, horizontal: 30),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ActivitiesScreen()),
                );
              },
              child: Text('View ALL Activities',style: TextStyle(color: Color(0xFFFFEBFF)),),
            ),
            SizedBox(height: 20,),
            // Location with Map Image
            Text(
              '$location',
              style: TextStyle(fontSize: 18, color: Colors.deepOrange.shade800),
            ),
            SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/images/Map.PNG',
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 20),
            // Images of Activities

            SizedBox(height: 20),

            // Book Now Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookingScreen(
                        daycareName: name,
                        daycareImage: 'assets/images/Baby.png',
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade300,
                  padding: EdgeInsets.symmetric(
                      vertical: 10, horizontal: 110),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
                child: Text(
                  'Book Now',
                  style: TextStyle(fontSize: 18,color: Color(0xFFFFEBFF)),
                ),
              )

            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to display an activity image
  Widget activityImage(String imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.asset(
        imageUrl,
        height: 100,
        width: 260,
        fit: BoxFit.cover,
      ),
    );
  }
}


class BookingScreen extends StatefulWidget {
  final String daycareName;
  final String daycareImage;

  BookingScreen({required this.daycareName, required this.daycareImage});

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? selectedDate;
  final TextEditingController childNameController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  String? selectedGender;

  void _showDatePicker() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking - ${widget.daycareName}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Daycare Image and Name
            Center(
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      widget.daycareImage,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.daycareName,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Child Name Field
            TextField(
              controller: childNameController,
              decoration: InputDecoration(
                labelText: 'Child\'s Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Gender Dropdown
            DropdownButtonFormField<String>(
              value: selectedGender,
              items: ['Male', 'Female', 'Other']
                  .map((gender) => DropdownMenuItem(
                value: gender,
                child: Text(gender),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedGender = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Gender',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Contact Number Field
            TextField(
              controller: contactController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Contact Number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Calendar Field
            GestureDetector(
              onTap: _showDatePicker,
              child: AbsorbPointer(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: selectedDate == null
                        ? 'Select Date'
                        : 'Selected Date: ${selectedDate!.toLocal()}'.split(' ')[0],
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Submit Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (childNameController.text.isEmpty ||
                      contactController.text.isEmpty ||
                      selectedGender == null ||
                      selectedDate == null) {
                    // Show error if any field is missing
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please fill all the fields')),
                    );
                  } else {
                    // Handle booking submission
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Booking Confirmed for ${childNameController.text}!'),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding:
                  EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                ),
                child: Text(
                  'Confirm Booking',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// Activities Screen with Activity Cards
class ActivitiesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text('Activities'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          activityCard(
            'Painting Class',
            'assets/images/Baby.png',
            'Let your child explore their creativity through painting.',
          ),
          SizedBox(height: 10),
          activityCard(
            'Music Lessons',
            'assets/images/Baby.png',
            'Fun music lessons to develop rhythm and melody.',
          ),
          SizedBox(height: 10),
          activityCard(
            'Outdoor Play',
            'assets/images/Baby.png',
            'Engage in healthy outdoor activities and games.',
          ),
          SizedBox(height: 10),
          activityCard(
            'Story Time',
            'assets/images/Baby.png',
            'Interactive storytelling sessions to spark imagination.',
          ),
        ],
      ),
    );
  }

  Widget activityCard(String title, String imageUrl, String description) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                imageUrl,
                height: 80,
                width: 80,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                  ),
                  SizedBox(height: 5),
                  Text(
                    description,
                    style: TextStyle(fontSize: 14, color: Colors.black87),
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
