import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'Login.dart'; // Import your Login Screen

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to fetch user-specific data
  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserDataStream() {
    final String? uid = _auth.currentUser?.uid;
    if (uid != null) {
      return _firestore.collection('users').doc(uid).snapshots();
    }
    throw Exception('User not logged in');
  }

  // Function to log out the current user
  void logout() async {
    await _auth.signOut();
    // Navigate to the Login Screen after logout
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
        title: const Text('User Profile', style: TextStyle(color: Color(0xFFFFEBFF))),
        backgroundColor: Colors.deepOrange.shade500,
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: getUserDataStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text('Error fetching user data'),
            );
          }
          if (snapshot.hasData && snapshot.data != null) {
            final data = snapshot.data!.data();
            if (data != null) {
              // Extract user profile picture URL or default to initials
              final String? profilePictureUrl = data['profilePicture'];
              final String displayName = data['name'] ?? 'N/A';

              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Circular Avatar
                    CircleAvatar(
                      radius: 70,
                      backgroundImage: profilePictureUrl != null
                          ? NetworkImage(profilePictureUrl)
                          : null,
                      child: profilePictureUrl == null
                          ? Text(
                        displayName.isNotEmpty
                            ? displayName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                          : null,
                      backgroundColor: Colors.grey[300],
                    ),
                    const SizedBox(height: 20),
                    // User Information
                    TextField(
                      controller: TextEditingController(text: data['name']),
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: TextEditingController(text: data['email']),
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: TextEditingController(text: data['phone']),
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Phone',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Logout Button
                    ElevatedButton(
                      onPressed: logout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange.shade500, // Button color
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      ),
                      child: const Text(
                        'Logout',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Color(0xFFFFEBFF)),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return const Center(
                child: Text('No user data found'),
              );
            }
          }
          return const Center(
            child: Text('No data available'),
          );
        },
      ),
    );
  }
}
