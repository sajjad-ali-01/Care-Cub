import 'package:carecub/UI/DayCare_Account/Login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../Database/DataBaseReadServices.dart';
import '../../../Database/DatabaseServices.dart';

class DaycareProfileScreen extends StatefulWidget {
  @override
  _DaycareProfileScreenState createState() => _DaycareProfileScreenState();
}

class _DaycareProfileScreenState extends State<DaycareProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late DocumentSnapshot daycareData;
  bool isLoading = true;
  bool isEditing = false;
  File? profileImage;
  List<File> galleryImages = [];
  final picker = ImagePicker();

  // Controllers
  late TextEditingController nameController = TextEditingController();
  late TextEditingController descriptionController = TextEditingController();
  late TextEditingController licenseController = TextEditingController();
  late TextEditingController addressController = TextEditingController();
  late TextEditingController phoneController = TextEditingController();
  late TextEditingController emailController = TextEditingController();
  late TextEditingController capacityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadDaycareData();
  }

  Future<void> loadDaycareData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        daycareData = await DataBaseReadServices.fetchDaycareData(user.uid);
        _initializeControllers();
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Error loading data: $e");
      setState(() => isLoading = false);
    }
  }

  void _initializeControllers() {
    nameController = TextEditingController(text: daycareData['name']);
    descriptionController = TextEditingController(text: daycareData['description']);
    licenseController = TextEditingController(text: daycareData['license']);
    addressController = TextEditingController(text: daycareData['address']);
    phoneController = TextEditingController(text: daycareData['phone']);
    emailController = TextEditingController(text: daycareData['email']);
    capacityController = TextEditingController(text: daycareData['capacity']);
  }

  Future<void> _pickImage(bool isProfile) async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File image = File(pickedFile.path);
      if (isProfile) {
        setState(() => profileImage = image);
      } else {
        setState(() => galleryImages.add(image));
      }
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await DatabaseService.updateDaycareProfile(
            uid: user.uid,
            name: nameController.text,
            description: descriptionController.text,
            license: licenseController.text,
            address: addressController.text,
            phone: phoneController.text,
            capacity: capacityController.text,
          );

          setState(() => isEditing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Profile updated successfully!')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDaCareLoggedIn', false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => DayCareLogin()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.deepOrange.shade400,
        title: Text('Daycare Profile', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.save : Icons.edit, color: Colors.white),
            onPressed: () => isEditing ? _updateProfile() : setState(() => isEditing = true),
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildProfileImageSection(),
              _buildGallerySection(),
              _buildEditableInfoSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImageSection() {
    return Column(
      children: [
        GestureDetector(
          onTap: () => isEditing ? _pickImage(true) : null,
          child: CircleAvatar(
            radius: 65,
            backgroundImage: profileImage != null
                ? FileImage(profileImage!)
                : AssetImage('assets/images/daycareCenter1.webp') as ImageProvider<Object>?,
            child: isEditing && profileImage == null
                ? Icon(Icons.add_a_photo, color: Colors.purple, size: 30)
                : null,
          ),
        ),
        if (isEditing) Text('Tap to change profile image', style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildGallerySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text('Gallery Images', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemCount: galleryImages.length + (isEditing ? 1 : 0),
          itemBuilder: (context, index) {
            if (isEditing && index == galleryImages.length) {
              return GestureDetector(
                onTap: () => _pickImage(false),
                child: Container(
                  color: Colors.grey[200],
                  child: Icon(Icons.add_photo_alternate),
                ),
              );
            }
            return Stack(
              children: [
                Image.file(galleryImages[index], fit: BoxFit.cover),
                if (isEditing)
                  Positioned(
                    right: 0,
                    child: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => deleteImage(index),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Future<void> deleteImage(int index) async {
    setState(() {
      galleryImages.removeAt(index);
    });
  }

  Widget _buildEditableInfoSection() {
    return Column(
      children: [
        buildEditableField('Daycare Name', nameController),
        buildEditableField('Description', descriptionController, maxLines: 3),
        buildEditableField('License Number', licenseController),
        buildEditableField('Address', addressController),
        buildEditableField('Phone Number', phoneController),
        buildEditableField('Capacity', capacityController),
        buildReadOnlyField('Email', emailController.text),
      ],
    );
  }

  Widget buildEditableField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          enabled: isEditing,
        ),
        maxLines: maxLines,
        validator: (value) => value!.isEmpty ? 'Required field' : null,
      ),
    );
  }

  Widget buildReadOnlyField(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          enabled: false,
        ),
      ),
    );
  }
}