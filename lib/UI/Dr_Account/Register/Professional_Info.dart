import 'package:carecub/Database/DatabaseServices.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'Education.dart';

class SignUpStep2 extends StatefulWidget {

  const SignUpStep2({

    super.key,});

  @override
  State<SignUpStep2> createState() => _SignUpStep2State();
}

class _SignUpStep2State extends State<SignUpStep2> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _experienceController;
  String? name;
  String? title;
  String? _selectedTitle;
  String? _selectedPrimarySpecialization;
  String? _selectedSecondarySpecialization;
  String? _selectedService;
  String? _selectedCondition;
  User? user;
  void fetchDoctorData() async {
    try {
      if (user == null) return; // Ensure user is not null
      Map<String, dynamic>? doctorData = await DatabaseService.getDrData(user!.uid);
      if (doctorData != null && mounted) {
        setState(() {
          title = doctorData['title'];
          name = doctorData['name'];
          _selectedTitle = title;
          _nameController.text = name ?? ""; // Update controller text
        });
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }


  final List<String> _specializations = [
    'Pediatrics', 'Cardiology', 'Dermatology', 'Neurology', 'Orthopedics',
    'Endocrinology', 'Gastroenterology', 'Pulmonology', 'Psychiatry', 'Oncology',
  ];

  final List<String> _services = [
    'Consultation', 'Surgery', 'Therapy', 'Rehabilitation', 'Diagnostics',
  ];

  final List<String> _conditions = [
    'Diabetes', 'Hypertension', 'Asthma', 'Arthritis', 'Cancer',
  ];

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    _nameController = TextEditingController(text: ""); // Start with empty text
    _experienceController = TextEditingController();
    fetchDoctorData(); // Fetch data after initialization
  }

  @override
  void dispose() {
    _nameController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  Widget _buildDropdownField({
    required String label,
    required List<String> items,
    required String? value,
    required void Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
        value: value,
        items: items.map((String item) {
          return DropdownMenuItem<String>(value: item, child: Text(item));
        }).toList(),
        onChanged: onChanged,
        validator: (value) => value == null ? 'Please select a $label' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFEBFF),
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: const Text("Professional Info"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Confirm Your Details", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              // Title Dropdown
              _buildDropdownField(
                label: 'Title',
                items: ['Dr.', 'Prof.', 'Assist. Prof.', 'Assoc. Prof.'],
                value: _selectedTitle,
                onChanged: (value) => setState(() => _selectedTitle = value),
              ),

              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
              ),
              const SizedBox(height: 20),

              // Experience Field
              TextFormField(
                controller: _experienceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Years of Experience", border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) return "Enter years of experience";
                  if (double.tryParse(value) == null) return "Enter a valid number";
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Primary Specialization Dropdown
              _buildDropdownField(
                label: 'Primary Specialization',
                items: _specializations,
                value: _selectedPrimarySpecialization,
                onChanged: (value) => setState(() => _selectedPrimarySpecialization = value),
              ),

              // Secondary Specialization Dropdown
              _buildDropdownField(
                label: 'Secondary Specialization',
                items: _specializations,
                value: _selectedSecondarySpecialization,
                onChanged: (value) => setState(() => _selectedSecondarySpecialization = value),
              ),

              // Services Offered Dropdown
              _buildDropdownField(
                label: 'Service Offered',
                items: _services,
                value: _selectedService,
                onChanged: (value) => setState(() => _selectedService = value),
              ),

              // Conditions Treated Dropdown
              _buildDropdownField(
                label: 'Condition Treated',
                items: _conditions,
                value: _selectedCondition,
                onChanged: (value) => setState(() => _selectedCondition = value),
              ),

              const SizedBox(height: 30),

              // Next Button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    DatabaseService.AddDrProfessional_Info(
                      uid: user!.uid,
                      name: _nameController.text,
                      title: _selectedTitle ?? '',
                      experience: _experienceController.text,
                      Primary_specialization: _selectedPrimarySpecialization ??'',
                      Secondary_specialization: _selectedSecondarySpecialization ?? '',
                      Service_Offered: _selectedService ?? '',
                      Condition: _selectedCondition ?? '',
                    );
                    if (_formKey.currentState!.validate()) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EducationScreen()),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
                  child: const Text("Next", style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
