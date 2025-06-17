import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DaycareBookingScreen extends StatefulWidget {
  final String daycareId;  // Add daycareId parameter
  final String name;
  final String image;
  final String type;
  final String location;
  final String price;

  DaycareBookingScreen({
    required this.daycareId,
    required this.name,
    required this.image,
    required this.type,
    required this.location,
    required this.price,
  });

  @override
  _DaycareBookingScreenState createState() => _DaycareBookingScreenState();
}

class _DaycareBookingScreenState extends State<DaycareBookingScreen> {
  DateTime? selectedDate;
  String? selectedTime;
  final TextEditingController childNameController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController specialNotesController = TextEditingController();
  String? selectedGender;
  bool _isSubmitting = false;

  final List<String> availableTimeSlots = [
    '8:00 AM',
    '9:00 AM',
    '10:00 AM',
    '1:00 PM',
    '3:00 PM',
    '5:00 PM',
  ];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
        dateController.text = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
      });
    }
  }

  Future<void> _saveBooking() async {
    if (!_validateForm()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not logged in. Please sign in to make a booking.');
      }

      // Get current user data from Users collection
      DocumentSnapshot userDoc;
      try {
        userDoc = await _firestore.collection('users').doc(user.uid).get();
      } catch (e) {
        throw Exception('Failed to fetch user data. Please try again.');
      }

      if (!userDoc.exists) {
        throw Exception('User data not found. Please complete your profile first.');
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final userName = userData['name'] ?? 'Unknown';
      final userPhone = userData['phone'] ?? '';

      // Validate we have minimum required user data
      if (userName.isEmpty && userPhone.isEmpty) {
        throw Exception('Please complete your profile with at least name or phone number.');
      }

      // Create booking data with all required fields
      final bookingData = {
        // Daycare Information
        'daycareId': widget.daycareId,
        'daycareName': widget.name,
        'daycareImage': widget.image,
        'daycareType': widget.type,
        'daycareLocation': widget.location,
        'daycarePrice': widget.price,

        // Child Information
        'childName': childNameController.text.trim(),
        'childGender': selectedGender ?? 'Not specified',
        'specialNotes': specialNotesController.text.trim(),

        // Booking Details
        'startDate': dateController.text,
        'preferredTime': selectedTime ?? 'Not specified',
        'parentContact': contactController.text.trim(),
        'bookingDate': FieldValue.serverTimestamp(),

        // User Information
        'userId': user.uid,
        'userName': userName,
        'userEmail': user.email ?? '',
        'userPhone': userPhone,

        // System Fields
        'status': 'Pending', // Pending, Confirmed, Cancelled, Completed
        'bookingId': _firestore.collection('DaycareBookings').doc().id,
        'lastUpdated': FieldValue.serverTimestamp(),
      };

      // Save to Firestore
      await _firestore.collection('DaycareBookings').add(bookingData);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Booking confirmed successfully!"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // Navigate back after success
      Navigator.pop(context);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error saving booking: ${e.toString().replaceAll('Exception: ', '')}"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  bool _validateForm() {
    if (childNameController.text.isEmpty ||
        contactController.text.isEmpty ||
        selectedGender == null ||
        dateController.text.isEmpty ||
        selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please fill all required fields"),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    // Validate phone number format if needed
    if (contactController.text.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please enter a valid phone number"),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.deepOrange.shade400,
        title: Text('Daycare Booking', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Daycare Information Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            widget.image,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(Icons.image, size: 80),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.name,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                widget.type,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.location_on, size: 18, color: Colors.deepOrange),
                                  SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      widget.location,
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  SizedBox(width: 4),
                                  Text(
                                    widget.price,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
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
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),

            // Booking Form
            Text(
              "Child Information",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange.shade400,
              ),
            ),
            SizedBox(height: 12),

            TextField(
              controller: childNameController,
              decoration: InputDecoration(
                labelText: "Child's Full Name*",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.child_care),
              ),
            ),
            SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: selectedGender,
              items: ['Male', 'Female', 'Other']
                  .map((gender) => DropdownMenuItem(
                value: gender,
                child: Text(gender),
              ))
                  .toList(),
              onChanged: (value) => setState(() => selectedGender = value),
              decoration: InputDecoration(
                labelText: "Child's Gender*",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) => value == null ? 'Required field' : null,
            ),
            SizedBox(height: 16),

            Text(
              "Parent/Guardian Information",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange.shade400,
              ),
            ),
            SizedBox(height: 12),

            TextField(
              controller: contactController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: "Contact Number*",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
            ),
            SizedBox(height: 16),

            Text(
              "Booking Details",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange.shade400,
              ),
            ),
            SizedBox(height: 12),

            GestureDetector(
              onTap: selectDate,
              child: AbsorbPointer(
                child: TextField(
                  controller: dateController,
                  decoration: InputDecoration(
                    labelText: "Start Date*",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),

            Text(
              "Preferred Drop-off Time*",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: availableTimeSlots.map((time) {
                return ChoiceChip(
                  label: Text(time),
                  selected: selectedTime == time,
                  selectedColor: Colors.deepOrange.shade100,
                  onSelected: (selected) {
                    setState(() {
                      selectedTime = selected ? time : null;
                    });
                  },
                );
              }).toList(),
            ),
            SizedBox(height: 16),

            TextField(
              controller: specialNotesController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Special Notes (Allergies, Special Needs, etc.)",
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child:  Positioned(
                bottom: 5,
                left: 20,
                right: 20,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _saveBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange.shade400,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isSubmitting
                      ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : Text(
                    "CONFIRM BOOKING",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    childNameController.dispose();
    contactController.dispose();
    dateController.dispose();
    specialNotesController.dispose();
    super.dispose();
  }
}