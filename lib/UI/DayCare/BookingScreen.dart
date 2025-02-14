import 'package:flutter/material.dart';

class DaycareBookingScreen extends StatefulWidget {
  final String name;
  final String image;
  final String type;
  final String location;
  final String price;

  DaycareBookingScreen({
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
  String? selectedGender;

  final List<String> availableTimeSlots = [
    '8:00 AM',
    '9:00 AM',
    '10:00 AM',
    '1:00 PM',
    '3:00 PM',
    '5:00 PM',
  ];

  void _selectDate() async {
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
              color: Colors.white,
              elevation: 5,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            widget.image,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.name,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                widget.type,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.price_check,
                                      color: Colors.green.shade700,
                                      size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    widget.price,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
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
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.location_on,
                            color: Colors.deepOrange.shade400,
                            size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.location,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // Booking Form
            TextField(
              controller: childNameController,
              decoration: InputDecoration(
                labelText: "Child's Full Name",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.child_care),
              ),
            ),
            SizedBox(height: 15),

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
                labelText: "Child's Gender",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.transgender),
              ),
            ),
            SizedBox(height: 15),

            TextField(
              controller: contactController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: "Parent's Contact Number",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
            ),
            SizedBox(height: 15),

            GestureDetector(
              onTap: _selectDate,
              child: AbsorbPointer(
                child: TextField(
                  controller: dateController,
                  decoration: InputDecoration(
                    labelText: "Start Date",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),

            Text(
              "Preferred Drop-off Time:",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
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
            SizedBox(height: 30),

            // Booking Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_validateForm()) {
                    _showConfirmationDialog();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange.shade400,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Confirm Booking",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
    return true;
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Booking Confirmation"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Daycare: ${widget.name}"),
            Text("Child: ${childNameController.text}"),
            Text("Start Date: ${dateController.text}"),
            Text("Drop-off Time: $selectedTime"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Edit"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Booking confirmed successfully!"),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text("Confirm"),
          ),
        ],
      ),
    );
  }
}