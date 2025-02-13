import 'package:flutter/material.dart';
import 'Education.dart'; // Import the new screen

class SignInStep2 extends StatefulWidget {
  final String title;
  final String name;

  const SignInStep2({
    super.key,
    required this.title,
    required this.name,
  });

  @override
  State<SignInStep2> createState() => _SignInStep2State();
}

class _SignInStep2State extends State<SignInStep2> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _experienceController;
  String? _selectedTitle;
  String? _selectedPrimarySpecialization;
  String? _selectedSecondarySpecialization;
  String? _selectedService;
  String? _selectedCondition;

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
    _selectedTitle = widget.title;
    _nameController = TextEditingController(text: widget.name);
    _experienceController = TextEditingController();
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
