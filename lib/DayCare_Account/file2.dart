import 'package:flutter/material.dart';

class SignInStep2 extends StatefulWidget {
  final String title;
  final String name;
  final String country;
  final String city;
  final String email;
  final String phone;

  const SignInStep2({
    super.key,
    required this.title,
    required this.name,
    required this.country,
    required this.city,
    required this.email,
    required this.phone,
  });

  @override
  State<SignInStep2> createState() => _SignInStep2State();
}

class _SignInStep2State extends State<SignInStep2> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _nameController;
  late TextEditingController _countryController;
  late TextEditingController _cityController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  final TextEditingController _experienceController = TextEditingController();

  String? _selectedPrimarySpecialization;
  String? _selectedSecondarySpecialization;
  String? _selectedService;
  String? _selectedCondition;
  String? _selectedTitle;
  String? _selectedCity;
  final List<String> _cities = [
    'Karachi', 'Lahore', 'Islamabad', 'Rawalpindi', 'Faisalabad',
    'Multan', 'Peshawar', 'Quetta', 'Hyderabad', 'Sialkot'
  ];

  // Specializations
  final List<String> _specializations = [
    'Pediatrics',
    'Cardiology',
    'Dermatology',
    'Neurology',
    'Orthopedics',
    'Endocrinology',
    'Gastroenterology',
    'Pulmonology',
    'Psychiatry',
    'Oncology',
  ];

  // Services & Treatments (depending on specialization)
  final Map<String, List<String>> _servicesMap = {
    'Pediatrics': ['Vaccination', 'Growth Monitoring', 'Newborn Care'],
    'Cardiology': ['ECG', 'Heart Surgery', 'Blood Pressure Management'],
    'Dermatology': ['Acne Treatment', 'Skin Allergy Treatment', 'Laser Therapy'],
    'Neurology': ['Brain MRI', 'Seizure Management', 'Stroke Treatment'],
    'Orthopedics': ['Fracture Treatment', 'Joint Replacement', 'Arthritis Care'],
    'Endocrinology': ['Diabetes Management', 'Thyroid Disorders', 'Hormone Therapy'],
    'Gastroenterology': ['Endoscopy', 'Liver Disease Treatment', 'Colon Cancer Screening'],
    'Pulmonology': ['Asthma Treatment', 'COPD Management', 'Lung Function Tests'],
    'Psychiatry': ['Depression Treatment', 'Anxiety Management', 'Therapy Sessions'],
    'Oncology': ['Cancer Screening', 'Chemotherapy', 'Radiation Therapy'],
  };

  // Conditions Treated (depending on specialization)
  final Map<String, List<String>> _conditionsMap = {
    'Pediatrics': ['Fever', 'Cough & Cold', 'Nutritional Deficiencies'],
    'Cardiology': ['Heart Attack', 'Hypertension', 'Arrhythmia'],
    'Dermatology': ['Eczema', 'Psoriasis', 'Fungal Infections'],
    'Neurology': ['Epilepsy', 'Parkinson’s Disease', 'Migraine'],
    'Orthopedics': ['Osteoporosis', 'Back Pain', 'Sports Injuries'],
    'Endocrinology': ['Diabetes', 'Thyroid Disorders', 'Obesity'],
    'Gastroenterology': ['Acid Reflux', 'IBS', 'Liver Disease'],
    'Pulmonology': ['Asthma', 'Pneumonia', 'Tuberculosis'],
    'Psychiatry': ['Schizophrenia', 'Bipolar Disorder', 'PTSD'],
    'Oncology': ['Breast Cancer', 'Lung Cancer', 'Leukemia'],
  };
  @override
  void initState() {
    super.initState();
    _selectedTitle = widget.title; // Initialize title from previous screen
    _selectedCity = widget.city; // Initialize city from previous screen
    _nameController = TextEditingController(text: widget.name);
    _countryController = TextEditingController(text: widget.country);
    _emailController = TextEditingController(text: widget.email);
    _phoneController = TextEditingController(text: widget.phone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _countryController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFEBFF),
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: const Text("Sign In - Step 2"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Confirm Your Details",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Title Dropdown
              DropdownButtonFormField<String>(
                value: _selectedTitle,
                dropdownColor: const Color(0xFFFFEBFF),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.person_outline),
                  labelText: 'Title',
                ),
                items: ['Dr.', 'Prof.', 'Assist. Prof.', 'Assoc. Prof.']
                    .map((title) => DropdownMenuItem<String>(
                  value: title,
                  child: Text(title),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedTitle = value;
                  });
                },
                validator: (value) =>
                value == null ? 'Please select a title' : null,
              ),
              SizedBox(height: 15),

              const SizedBox(height: 15),

              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Full Name",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value!.isEmpty ? 'Please enter your name' : null,
              ),
              const SizedBox(height: 15),

              // Country Field
              TextFormField(
                controller: _countryController,
                decoration: const InputDecoration(
                  labelText: "Country",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value!.isEmpty ? 'Please enter your country' : null,
              ),
              const SizedBox(height: 15),

              // City Field
              TextFormField(
                controller: _countryController,
                decoration: const InputDecoration(
                  labelText: "Country",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value!.isEmpty ? 'Please enter your country' : null,
              ),
              const SizedBox(height: 15),

              // City Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCity,
                decoration: const InputDecoration(
                  labelText: "City",
                  border: OutlineInputBorder(),
                ),
                items: _cities.map((city) {
                  return DropdownMenuItem<String>(
                    value: city,
                    child: Text(city),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCity = value;
                  });
                },
                validator: (value) =>
                value == null ? 'Please select your city' : null,
              ),
              const SizedBox(height: 15),

              const SizedBox(height: 15),

              // Email Field
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value!.isEmpty ? 'Please enter your email' : null,
              ),
              const SizedBox(height: 15),

              // Phone Field
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  prefixIcon: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      "+92",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  prefixIconConstraints: BoxConstraints(minWidth: 50, minHeight: 0),
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  } else if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                    return 'Enter a valid 10-digit number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Years of Experience Field
              TextFormField(
                controller: _experienceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Years of Experience",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter years of experience";
                  }
                  if (int.tryParse(value) == null) {
                    return "Enter a valid number";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Primary Specialization Dropdown
              _buildDropdownField(
                label: "Primary Specialization",
                value: _selectedPrimarySpecialization,
                items: _specializations,
                onChanged: (value) {
                  setState(() {
                    _selectedPrimarySpecialization = value;
                    _selectedSecondarySpecialization = null;
                    _selectedService = null;
                    _selectedCondition = null;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Secondary Specialization Dropdown
              _buildDropdownField(
                label: "Secondary Specialization",
                value: _selectedSecondarySpecialization,
                items: _specializations,
                onChanged: (value) {
                  setState(() {
                    _selectedSecondarySpecialization = value;
                    _selectedService = null;
                    _selectedCondition = null;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Services & Treatments Dropdown
              _buildDropdownField(
                label: "Services & Treatments Offered",
                value: _selectedService,
                items: _selectedSecondarySpecialization != null
                    ? _servicesMap[_selectedSecondarySpecialization]!
                    : [],
                onChanged: (value) => setState(() => _selectedService = value),
              ),
              const SizedBox(height: 20),

              // Conditions Treated Dropdown
              _buildDropdownField(
                label: "Conditions Treated",
                value: _selectedCondition,
                items: _selectedSecondarySpecialization != null
                    ? _conditionsMap[_selectedSecondarySpecialization]!
                    : [],
                onChanged: (value) => setState(() => _selectedCondition = value),
              ),
              const SizedBox(height: 30),

              // Complete Sign-In Button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Sign-In Completed Successfully!")),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 100),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Complete Sign-In",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? "Please select $label" : null,
    );
  }
}