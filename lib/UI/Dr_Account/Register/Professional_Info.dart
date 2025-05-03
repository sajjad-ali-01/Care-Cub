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
  final formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController experienceController;
  String? name;
  String? title;
  String? selectedTitle;
  String? selectedPrimarySpecialization;
  String? selectedSecondarySpecialization;
  User? user;
  final List<String> _servicesOptions = [
    'Consultation',
    'Surgery',
    'Therapy',
    'Rehabilitation',
    'Diagnostics',
    'Vaccination',
    'Growth Monitoring',
    'Nutritional Counseling',
    'Developmental Screening',
    'Behavioral Therapy',
    'Speech Therapy',
    'Occupational Therapy',
    'Neonatal Care',
    'Pediatric Emergency Care',
    'Allergy Testing',
    'Asthma Management',
    'Child Psychology Services',
    'Adolescent Health Services',
    'Chronic Disease Management',
    'Genetic Counseling',
    'Hearing and Vision Screening',
    'Pediatric Dental Care',
    'Immunization Programs',
    'Parenting Workshops',
    'Childhood Obesity Management',
  ];

  final List<String> conditionsOptions = [
    'Diabetes',
    'Hypertension',
    'Asthma',
    'Arthritis',
    'Cancer',
    'Autism Spectrum Disorder',
    'Attention Deficit Hyperactivity Disorder (ADHD)',
    'Cerebral Palsy',
    'Cystic Fibrosis',
    'Down Syndrome',
    'Epilepsy',
    'Food Allergies',
    'Hearing Loss',
    'Heart Defects (Congenital)',
    'Infectious Diseases (e.g., Chickenpox, Measles)',
    'Juvenile Rheumatoid Arthritis',
    'Leukemia',
    'Malnutrition',
    'Obesity',
    'Prematurity Complications',
    'Sickle Cell Anemia',
    'Speech and Language Disorders',
    'Thyroid Disorders',
    'Tuberculosis',
    'Vision Problems (e.g., Amblyopia, Strabismus)',
    'Developmental Delays',
    'Gastrointestinal Disorders (e.g., Crohn’s Disease, Celiac Disease)',
    'Mental Health Disorders (e.g., Anxiety, Depression)',
    'Skin Conditions (e.g., Eczema, Psoriasis)',
    'Respiratory Infections (e.g., Bronchiolitis, Pneumonia)',
  ];

  List<String> selectedServices = [];
  List<String> selectedConditions = [];

  final List<String> specializations = [
    'General Pediatrics', // Primary care for children
    'Pediatric Cardiology', // Heart conditions in children
    'Pediatric Dermatology', // Skin conditions in children
    'Pediatric Neurology', // Nervous system disorders in children
    'Pediatric Orthopedics', // Bone and joint issues in children
    'Pediatric Endocrinology', // Hormonal and growth disorders in children
    'Pediatric Gastroenterology', // Digestive system disorders in children
    'Pediatric Pulmonology', // Respiratory conditions in children
    'Pediatric Psychiatry', // Mental health in children
    'Pediatric Oncology', // Childhood cancers
    'Neonatology', // Care for newborns, especially premature or ill infants
    'Pediatric Allergy and Immunology', // Allergies and immune system disorders
    'Pediatric Nephrology', // Kidney disorders in children
    'Pediatric Hematology', // Blood disorders in children
    'Pediatric Infectious Diseases', // Infectious diseases in children
    'Pediatric Rheumatology', // Autoimmune and inflammatory conditions in children
    'Pediatric Emergency Medicine', // Emergency care for children
    'Pediatric Surgery', // Surgical care for children
    'Developmental Pediatrics', // Developmental and behavioral issues in children
    'Pediatric Rehabilitation', // Physical and cognitive rehabilitation for children
  ];

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    nameController = TextEditingController(text: "");
    experienceController = TextEditingController();
    fetchDoctorData();
  }

  @override
  void dispose() {
    nameController.dispose();
    experienceController.dispose();
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
          selectedTitle = title;
          nameController.text = name ?? "";
        });
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  Widget buildDropdownField({
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

  Widget buildMultiSelectSection({
    required String title,
    required List<String> options,
    required List<String> selectedOptions,
    required Function(String, bool) onSelected,
  }) {
    return ExpansionTile(
      title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      children: [
        Wrap(
          spacing: 8,
          children: options.map((option) => FilterChip(
            label: Text(option),
            selected: selectedOptions.contains(option),
            onSelected: (selected) => onSelected(option, selected),
          )).toList(),
        ),
      ],
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
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Confirm Your Details", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              buildDropdownField(
                label: 'Title',
                items: ['Dr.', 'Prof.', 'Assist. Prof.', 'Assoc. Prof.'],
                value: selectedTitle,
                onChanged: (value) => setState(() => selectedTitle = value),
              ),

              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: experienceController,
                decoration: const InputDecoration(labelText: "Years of Experience", hintText: "1 year", border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) return "Enter years of experience";
                  return null;
                },
              ),
              const SizedBox(height: 20),

              buildDropdownField(
                label: 'Primary Specialization',
                items: specializations,
                value: selectedPrimarySpecialization,
                onChanged: (value) => setState(() => selectedPrimarySpecialization = value),
              ),

              buildDropdownField(
                label: 'Secondary Specialization',
                items: specializations,
                value: selectedSecondarySpecialization,
                onChanged: (value) => setState(() => selectedSecondarySpecialization = value),
              ),

              buildMultiSelectSection(
                title: 'Services Offered',
                options: _servicesOptions,
                selectedOptions: selectedServices,
                onSelected: (option, selected) {
                  setState(() {
                    if (selected) {
                      selectedServices.add(option);
                    } else {
                      selectedServices.remove(option);
                    }
                  });
                },
              ),

              buildMultiSelectSection(
                title: 'Conditions Treated',
                options: conditionsOptions,
                selectedOptions: selectedConditions,
                onSelected: (option, selected) {
                  setState(() {
                    if (selected) {
                      selectedConditions.add(option);
                    } else {
                      selectedConditions.remove(option);
                    }
                  });
                },
              ),

              const SizedBox(height: 30),

              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      DatabaseService.AddDrProfessional_Info(
                        uid: user!.uid,
                        name: nameController.text,
                        title: selectedTitle ?? '',
                        experience: experienceController.text,
                        Primary_specialization: selectedPrimarySpecialization ?? '',
                        Secondary_specialization: selectedSecondarySpecialization ?? '',
                        Service_Offered: selectedServices,
                        Condition: selectedConditions,
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