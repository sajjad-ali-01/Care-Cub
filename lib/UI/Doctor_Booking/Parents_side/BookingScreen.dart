import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookingScreen extends StatefulWidget {
  final String doctorId;
  final String name;
  final String Image;
  final String Specialization;
  final String Secondary_Specialization;
  final String locations;
  final String Address;
  final String qualification;
  final Map<String, dynamic> availability;
  final String clinicName;

  BookingScreen({
    required this.doctorId,
    required this.name,
    required this.Image,
    required this.Specialization,
    required this.Secondary_Specialization,
    required this.locations,
    required this.Address,
    required this.qualification,
    required this.availability,
    required this.clinicName,
  });

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? selectedDate;
  String? selectedTime;
  List<String> availableTimeSlots = [];
  final TextEditingController childNameController = TextEditingController();
  final TextEditingController problem = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController dobController = TextEditingController(); // New controller for DOB
  String? selectedGender;
  DateTime? selectedDob;

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
  Future<void> selectDob(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime tenYearsAgo = DateTime(now.year - 10, now.month, now.day);
    final DateTime firstAllowedDate = DateTime(now.year - 10, 1, 1); // January 1st of 10 years ago

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: tenYearsAgo, // Default to 10 years ago
      firstDate: firstAllowedDate, // Only allow dates from 10 years ago
      lastDate: now, // Up to current date
      initialDatePickerMode: DatePickerMode.year, // Start with year selection
      helpText: 'Select child\'s date of birth (max 10 years old)',
      fieldHintText: 'DD/MM/YYYY',
      errorFormatText: 'Enter valid date',
      errorInvalidText: 'Child must be 10 years or younger',
    );

    if (picked != null && picked != selectedDob) {
      setState(() {
        selectedDob = picked;
        dobController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }
  TimeOfDay parseTime(String timeStr) {
    try {
      final format = DateFormat('h:mm a');
      final dateTime = format.parse(timeStr);
      return TimeOfDay.fromDateTime(dateTime);
    } catch (e) {
      print("Error parsing time: $e");
      return TimeOfDay(hour: 0, minute: 0);
    }
  }

  List<String> generateTimeSlots(String startTime, String endTime) {
    final start = parseTime(startTime);
    final end = parseTime(endTime);
    List<String> slots = [];

    TimeOfDay current = start;

    while (current.hour < end.hour ||
        (current.hour == end.hour && current.minute < end.minute)) {
      slots.add(current.format(context));

      // Add 20 minutes
      final totalMinutes = current.hour * 60 + current.minute + 20;
      current = TimeOfDay(
        hour: totalMinutes ~/ 60,
        minute: totalMinutes % 60,
      );
    }

    return slots;
  }
  
  Stream<QuerySnapshot>? _bookingsStream;

  void DatePicker() async {
    // Find the first available date starting from today
    DateTime initialDate = DateTime.now();
    int attempts = 0;

    // Ensure we don't loop indefinitely
    while (attempts < 365) {
      final dayName = _getDayName(initialDate.weekday);
      if (widget.availability.containsKey(dayName)) {
        break;
      }
      initialDate = initialDate.add(Duration(days: 1));
      attempts++;
    }

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,  // Use the calculated initial date
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      selectableDayPredicate: (date) {
        final dayName = _getDayName(date.weekday);
        return widget.availability.containsKey(dayName);
      },
    );

    if (pickedDate != null && mounted) {
      final dayName = _getDayName(pickedDate.weekday);
      if (widget.availability.containsKey(dayName)) {
        final daySchedule = widget.availability[dayName];

        // Set up the real-time bookings stream
        final selectedDay = DateTime(pickedDate.year, pickedDate.month, pickedDate.day);
        _bookingsStream = FirebaseFirestore.instance
            .collection('Bookings')
            .where('doctorId', isEqualTo: widget.doctorId)
            .where('date', isEqualTo: Timestamp.fromDate(selectedDay))
            .where('status', whereIn: ['pending', 'confirmed'])
            .snapshots();

        setState(() {
          selectedDate = pickedDate;
          dateController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.deepOrange.shade600,
        leading: IconButton(onPressed: (){Navigator.pop(context);}, icon: Icon(Icons.arrow_back,color: Colors.white,)),
        title: Text('Confirm Booking', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.white,
              elevation: 5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(widget.Image),
                          radius: 40,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.name,
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              Text('${widget.qualification}, ${widget.Specialization}',
                                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                        Column(
                          children: [
                            Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.green),
                                Text(widget.clinicName, style: TextStyle(fontSize: 16)),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.location_on, color: Colors.red),
                                Text(widget.Address, style: TextStyle(fontSize: 16),),
                                Spacer(),
                                ElevatedButton(onPressed: (){}, child: Text("See on map"))
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                ),
              ),

            const SizedBox(height: 20),
            TextField(
              controller: childNameController,
              decoration: InputDecoration(
                labelText: 'Child\'s Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
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
                labelText: 'Gender',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(

              controller: contactController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Contact Number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: problem,
              decoration: InputDecoration(
                labelText: 'Child\'s issue(optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            // Add Date of Birth field
            GestureDetector(
              onTap: () => selectDob(context),
              child: AbsorbPointer(
                child: TextField(
                  controller: dobController,
                  decoration: InputDecoration(
                    labelText: 'Child\'s Date of Birth',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: DatePicker,
              child: AbsorbPointer(
                child: TextField(
                  controller: dateController,
                  decoration: InputDecoration(
                    labelText: 'Select Date',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (selectedDate != null) ...[
              Text('Available Time Slots:', /* ... */),
              SizedBox(height: 10),
              StreamBuilder<QuerySnapshot>(
                stream: _bookingsStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }

                  if (snapshot.hasError) {
                    return Text('Error loading slots');
                  }

                  // Get booked times
                  final bookedSlots = snapshot.data?.docs
                      .map((doc) => doc['time'] as String)
                      .toList() ?? [];

                  // Generate all possible slots
                  final dayName = _getDayName(selectedDate!.weekday);
                  final daySchedule = widget.availability[dayName];
                  final allSlots = generateTimeSlots(
                      daySchedule['start'],
                      daySchedule['end']
                  );

                  // Filter available slots
                  final availableSlots = allSlots.where(
                          (slot) => !bookedSlots.contains(slot)).toList();

                  return Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: availableSlots.map((time) {
                      return ChoiceChip(
                        label: Text(time),
                        selected: selectedTime == time,
                        selectedColor: Colors.deepOrange.shade400,
                        onSelected: (selected) => setState(() => selectedTime = selected ? time : null),
                      );
                    }).toList(),
                  );
                },
              ),
            ] else
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text('Select a date to view available time slots',
                    style: TextStyle(color: Colors.grey)),
              ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (childNameController.text.isEmpty ||
                      contactController.text.isEmpty ||
                      selectedGender == null ||
                      selectedDate == null ||
                      selectedTime == null ||
                      selectedDob == null)
                  {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please fill all required fields')),
                    );
                    return;
                  }

                  final User? user = FirebaseAuth.instance.currentUser;
                  if (user == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('You must be logged in to book')),
                    );
                    return;
                  }

                  try {
                    await FirebaseFirestore.instance.collection('Bookings').add({
                      'userId': user.uid,
                      'doctorId': widget.doctorId,
                      'childName': childNameController.text,
                      'description':problem.text,
                      'gender': selectedGender,
                      'contactNumber': contactController.text,
                      'date': Timestamp.fromDate(selectedDate!),
                      'time': selectedTime,
                      'status': 'pending',
                      'createdAt': FieldValue.serverTimestamp(),
                      'doctorName': widget.name,
                      'clinicAddress': widget.Address,
                      'clinicName': widget.clinicName,
                      'dob': Timestamp.fromDate(selectedDob!), // Add DOB to database
                      'age': calculateAge(selectedDob!), // Calculate and store age
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Booking confirmed for ${childNameController.text}'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to save booking: $e')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange.shade400,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Text('Confirm Booking',
                    style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
  // Helper method to calculate age from DOB
  int calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }
}
