import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Dr_Account/Login.dart';

class DoctorProfilePage extends StatefulWidget {
  @override
  _DoctorProfilePageState createState() => _DoctorProfilePageState();
}

class _DoctorProfilePageState extends State<DoctorProfilePage> {
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String email = "email@example.com";
  int experienceYears = 5;
  List<Map<String, String>> workExperience = [
    {"place": "City Hospital", "position": "Senior Surgeon"},
    {"place": "Health Clinic", "position": "General Physician"}
  ];
  List<String> studies = ["MBBS - XYZ University", "MD - ABC Institute"];
  List<String> services = ["Surgery", "General Consultation", "Emergency Care"];
  String clinicName = "General Medical Clinic";
  String clinicAddress = "123 Medical Street, City";

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  void _editField(String title, String currentValue, Function(String) onSave) {
    TextEditingController controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit $title"),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: "Enter new $title"),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  onSave(controller.text);
                  setState(() {});
                }
                Navigator.pop(context);
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _addToList(String title, List<dynamic> list, Function(List<dynamic>) onSave) {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add $title"),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: "Enter $title"),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  list.add(controller.text);
                  onSave(list);
                  setState(() {});
                }
                Navigator.pop(context);
              },
              child: Text("Add"),
            ),
          ],
        );
      },
    );
  }

  void _addWorkExperience() {
    TextEditingController placeController = TextEditingController();
    TextEditingController positionController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add Work Experience"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: placeController, decoration: InputDecoration(hintText: "Enter Workplace")),
              SizedBox(height: 10),
              TextField(controller: positionController, decoration: InputDecoration(hintText: "Enter Position")),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
            TextButton(
              onPressed: () {
                if (placeController.text.isNotEmpty && positionController.text.isNotEmpty) {
                  setState(() {
                    workExperience.add({"place": placeController.text, "position": positionController.text});
                  });
                }
                Navigator.pop(context);
              },
              child: Text("Add"),
            ),
          ],
        );
      },
    );
  }

  // Logout function
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
                      : AssetImage("assets/images/profile_pic.png") as ImageProvider,
                ),
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: Text("Dr. Faseeh", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ),
            SizedBox(height: 16),

            ListTile(
              title: Text("Email"),
              subtitle: Text(email),
              trailing: Icon(Icons.edit),
              onTap: () => _editField("Email", email, (newValue) => email = newValue),
            ),

            ListTile(
              title: Text("Experience (Years)"),
              subtitle: Text("$experienceYears years"),
              trailing: Icon(Icons.edit),
              onTap: () => _editField("Experience", experienceYears.toString(), (newValue) {
                experienceYears = int.tryParse(newValue) ?? experienceYears;
              }),
            ),

            ListTile(
              title: Text("Work Experience"),
              trailing: Icon(Icons.add),
              onTap: _addWorkExperience,
            ),
            ...workExperience.map((work) => ListTile(
              title: Text(work["place"]!),
              subtitle: Text(work["position"]!),
            )),

            ListTile(
              title: Text("Studies"),
              trailing: Icon(Icons.add),
              onTap: () => _addToList("Study", studies, (newList) => studies = newList.cast<String>()),
            ),
            ...studies.map((study) => ListTile(title: Text(study))),

            ListTile(
              title: Text("Services Offered"),
              trailing: Icon(Icons.add),
              onTap: () => _addToList("Service", services, (newList) => services = newList.cast<String>()),
            ),
            ...services.map((service) => ListTile(title: Text(service))),

            ListTile(
              title: Text("Clinic Name"),
              subtitle: Text(clinicName),
              trailing: Icon(Icons.edit),
              onTap: () => _editField("Clinic Name", clinicName, (newValue) => clinicName = newValue),
            ),

            ListTile(
              title: Text("Clinic Address"),
              subtitle: Text(clinicAddress),
              trailing: Icon(Icons.edit),
              onTap: () => _editField("Clinic Address", clinicAddress, (newValue) => clinicAddress = newValue),
            ),
          ],
        ),
      ),
    );
  }
}