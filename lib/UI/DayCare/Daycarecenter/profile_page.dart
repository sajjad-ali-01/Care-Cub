import 'package:carecub/UI/DayCare_Account/Login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:photo_view/photo_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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
  bool _isUploading = false;
  File? profileImage;
  List<File> galleryImages = [];
  List<String> galleryImageUrls = [];
  final picker = ImagePicker();

  // Controllers for all fields
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController licenseController;
  late TextEditingController addressController;
  late TextEditingController phoneController;
  late TextEditingController emailController;
  late TextEditingController capacityController;
  late TextEditingController ageRangeController;
  late TextEditingController hoursController;

  List<String> facilities = [];
  List<String> safetyFeatures = [];
  List<String> operatingDays = [];
  List<Map<String, String>> programs = [];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    loadDaycareData();
  }

  void _initializeControllers() {
    nameController = TextEditingController();
    descriptionController = TextEditingController();
    licenseController = TextEditingController();
    addressController = TextEditingController();
    phoneController = TextEditingController();
    emailController = TextEditingController();
    capacityController = TextEditingController();
    ageRangeController = TextEditingController();
    hoursController = TextEditingController();
  }

  Future<void> loadDaycareData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        daycareData = await DataBaseReadServices.fetchDaycareData(user.uid);
        final data = daycareData.data() as Map<String, dynamic>? ?? {};

        setState(() {
          galleryImageUrls = List<String>.from(data['galleryImages'] ?? []);
          facilities = List<String>.from(data['facilities'] ?? []);
          safetyFeatures = List<String>.from(data['safetyFeatures'] ?? []);
          operatingDays = List<String>.from(data['operatingDays'] ?? []);
          programs = List<Map<String, String>>.from(data['programs']?.map((p) => Map<String, String>.from(p)) ?? []);

              nameController.text = data['name'] ?? '';
              descriptionController.text = data['description'] ?? '';
              licenseController.text = data['license'] ?? '';
              addressController.text = data['address'] ?? '';
              phoneController.text = data['phone'] ?? '';
              emailController.text = data['email'] ?? '';
              capacityController.text = data['capacity'] ?? '';
              ageRangeController.text = data['ageRange'] ?? '';
              hoursController.text = data['hours'] ?? '';

              isLoading = false;
          });
      }
    } catch (e) {
      print("Error loading data: $e");
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading profile data')),
      );
    }
  }


  Future<void> _pickImage(bool isProfile) async {
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        File image = File(pickedFile.path);
        setState(() {
          if (isProfile) {
            profileImage = image;
          } else {
            galleryImages.add(image);
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<String?> _uploadImageToCloudinary(File imageFile) async {
    try {
      setState(() => _isUploading = true);

      final url = Uri.parse('https://api.cloudinary.com/v1_1/dghmibjc3/upload');
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = 'CareCub'
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.toBytes();
        final responseString = String.fromCharCodes(responseData);
        final jsonMap = jsonDecode(responseString);
        return jsonMap['secure_url'] ?? jsonMap['url'];
      } else {
        throw Exception('Failed to upload image to Cloudinary');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image: $e')),
      );
      return null;
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          // Handle profile image upload
          String? profileImageUrl;
          if (profileImage != null) {
            profileImageUrl = await _uploadImageToCloudinary(profileImage!);
          }

          // Upload new gallery images
          List<String> newGalleryUrls = [];
          for (var image in galleryImages) {
            final url = await _uploadImageToCloudinary(image);
            if (url != null) {
              newGalleryUrls.add(url);
            }
          }

          // Combine existing URLs with new ones
          List<String> allGalleryUrls = [...galleryImageUrls, ...newGalleryUrls];

          await DatabaseService.updateDaycareProfile(
            uid: user.uid,
            name: nameController.text,
            description: descriptionController.text,
            license: licenseController.text,
            address: addressController.text,
            phone: phoneController.text,
            capacity: capacityController.text,
            profileImageUrl: profileImageUrl,
            galleryImageUrls: allGalleryUrls,
          );

          // Also update other fields
          await FirebaseFirestore.instance
              .collection('DayCare')
              .doc(user.uid)
              .update({
            'ageRange': ageRangeController.text,
            'hours': hoursController.text,
            'facilities': facilities,
            'safetyFeatures': safetyFeatures,
            'operatingDays': operatingDays,
            'programs': programs,
            'updatedAt': FieldValue.serverTimestamp(),
          });

          // Refresh data after update
          await loadDaycareData();

          setState(() {
            isEditing = false;
            galleryImages.clear();
          });

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

  Future<void> _deleteGalleryImage(int index) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        List<String> updatedGalleryUrls = List.from(galleryImageUrls);
        updatedGalleryUrls.removeAt(index);

        await FirebaseFirestore.instance
            .collection('DayCare')
            .doc(user.uid)
            .update({'galleryImages': updatedGalleryUrls});

        setState(() {
          galleryImageUrls = updatedGalleryUrls;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image deleted successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting image: $e')),
      );
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

  Widget _buildListField(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: items.map((item) => Chip(label: Text(item))).toList(),
        ),
      ],
    );
  }

  Widget _buildProgramsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Programs', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        ...programs.map((program) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${program['name'] ?? ''}'),
            Text('Age Range: ${program['ageRange'] ?? ''}'),
            Text('Description: ${program['description'] ?? ''}'),
            Divider(),
          ],
        )).toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_isUploading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Uploading images...'),
            ],
          ),
        ),
      );
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
              SizedBox(height: 20),
              _buildListField('Facilities', facilities),
              SizedBox(height: 20),
              _buildListField('Safety Features', safetyFeatures),
              SizedBox(height: 20),
              _buildListField('Operating Days', operatingDays),
              SizedBox(height: 20),
              _buildProgramsField(),
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
            backgroundImage: _getProfileImage(),
            child: isEditing && profileImage == null
                ? Icon(Icons.add_a_photo, color: Colors.purple, size: 30)
                : null,
          ),
        ),
        if (isEditing) Text('Tap to change profile image', style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  ImageProvider? _getProfileImage() {
    if (profileImage != null) {
      return FileImage(profileImage!);
    }

    try {
      final data = daycareData.data() as Map<String, dynamic>?;
      final imageUrl = data?['profileImageUrl'] as String?;
      if (imageUrl != null && imageUrl.isNotEmpty) {
        return NetworkImage(imageUrl);
      }
    } catch (e) {
      print("Error getting profile image URL: $e");
    }

    return AssetImage('assets/images/daycareCenter1.webp') as ImageProvider<Object>?;
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
          itemCount: galleryImageUrls.length + galleryImages.length + (isEditing ? 1 : 0),
          itemBuilder: (context, index) {
            if (isEditing && index == galleryImageUrls.length + galleryImages.length) {
              return GestureDetector(
                onTap: () => _pickImage(false),
                child: Container(
                  color: Colors.grey[200],
                  child: Icon(Icons.add_photo_alternate),
                ),
              );
            }

            if (index < galleryImageUrls.length) {
              return GestureDetector(
                onTap: () => _showFullScreenImage(galleryImageUrls[index]),
                child: Stack(
                  children: [
                    Image.network(galleryImageUrls[index], fit: BoxFit.cover),
                    if (isEditing)
                      Positioned(
                        right: 0,
                        child: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red, size: 20),
                          onPressed: () => _deleteGalleryImage(index),
                        ),
                      ),
                  ],
                ),
              );
            }

            final localIndex = index - galleryImageUrls.length;
            return GestureDetector(
              onTap: () {
                // For newly added images not yet uploaded, we can show a temporary preview
                showDialog(
                  context: context,
                  builder: (context) => Dialog(
                    child: PhotoView(
                      imageProvider: FileImage(galleryImages[localIndex]),
                      minScale: PhotoViewComputedScale.contained,
                      maxScale: PhotoViewComputedScale.covered * 2,
                    ),
                  ),
                );
              },
              child: Image.file(galleryImages[localIndex], fit: BoxFit.cover),
            );
          },
        ),
      ],
    );
  }
  void _showFullScreenImage(String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          extendBodyBehindAppBar: true, // Allows content to go behind AppBar
          appBar: AppBar(
            backgroundColor: Colors.transparent, // Make AppBar transparent
            elevation: 0, // Remove shadow
            actions: [
              if (isEditing)
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    Navigator.pop(context);
                    _deleteGalleryImage(galleryImageUrls.indexOf(imageUrl));
                  },
                ),
            ],
          ),
          body: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              color: Colors.black,
              child: PhotoView(
                imageProvider: NetworkImage(imageUrl),
                minScale: PhotoViewComputedScale.covered, // Ensures full coverage
                maxScale: PhotoViewComputedScale.covered * 3, // Allows zooming
                initialScale: PhotoViewComputedScale.covered, // Starts covering the screen
                basePosition: Alignment.center, // Centers the image
                backgroundDecoration: BoxDecoration(color: Colors.black),
              ),
            ),
          ),
        ),
      ),
    );
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
        buildEditableField('Age Range', ageRangeController),
        buildEditableField('Operating Hours', hoursController),
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