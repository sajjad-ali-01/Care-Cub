import 'package:flutter/material.dart';

class BookingScreen extends StatefulWidget {
  final String daycareName;
  final String daycareImage;

  BookingScreen({required this.daycareName, required this.daycareImage});

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? selectedDate;
  String? selectedTime;
  final TextEditingController childNameController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  String? selectedGender;

  final List<String> availableTimeSlots = [
    '9:00 AM',
    '10:00 AM',
    '11:00 AM',
    '1:00 PM',
    '2:00 PM',
    '3:00 PM',
  ];

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
        dateController.text = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFEBFF),
      appBar: AppBar(
        backgroundColor: Colors.deepOrange.shade500,
        title: Text('Booking - ${widget.daycareName}',style: TextStyle(color: Color(0xFFFFEBFF)),),
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
                  const SizedBox(height: 0),
                  Text(
                    widget.daycareName,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold,color: Colors.deepOrange.shade800),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      widget.daycareImage,
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // Child Name Field
            TextField(
              controller: childNameController,
              decoration: InputDecoration(
                labelText: 'Child\'s Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
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
            const SizedBox(height: 10),
            // Contact Number Field
            TextField(
              controller: contactController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Contact Number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            // Calendar Field
            GestureDetector(
              onTap: _showDatePicker,
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
            const SizedBox(height: 10),

            // Time Slots
            Text(
              'Select Time Slot:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Wrap(
              spacing: 10,
              children: availableTimeSlots.map((time) {
                return ChoiceChip(
                  label: Text(time),
                  selected: selectedTime == time,
                  onSelected: (selected) {
                    setState(() {
                      selectedTime = selected ? time : null;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 15),

            // Submit Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (childNameController.text.isEmpty ||
                      contactController.text.isEmpty ||
                      selectedGender == null ||
                      dateController.text.isEmpty ||
                      selectedTime == null) {
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
                  backgroundColor: Colors.red.shade300,
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 70),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text(
                  'Confirm Booking',
                  style: TextStyle(fontSize: 18,color: Color(0xFFFFEBFF)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}