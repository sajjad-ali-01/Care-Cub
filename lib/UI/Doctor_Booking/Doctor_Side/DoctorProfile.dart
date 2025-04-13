import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../Dr_Account/Login.dart';

class DoctorProfilePage extends StatefulWidget {
  @override
  _DoctorProfilePageState createState() => _DoctorProfilePageState();
}

class _DoctorProfilePageState extends State<DoctorProfilePage> {
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic> doctorData = {};
  bool isLoading = true;

  // Options for dropdowns
  final List<String> _titles = ['Dr.', 'Prof.', 'Assist. Prof.', 'Assoc. Prof.'];
  final List<String> _specializations = [
    'General Pediatrics',
    'Pediatric Cardiology',
    'Pediatric Dermatology',
    'Pediatric Neurology',
    'Pediatric Orthopedics',
    'Pediatric Endocrinology',
    'Pediatric Gastroenterology',
    'Pediatric Pulmonology',
    'Pediatric Psychiatry',
    'Pediatric Oncology',
    'Neonatology',
    'Pediatric Allergy and Immunology',
    'Pediatric Nephrology',
    'Pediatric Hematology',
    'Pediatric Infectious Diseases',
    'Pediatric Rheumatology',
    'Pediatric Emergency Medicine',
    'Pediatric Surgery',
    'Developmental Pediatrics',
    'Pediatric Rehabilitation',
  ];
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
  final List<String> _conditionsOptions = [
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
  final List<String> _degrees = [
    "MBBS", "MD", "MS", "PhD", "BDS", "DCH", "DNB", "MRCPCH", "FAAP", "DM",
    "MSc", "MPH", "DPed", "FCPS", "MCh", "DO", "PG Diploma", "BSc Nursing", "MPhil", "FRCPCH",
  ];

  @override
  void initState() {
    super.initState();
    _fetchDoctorData();
  }

  Future<void> _fetchDoctorData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('Doctors').doc(user.uid).get();
        if (doc.exists) {
          setState(() {
            doctorData = doc.data()!;
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error fetching doctor data: $e');
      setState(() => isLoading = false);
    }
  }
  void _editEducation() async {
    List<dynamic> currentEducation = doctorData['EDU_INFO'] ?? [];
    List<Map<String, dynamic>> educationDetails = [];

    // Parse existing education if available
    if (currentEducation.isNotEmpty) {
      for (var edu in currentEducation) {
        if (edu is String) {
          // Parse the string format: "Degree (Year) - College, City, Country"
          try {
            final parts = edu.split(' - ');
            final degreeYear = parts[0].split(' (');
            final collegeLocation = parts[1].split(', ');

            educationDetails.add({
              'degree': degreeYear[0],
              'year': degreeYear[1].replaceAll(')', ''),
              'college': collegeLocation[0],
              'city': collegeLocation[1],
              'country': collegeLocation[2],
            });
          } catch (e) {
            print('Error parsing education entry: $edu');
          }
        }
      }
    }

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Edit Education"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...educationDetails.map((edu) => _buildEducationCard(edu, setState,educationDetails)).toList(),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          educationDetails.add({
                            'degree': '',
                            'year': '',
                            'college': '',
                            'city': '',
                            'country': '',
                          });
                        });
                      },
                      child: Text("Add New Education"),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel"),
                ),
                TextButton(
                  onPressed: () async {
                    List<String> formattedEducation = [];
                    for (var edu in educationDetails) {
                      if (edu['degree']!.isNotEmpty &&
                          edu['year']!.isNotEmpty &&
                          edu['college']!.isNotEmpty &&
                          edu['city']!.isNotEmpty &&
                          edu['country']!.isNotEmpty) {
                        formattedEducation.add(
                            "${edu['degree']} (${edu['year']}) - ${edu['college']}, ${edu['city']}, ${edu['country']}"
                        );
                      }
                    }

                    try {
                      await _firestore.collection('Doctors')
                          .doc(_auth.currentUser!.uid)
                          .update({'EDU_INFO': formattedEducation});
                      _fetchDoctorData();
                    } catch (e) {
                      print('Error updating education: $e');
                    }

                    Navigator.pop(context);
                  },
                  child: Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildEducationCard(Map<String, dynamic> edu, StateSetter setState, List<Map<String, dynamic>> educationDetails) {
    String? selectedDegree = edu['degree']!.isEmpty ? null : edu['degree'];


    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: selectedDegree,
              decoration: InputDecoration(labelText: "Degree"),
              items: _degrees.map((degree) => DropdownMenuItem(
                value: degree,
                child: Text(degree),
              )).toList(),
              onChanged: (value) {
                setState(() {
                  edu['degree'] = value;
                });
              },
            ),
            SizedBox(height: 8),
            TextFormField(
              decoration: InputDecoration(labelText: "Year"),
              initialValue: edu['year'],
              onChanged: (value) => edu['year'] = value,
            ),
            SizedBox(height: 8),
            TextFormField(
              decoration: InputDecoration(labelText: "College/University"),
              initialValue: edu['college'],
              onChanged: (value) => edu['college'] = value,
            ),
            SizedBox(height: 8),
            TextFormField(
              decoration: InputDecoration(labelText: "City"),
              initialValue: edu['city'],
              onChanged: (value) => edu['city'] = value,
            ),
            SizedBox(height: 8),
            TextFormField(
              decoration: InputDecoration(labelText: "Country"),
              initialValue: edu['country'],
              onChanged: (value) => edu['country'] = value,
            ),
            SizedBox(height: 8),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                setState(() {
                  educationDetails.remove(edu);
                });
              },
            ),
          ],
        ),
      ),
    );
  }


  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
      // TODO: Upload image to Firebase Storage and update photoUrl
    }
  }

  void _editField(String fieldName, dynamic currentValue) async {
    dynamic newValue = currentValue;

    await showDialog(
      context: context,
      builder: (context) {
        if (fieldName == 'title' ||
            fieldName == 'Primary_specialization' ||
            fieldName == 'Secondary_specialization') {
          // Handle dropdown fields
          return AlertDialog(
            title: Text("Edit ${fieldName.replaceAll('_', ' ')}"),
            content: DropdownButtonFormField<String>(
              value: currentValue,
              items: (fieldName == 'title' ? _titles : _specializations)
                  .map((item) => DropdownMenuItem(
                value: item,
                child: Text(item),
              ))
                  .toList(),
              onChanged: (value) => newValue = value,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  if (newValue != null) {
                    await _updateField(fieldName, newValue);
                  }
                  Navigator.pop(context);
                },
                child: Text("Save"),
              ),
            ],
          );
        } else {
          // Handle text fields
          TextEditingController controller =
          TextEditingController(text: currentValue?.toString() ?? '');
          return AlertDialog(
            title: Text("Edit ${fieldName.replaceAll('_', ' ')}"),
            content: TextField(controller: controller),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  if (controller.text.isNotEmpty) {
                    await _updateField(fieldName, controller.text);
                  }
                  Navigator.pop(context);
                },
                child: Text("Save"),
              ),
            ],
          );
        }
      },
    );
  }

  Future<void> _updateField(String fieldName, dynamic value) async {
    try {
      await _firestore.collection('Doctors').doc(_auth.currentUser!.uid).update({
        fieldName: value
      });
      _fetchDoctorData(); // Refresh data
    } catch (e) {
      print('Error updating field: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update $fieldName')),
      );
    }
  }

  void _editArrayField(String fieldName, List<dynamic> currentList) async {
    List<dynamic> newList = List.from(currentList);
    bool changesMade = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Edit ${fieldName.replaceAll('_', ' ')}"),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    if (fieldName == 'Service_Offered' || fieldName == 'Condition')
                      _buildMultiSelectField(fieldName, newList, setState),
                    if (fieldName == 'EDU_INFO')
                      ...newList.map((item) => ListTile(
                        title: Text(item),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              newList.remove(item);
                              changesMade = true;
                            });
                          },
                        ),
                      )),
                  ],
                ),
              ),
              actions: [
                if (fieldName == 'EDU_INFO')
                  TextButton(
                    onPressed: () {
                      TextEditingController controller = TextEditingController();
                      showDialog(
                        context: context,
                        builder: (innerContext) => AlertDialog(
                          title: Text("Add Education"),
                          content: TextField(controller: controller),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(innerContext),
                              child: Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () {
                                if (controller.text.isNotEmpty) {
                                  setState(() {
                                    newList.add(controller.text);
                                    changesMade = true;
                                  });
                                  Navigator.pop(innerContext);
                                }
                              },
                              child: Text("Add"),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Text("Add"),
                  ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel"),
                ),
                TextButton(
                  onPressed: () async {
                    if (changesMade || newList.length != currentList.length) {
                      await _firestore.collection('Doctors')
                          .doc(_auth.currentUser!.uid)
                          .update({fieldName: newList});
                      _fetchDoctorData();
                    }
                    Navigator.pop(context);
                  },
                  child: Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildMultiSelectField(String fieldName, List<dynamic> selectedItems, StateSetter setState) {
    List<String> options = fieldName == 'Service_Offered'
        ? _servicesOptions
        : _conditionsOptions;

    return Wrap(
      spacing: 8,
      children: options.map((option) =>
          FilterChip(
            label: Text(option),
            selected: selectedItems.contains(option),
            onSelected: (selected) {
              setState(() {
                if (selected) {
                  selectedItems.add(option);
                } else {
                  selectedItems.remove(option);
                }
              });
            },
          )).toList(),
    );
  }

  void logout() async {
    await _auth.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDrLoggedIn', false);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const DrLogin()),
          (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text("Doctor Profile")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Doctor Profile"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: _profileImage != null
                      ? FileImage(_profileImage!)
                      : (doctorData['photoUrl']?.isNotEmpty ?? false
                      ? NetworkImage(doctorData['photoUrl'])
                      : AssetImage("assets/images/profile_pic.png")) as ImageProvider,
                ),
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: Text(
                "${doctorData['title'] ?? ''} ${doctorData['name'] ?? 'Doctor'}",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 24),

            // Basic Information Section
            _buildSectionHeader("Basic Information"),
            _buildEditableField("Name", doctorData['name'] ?? '', 'name'),
            _buildEditableField("Email", doctorData['email'] ?? '', 'email'),
            _buildEditableField("Phone", doctorData['phone'] ?? '', 'phone'),
            _buildEditableField("City", doctorData['city'] ?? '', 'city'),
            _buildEditableField("Experience", doctorData['experience'] ?? '', 'experience'),
            _buildEditableField("Title", doctorData['title'] ?? '', 'title'),

            // Professional Information
            _buildSectionHeader("Professional Information"),
            _buildEditableField("PMC Number", doctorData['PMCNumber'] ?? '', 'PMCNumber'),
            _buildEditableField("Primary Specialization",
                doctorData['Primary_specialization'] ?? '', 'Primary_specialization'),
            _buildEditableField("Secondary Specialization",
                doctorData['Secondary_specialization'] ?? '', 'Secondary_specialization'),


            // Education Section
            _buildSectionHeader("Education"),
            if ((doctorData['EDU_INFO'] ?? []).isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text("No education information added", style: TextStyle(color: Colors.grey)),
              ),
            ...(doctorData['EDU_INFO'] ?? []).map<Widget>((edu) {
              if (edu is String) {
                return ListTile(
                  title: Text(edu.split(' - ')[0]), // Show degree and year
                  subtitle: Text(edu.split(' - ')[1]), // Show college and location
                );
              }
              return SizedBox.shrink();
            }).toList(),
            TextButton(
              onPressed: _editEducation,
              child: Text("Edit Education"),
            ),
            // Services Offered
            _buildSectionHeader("Services Offered"),
            _buildArrayField("Services", doctorData['Service_Offered'] ?? [], 'Service_Offered'),

            // Conditions Treated
            _buildSectionHeader("Conditions Treated"),
            _buildArrayField("Conditions", doctorData['Condition'] ?? [], 'Condition'),
            // Verification Status
            _buildSectionHeader("Account Status"),
            ListTile(
              title: Text("Verification Status"),
              trailing: Chip(
                label: Text(doctorData['isVerified'] == true ? "Verified" : "Not Verified"),
                backgroundColor: doctorData['isVerified'] == true ? Colors.green.shade100 : Colors.orange.shade100,
              ),
            ),

            // Account Created Date
            if (doctorData['createdAt'] != null)
              ListTile(
                title: Text("Member Since"),
                subtitle: Text(DateFormat('MMMM dd, yyyy').format((doctorData['createdAt'] as Timestamp).toDate())),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepOrange),
      ),
    );
  }

  Widget _buildEditableField(String label, String value, String fieldName) {
    return ListTile(
      title: Text(label),
      subtitle: Text(value.isNotEmpty ? value : "Not specified"),
      trailing: Icon(Icons.edit),
      onTap: () => _editField(fieldName, value),
    );
  }

  Widget _buildArrayField(String label, List<dynamic> items, String fieldName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (items.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text("No $label added", style: TextStyle(color: Colors.grey)),
          ),
        ...items.map<Widget>((item) =>
            ListTile(
              title: Text(item.toString()),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () async {
                  await _firestore.collection('Doctors')
                      .doc(_auth.currentUser!.uid)
                      .update({
                    fieldName: FieldValue.arrayRemove([item])
                  });
                  _fetchDoctorData();
                },
              ),
            )
        ).toList(),
        TextButton(
          onPressed: () => _editArrayField(fieldName, items),
          child: Text("Edit $label"),
        ),
      ],
    );
  }
}