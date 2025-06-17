import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'Login.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  String? selectedChildGender;
  final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: ['https://www.googleapis.com/auth/drive.file'],
  );

  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController childNameController;
  late TextEditingController childDobController;
  File? pickedImage;
  bool isEditing = false;
  bool isUpdating = false;
  bool isUploadingImage = false;
  DateTime? selectedChildDob;
  String? childId;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    phoneController = TextEditingController();
    childNameController = TextEditingController();
    childDobController = TextEditingController();
    selectedChildGender = 'Boy';
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    childNameController.dispose();
    childDobController.dispose();
    super.dispose();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserDataStream() {
    final String? uid = auth.currentUser?.uid;
    if (uid != null) {
      return firestore.collection('users').doc(uid).snapshots();
    }
    throw Exception('User not logged in');
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getChildDataStream() {
    final String? uid = auth.currentUser?.uid;
    if (uid != null) {
      return firestore
          .collection('users')
          .doc(uid)
          .collection('babyProfiles')
          .snapshots();
    }
    throw Exception('User not logged in');
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          pickedImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  Future<String?> _uploadImageToCloudinary() async {
    if (pickedImage == null) return null;

    try {
      setState(() => isUploadingImage = true);

      const cloudName = 'dghmibjc3';
      const uploadPreset = 'CareCub';

      final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath(
          'file',
          pickedImage!.path,
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

  Future<void> updateProfile() async {
    final user = auth.currentUser;
    if (user == null) return;

    setState(() => isUpdating = true);

    try {
      String? imageUrl;
      if (pickedImage != null) {
        imageUrl = await _uploadImageToCloudinary();
      }

      final userData = {
        'name': nameController.text,
        'phone': phoneController.text,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (imageUrl != null) {
        userData['photoUrl'] = imageUrl;
      }

      await firestore.collection('users').doc(user.uid).update(userData);

      if (childId != null) {
        await firestore
            .collection('users')
            .doc(user.uid)
            .collection('babyProfiles')
            .doc(childId)
            .update({
          'name': childNameController.text,
          'dateOfBirth': selectedChildDob,
          'gender': selectedChildGender, // Add gender to update
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully!')),
      );

      setState(() {
        isEditing = false;
        pickedImage = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Update failed: ${e.toString()}')),
      );
    } finally {
      setState(() => isUpdating = false);
    }
  }
  Future<void> selectChildDob(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedChildDob ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        selectedChildDob = picked;
        childDobController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  void ConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Update'),
        content: Text('Are you sure you want to update your profile and child details?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              updateProfile();
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  void logout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await auth.signOut();
              await googleSignIn.signOut();
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setBool('isLoggedIn', false);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const Login()),
                    (Route<dynamic> route) => false,
              );
            },
            child: Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFEBFF),
      appBar: AppBar(
        title: Text('User Profile', style: TextStyle(color: Colors.white)),
        leading: IconButton(onPressed: (){Navigator.pop(context);}, icon: Icon(Icons.arrow_back,color: Colors.white,)),
        backgroundColor: Colors.deepOrange.shade500,
        actions: [
          if (isEditing)
            IconButton(
              icon: Icon(Icons.save,color: Colors.white,),
              onPressed: () => ConfirmationDialog(),
            )
          else
            IconButton(
              icon: Icon(Icons.edit,color: Colors.white,),
              onPressed: () => setState(() => isEditing = true),
            )
        ],
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Main content
          isUpdating || isUploadingImage
              ? Center(child: CircularProgressIndicator())
              : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: getUserDataStream(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

              final data = snapshot.data!.data() ?? {};
              if (!isEditing) {
                nameController.text = data['name'] ?? '';
                phoneController.text = data['phone'] ?? '';
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User Profile Section
                    GestureDetector(
                      onTap: isEditing ? _pickImage : null,
                      child: Center(
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 70,
                              backgroundImage: pickedImage != null
                                  ? FileImage(pickedImage!)
                                  : (data['photoUrl'] != null
                                  ? NetworkImage(data['photoUrl'])
                                  : null),
                              child: pickedImage == null && data['photoUrl'] == null
                                  ? Text(
                                data['name']?.isNotEmpty == true
                                    ? data['name'][0].toUpperCase()
                                    : '?',
                                style: TextStyle(fontSize: 40),
                              )
                                  : null,
                            ),
                            if (isEditing)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.deepOrange,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.edit, color: Colors.white, size: 20),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: 'Name'),
                      enabled: isEditing,
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: TextEditingController(text: data['email'] ?? ''),
                      decoration: InputDecoration(labelText: 'Email'),
                      readOnly: true,
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: phoneController,
                      decoration: InputDecoration(labelText: 'Phone'),
                      enabled: isEditing,
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 20),

                    // Child Details Section
                    Text(
                      'Child Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange.shade500,
                      ),
                    ),
                    SizedBox(height: 10),
                    StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: getChildDataStream(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

                        final children = snapshot.data!.docs;
                        if (children.isEmpty) {
                          return Text('No child data found.');
                        }

                        final childData = children.first.data();
                        childId = children.first.id;
                        final name = childData['name'] ?? 'No Name';
                        final dob = childData['dateOfBirth']?.toDate();
                        final gender = childData['gender'] ?? 'Boy';

                        if (!isEditing) {
                          childNameController.text = name;
                          selectedChildDob = dob;
                          selectedChildGender = gender;
                          childDobController.text = dob != null
                              ? "${dob.day}/${dob.month}/${dob.year}"
                              : '';
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: childNameController,
                              decoration: InputDecoration(labelText: 'Child Name'),
                              enabled: isEditing,
                            ),
                            SizedBox(height: 10),
                            TextField(
                              controller: childDobController,
                              decoration: InputDecoration(labelText: 'Date of Birth'),
                              readOnly: true,
                              onTap: isEditing ? () => selectChildDob(context) : null,
                            ),
                            SizedBox(height: 10),
                            // Gender Dropdown
                            DropdownButtonFormField<String>(
                              value: selectedChildGender,
                              decoration: InputDecoration(
                                labelText: 'Gender',
                                border: OutlineInputBorder(),
                              ),
                              items: ['Boy', 'Girl', 'Prefer not to say']
                                  .map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: isEditing
                                  ? (String? newValue) {
                                setState(() {
                                  selectedChildGender = newValue;
                                });
                              }
                                  : null,
                            ),
                            SizedBox(height: 80), // Space for the logout button
                          ],
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),

          // Logout Button (positioned at bottom)
          Positioned(
            left: 20,
            right: 20,
            bottom: 10,
            child: ElevatedButton(
              onPressed: logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange.shade500,
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Logout',
                style: TextStyle(
                  color: Color(0xFFFFEBFF),
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}