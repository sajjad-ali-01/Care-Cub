import 'package:carecub/Database/DatabaseServices.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'Education.dart';

class SignUpStep2 extends StatefulWidget {
  const SignUpStep2({super.key});

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
  User? user;

  // Lists for multi-select options
  final List<String> _servicesOptions = [
    'Consultation', 'Surgery', 'Therapy', 'Rehabilitation', 'Diagnostics',
  ];
  final List<String> _conditionsOptions = [
    'Diabetes', 'Hypertension', 'Asthma', 'Arthritis', 'Cancer',
  ];

  // Selected services and conditions
  List<String> _selectedServices = [];
  List<String> _selectedConditions = [];

  final List<String> _specializations = [
    'Pediatrics', 'Cardiology', 'Dermatology', 'Neurology', 'Orthopedics',
    'Endocrinology', 'Gastroenterology', 'Pulmonology', 'Psychiatry', 'Oncology',
  ];

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    _nameController = TextEditingController(text: "");
    _experienceController = TextEditingController();
    fetchDoctorData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  void fetchDoctorData() async {
    try {
      if (user == null) return;
      Map<String, dynamic>? doctorData = await DatabaseService.getDrData(user!.uid);
      if (doctorData != null && mounted) {
        setState(() {
          title = doctorData['title'];
          name = doctorData['name'];
          _selectedTitle = title;
          _nameController.text = name ?? "";
        });
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
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

  Widget _buildMultiSelectSection({
    required String title,
    required List<String> options,
    required List<String> selectedOptions,
    required Function(String, bool) onSelected,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: options.map((option) => FilterChip(
                label: Text(option),
                selected: selectedOptions.contains(option),
                onSelected: (selected) => onSelected(option, selected),
              )).toList(),
            ),
          ],
        ),
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
                decoration: const InputDecoration(labelText: "Years of Experience", hintText: "1 year", border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) return "Enter years of experience";
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

              // Services Offered (Multi-Select)
              _buildMultiSelectSection(
                title: 'Services Offered',
                options: _servicesOptions,
                selectedOptions: _selectedServices,
                onSelected: (option, selected) {
                  setState(() {
                    if (selected) {
                      _selectedServices.add(option);
                    } else {
                      _selectedServices.remove(option);
                    }
                  });
                },
              ),

              // Conditions Treated (Multi-Select)
              _buildMultiSelectSection(
                title: 'Conditions Treated',
                options: _conditionsOptions,
                selectedOptions: _selectedConditions,
                onSelected: (option, selected) {
                  setState(() {
                    if (selected) {
                      _selectedConditions.add(option);
                    } else {
                      _selectedConditions.remove(option);
                    }
                  });
                },
              ),

              const SizedBox(height: 30),

              // Next Button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      DatabaseService.AddDrProfessional_Info(
                        uid: user!.uid,
                        name: _nameController.text,
                        title: _selectedTitle ?? '',
                        experience: _experienceController.text,
                        Primary_specialization: _selectedPrimarySpecialization ?? '',
                        Secondary_specialization: _selectedSecondarySpecialization ?? '',
                        Service_Offered: _selectedServices, // Save as List<String>
                        Condition: _selectedConditions, // Save as List<String>
                      );
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