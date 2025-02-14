import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Login.dart';

class GoogleAuthClient extends http.BaseClient {
  final String _accessToken;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._accessToken);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    request.headers['Authorization'] = 'Bearer $_accessToken';
    return _client.send(request);
  }
}

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['https://www.googleapis.com/auth/drive.file'],
  );

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  File? _pickedImage;
  bool _isEditing = false;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserDataStream() {
    final String? uid = _auth.currentUser?.uid;
    if (uid != null) {
      return _firestore.collection('users').doc(uid).snapshots();
    }
    throw Exception('User not logged in');
  }


  Future<void> _updateProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;

    setState(() => _isUpdating = true);

    try {

      await _firestore.collection('users').doc(user.uid).update({
        'name': _nameController.text,
        'phone': _phoneController.text,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        _isEditing = false;
        _pickedImage = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update failed: ${e.toString()}'))
      );
    } finally {
      setState(() => _isUpdating = false);
    }
  }

  void ConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Update'),
        content: Text('Are you sure you want to update your profile?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _updateProfile();
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  void logout() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Login()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFEBFF),
      appBar: AppBar(
        title: Text('User Profile', style: TextStyle(color: Color(0xFFFFEBFF))),
        backgroundColor: Colors.deepOrange.shade500,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                ConfirmationDialog();
              } else {
                setState(() => _isEditing = true);
              }
            },
          )
        ],
      ),
      body: _isUpdating
          ? Center(child: CircularProgressIndicator())
          : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: getUserDataStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final data = snapshot.data!.data() ?? {};
          if (!_isEditing) {
            _nameController.text = data['name'] ?? '';
            _phoneController.text = data['phone'] ?? '';
          }

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: ListView(
              children: [
                GestureDetector(
                  child: Center(
                    child: CircleAvatar(
                      radius: 70,
                      backgroundImage: _pickedImage != null
                          ? FileImage(_pickedImage!)
                          : (data['photoUrl'] != null && data['photoUrl'] is String
                          ? NetworkImage(data['photoUrl'])
                          : null),
                      child: _pickedImage == null && data['photoUrl'] == null
                          ? Text(
                        data['name']?.isNotEmpty == true
                            ? data['name'][0].toUpperCase()
                            : '?',
                        style: TextStyle(fontSize: 40),
                      )

                          : null,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                  enabled: _isEditing,
                ),
                SizedBox(height: 10),
                TextField(
                  controller: TextEditingController(text: data['email'] ?? ''),
                  decoration: InputDecoration(labelText: 'Email'),
                  readOnly: true,
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(labelText: 'Phone'),
                  enabled: _isEditing,
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: logout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange.shade500,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                  child: Text('Logout', style: TextStyle(color: Color(0xFFFFEBFF))),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}