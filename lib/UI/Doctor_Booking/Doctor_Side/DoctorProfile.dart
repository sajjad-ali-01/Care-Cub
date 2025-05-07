import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  File? profileImage;
  final ImagePicker picker = ImagePicker();
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Map<String, dynamic> doctorData = {};
  bool isLoading = true;
  bool isUploadingImage = false;

  final List<String> titles = ['Dr.', 'Prof. Dr.', 'Assist. Prof.', 'Assoc. Prof.'];
  final List<String> specializations = [
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
  final List<String> servicesOptions = [
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
  final List<String> degrees = [
    "MBBS", "MD", "MS", "PhD", "BDS", "DCH", "DNB", "MRCPCH", "FAAP", "DM",
    "MSc", "MPH", "DPed", "FCPS", "MCh", "DO", "PG Diploma", "BSc Nursing", "MPhil", "FRCPCH",
  ];

  @override
  void initState() {
    super.initState();
    fetchDoctorData();
  }

  Future<void> fetchDoctorData() async {
    try {
      final user = auth.currentUser;
      if (user != null) {
        final doc = await firestore.collection('Doctors').doc(user.uid).get();
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

  Future<String?> _uploadImageToCloudinary() async {
    if (profileImage == null) return null;

    try {
      setState(() => isUploadingImage = true);

      const cloudName = 'dghmibjc3'; // Your Cloudinary cloud name
      const uploadPreset = 'CareCub'; // Your Cloudinary upload preset

      final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath(
          'file',
          profileImage!.path,
        ));

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.toBytes();
        final responseString = String.fromCharCodes(responseData);
        final jsonMap = jsonDecode(responseString);
        return jsonMap['secure_url'];
      } else {
        throw Exception('Failed to upload image to Cloudinary');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image: $e')),
      );
      return null;
    } finally {
      setState(() => isUploadingImage = false);
    }
  }

  Future<void> pickImage() async {
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          profileImage = File(pickedFile.path);
        });

        // Upload the image to Cloudinary
        final imageUrl = await _uploadImageToCloudinary();

        if (imageUrl != null) {
          // Update the photoUrl in Firestore
          await firestore.collection('Doctors')
              .doc(auth.currentUser!.uid)
              .update({'photoUrl': imageUrl});

          // Refresh the data to show the new image
          fetchDoctorData();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Profile picture updated successfully!')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }
  void editEducation() async {
    List<dynamic> currentEducation = doctorData['EDU_INFO'] ?? [];
    List<Map<String, dynamic>> educationDetails = [];

    if (currentEducation.isNotEmpty) {
      for (var edu in currentEducation) {
        if (edu is String) {
          
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
                    ...educationDetails.map((edu) => buildEducationCard(edu, setState,educationDetails)).toList(),
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
                      await firestore.collection('Doctors')
                          .doc(auth.currentUser!.uid)
                          .update({'EDU_INFO': formattedEducation});
                      fetchDoctorData();
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

  Widget buildEducationCard(Map<String, dynamic> edu, StateSetter setState, List<Map<String, dynamic>> educationDetails) {
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
              items: degrees.map((degree) => DropdownMenuItem(
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

  void editField(String fieldName, dynamic currentValue) async {
    dynamic newValue = currentValue;

    await showDialog(
      context: context,
      builder: (context) {
        if (fieldName == 'title' ||
            fieldName == 'Primary_specialization' ||
            fieldName == 'Secondary_specialization') {
          
          return AlertDialog(
            title: Text("Edit ${fieldName.replaceAll('_', ' ')}"),
            content: DropdownButtonFormField<String>(
              value: currentValue,
              items: (fieldName == 'title' ? titles : specializations)
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
                    await updateField(fieldName, newValue);
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
                    await updateField(fieldName, controller.text);
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

  Future<void> updateField(String fieldName, dynamic value) async {
    try {
      await firestore.collection('Doctors').doc(auth.currentUser!.uid).update({
        fieldName: value
      });
      fetchDoctorData();
    } catch (e) {
      print('Error updating field: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update $fieldName')),
      );
    }
  }

  void editArrayField(String fieldName, List<dynamic> currentList) async {
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
                      buildMultiSelectField(fieldName, newList, setState),
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
                      await firestore.collection('Doctors')
                          .doc(auth.currentUser!.uid)
                          .update({fieldName: newList});
                      fetchDoctorData();
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

  Widget buildMultiSelectField(String fieldName, List<dynamic> selectedItems, StateSetter setState) {
    List<String> options = fieldName == 'Service_Offered'
        ? servicesOptions
        : conditionsOptions;

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
    // Show confirmation dialog
    bool confirmLogout = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm Logout"),
        content: Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    // Only proceed with logout if user confirmed
    if (confirmLogout == true) {
      await auth.signOut();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDrLoggedIn', false);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const DrLogin()),
            (Route<dynamic> route) => false,
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    if (isLoading || isUploadingImage) {
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
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: pickImage,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: profileImage != null
                          ? FileImage(profileImage!)
                          : (doctorData['photoUrl']?.isNotEmpty ?? false
                          ? NetworkImage(doctorData['photoUrl'])
                          : AssetImage("assets/images/profile_pic.png")) as ImageProvider,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.deepOrange,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    ),
                  ),
                ],
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

            // ... (keep all your existing buildSectionHeader, buildEditableField,
            // buildArrayField widgets and other UI elements)

            // Basic Information Section
            buildSectionHeader("Basic Information"),
            buildEditableField("Name", doctorData['name'] ?? '', 'name'),
            buildEditableField("Email", doctorData['email'] ?? '', 'email'),
            buildEditableField("Phone", doctorData['phone'] ?? '', 'phone'),
            buildEditableField("City", doctorData['city'] ?? '', 'city'),
            buildEditableField("Experience", doctorData['experience'] ?? '', 'experience'),
            buildEditableField("Title", doctorData['title'] ?? '', 'title'),

            // Professional Information
            buildSectionHeader("Professional Information"),
            buildEditableField("PMC Number", doctorData['PMCNumber'] ?? '', 'PMCNumber'),
            buildEditableField("Primary Specialization",
                doctorData['Primary_specialization'] ?? '', 'Primary_specialization'),
            buildEditableField("Secondary Specialization",
                doctorData['Secondary_specialization'] ?? '', 'Secondary_specialization'),

            // Education Section
            buildSectionHeader("Education"),
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
              onPressed: editEducation,
              child: Text("Edit Education"),
            ),

            // Services Offered
            buildSectionHeader("Services Offered"),
            buildArrayField("Services", doctorData['Service_Offered'] ?? [], 'Service_Offered'),

            // Conditions Treated
            buildSectionHeader("Conditions Treated"),
            buildArrayField("Conditions", doctorData['Condition'] ?? [], 'Condition'),

            // Verification Status
            buildSectionHeader("Account Status"),
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

  Widget buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepOrange),
      ),
    );
  }

  Widget buildEditableField(String label, String value, String fieldName) {
    return ListTile(
      title: Text(label),
      subtitle: Text(value.isNotEmpty ? value : "Not specified"),
      trailing: Icon(Icons.edit),
      onTap: () => editField(fieldName, value),
    );
  }

  Widget buildArrayField(String label, List<dynamic> items, String fieldName) {
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
                  await firestore.collection('Doctors')
                      .doc(auth.currentUser!.uid)
                      .update({
                    fieldName: FieldValue.arrayRemove([item])
                  });
                  fetchDoctorData();
                },
              ),
            )
        ).toList(),
        TextButton(
          onPressed: () => editArrayField(fieldName, items),
          child: Text("Edit $label"),
        ),
      ],
    );
  }
}