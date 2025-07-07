import 'package:carecub/UI/DayCare/DayCareListing.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'Community/Community.dart';
import 'CryTranslation/cryUI.dart';
import 'Doctor_Booking/Parents_side/Doctorlist.dart';
import 'Milestone/milestones_screen.dart';
import 'Nutrition Guide/SelectDate.dart';
import 'TrakingsScreens/TrackersList.dart';
import 'User/ProfileScreen.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String childName = "Your Child";
  String childAge = "0 weeks";
  String? childImageUrl;
  final ImagePicker _picker = ImagePicker();
  bool isUploading = false;

  @override
  void initState() {
    super.initState();
    fetchChildDetails();
  }

  Future<void> fetchChildDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('babyProfiles')
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        final name = data['name'] ?? "Your Child";
        final dob = data['dateOfBirth']?.toDate();
        final imageUrl = data['photoUrl'];

        if (dob != null) {
          final age = _calculateAge(dob);
          setState(() {
            childName = name;
            childAge = age;
            childImageUrl = imageUrl;
          });
        }
      }
    } catch (e) {
      print("Error fetching child details: $e");
    }
  }

  Future<void> _uploadImage(File file) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      setState(() => isUploading = true);

      // Upload to Cloudinary
      const cloudName = 'dghmibjc3';
      const uploadPreset = 'CareCub';

      final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', image.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.toBytes();
        final responseString = String.fromCharCodes(responseData);
        final jsonMap = jsonDecode(responseString);
        final imageUrl = jsonMap['secure_url'];

        // Update Firestore with new image URL
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final childSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('babyProfiles')
              .orderBy('createdAt', descending: true)
              .limit(1)
              .get();

          if (childSnapshot.docs.isNotEmpty) {
            await childSnapshot.docs.first.reference.update({
              'photoUrl': imageUrl,
              'updatedAt': FieldValue.serverTimestamp(),
            });
            setState(() => childImageUrl = imageUrl);
          }
        }
      } else {
        throw Exception('Failed to upload image to Cloudinary');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image: $e')),
      );
    } finally {
      setState(() => isUploading = false);
    }
  }

  Future<void> _showImageSourceDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Upload Child Photo'),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              ListTile(
                leading: Icon(Icons.camera),
                title: Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.image),
                title: Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        await _uploadImage(File(image.path));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  String _calculateAge(DateTime dob) {
    final now = DateTime.now();
    final difference = now.difference(dob);

    if (difference.inDays >= 365) {
      final years = (difference.inDays / 365).floor();
      return "$years year${years > 1 ? 's' : ''}";
    } else if (difference.inDays >= 30) {
      final months = (difference.inDays / 30).floor();
      return "$months month${months > 1 ? 's' : ''}";
    } else {
      final weeks = (difference.inDays / 7).floor();
      return "$weeks week${weeks > 1 ? 's' : ''}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFADB0), Colors.white60, Color(0xFFFFE3EC)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 30),
              GestureDetector(
                onTap: () => _showImageSourceDialog(),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 120.0,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFFFE3D3), Color(0xFFFFAD9E)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(width: 20),
                      Stack(
                        children: [
                          if (isUploading)
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey[200],
                              ),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          else if (childImageUrl != null)
                            CircleAvatar(
                              radius: 50,
                              backgroundImage: NetworkImage(childImageUrl!),
                            )
                          else
                            Stack(
                              children: [
                                Image.asset(
                                  'assets/images/cute_baby.png',
                                  width: 100,
                                  height: 100,
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
                                    child: Icon(Icons.camera_alt, color: Colors.white, size: 10),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            childName,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            childAge,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => UserProfileScreen()));
                            },
                            icon: Icon(Icons.account_circle, color: Colors.black54),
                            label: Text(
                              "Profile",
                              style: TextStyle(color: Colors.black87),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pink.shade100,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => CryCaptureScreen()));
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFFFE3EC), Colors.purple.shade50],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    color: Colors.purple.shade100,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.shade200,
                        blurRadius: 10,
                        offset: Offset(4, 4),
                      ),
                    ],
                  ),
                  child: Card(
                    elevation: 0,
                    color: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Cry Translator AI',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                'Translate your baby`s cry with AI',
                                style: TextStyle(fontSize: 16),
                              ),
                              Text(
                                '1 week',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: Colors.pink.shade100,
                            ),
                            child: const Text('Optimize your baby\'s needs'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GridView(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  children: [
                    buildCard(
                      'Nutrition Guid',
                      Icons.apple,
                      Color(0xFFFFEBFF),
                      Colors.red.shade600,
                          () {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>AgeSelectionScreen()));
                      },
                    ),
                    buildCard(
                      "Doctor Appointments",
                      Icons.local_hospital_outlined,
                      Color(0xFFFFEBFF),
                      Colors.red.shade600, // Shadow color
                          () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Doctorlist()),
                        );
                      },
                    ),
                    buildCard(
                      "Community",
                      Icons.comment,
                      Color(0xFFFFEBFF),
                      Colors.red.shade600, // Shadow color
                          () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CommunityHomePage()),
                        );
                      },
                    ),
                    buildCard(
                      "DayCare Centers",
                      Icons.maps_home_work_sharp,
                      Color(0xFFFFEBFF),
                      Colors.red.shade600, // Shadow co
                          () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => DayCareList()),
                        );
                      },
                    ),
                    buildCard(
                      "Trackers",
                      Icons.track_changes,
                      Color(0xFFFFEBFF),
                      Colors.red.shade600, // Shadow color
                          () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => TrackersList()),
                        );
                      },
                    ),
                    buildCard(
                      "Milestone Tracking",
                      Icons.show_chart,
                      Color(0xFFFFEBFF),
                      Colors.red.shade600, // Shadow color
                          () {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>MileStonesScreen()));
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Method to Build Each Card
  // Method to Build Each Card
  Widget buildCard(String title, IconData icon, Color cardColor, Color shadowColor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16), // Rounded corners
          boxShadow: [
            BoxShadow(
              color: shadowColor.withOpacity(0.5), // Shadow color with transparency
              blurRadius: 10, // Blur effect for the shadow
              offset: Offset(4, 4), // Shadow position (x, y)
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.deepOrange),
              SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
}
}