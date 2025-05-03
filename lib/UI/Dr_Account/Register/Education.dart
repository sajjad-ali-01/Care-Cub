import 'package:carecub/Database/DatabaseServices.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'Clinic.dart';

class EducationScreen extends StatefulWidget {
  @override
  _EducationScreenState createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  final formKey = GlobalKey<FormState>();
  final User? user = FirebaseAuth.instance.currentUser;

  final TextEditingController PMCNumberController = TextEditingController();

  List<String> degrees = [
    "MBBS", "MD", "MS", "PhD", "BDS", "DCH", "DNB", "MRCPCH", "FAAP", "DM",
    "MSc", "MPH", "DPed", "FCPS", "MCh", "DO", "PG Diploma", "BSc Nursing", "MPhil", "FRCPCH",
  ];

  Map<String, Map<String, String>> degreeDetails = {};
  Map<String, bool> isDegreeSelected = {};

  @override
  void initState() {
    super.initState();
    for (var degree in degrees) {
      degreeDetails[degree] = {
        'country': '',
        'city': '',
        'college': '',
        'year': '',
      };
      isDegreeSelected[degree] = false;
    }
  }

  void saveEducation() {
    if (formKey.currentState!.validate()) {
      List<String> selectedDegreeList = [];
      for (var degree in degrees) {
        if (isDegreeSelected[degree] ?? false) {
          selectedDegreeList.add(
            "$degree (${degreeDetails[degree]!['year']}) - ${degreeDetails[degree]!['college']}, ${degreeDetails[degree]!['city']}, ${degreeDetails[degree]!['country']}",
          );
        }
      }

      DatabaseService.AddDrEDU_INFO(
        uid: user!.uid,
        EDU_INFO: selectedDegreeList,
        PMCNumber: PMCNumberController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Education Details Saved Successfully!")),
      );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AddClinicScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFEBFF),
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: Text("Education Details"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Education Details", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),

              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: degrees.length,
                itemBuilder: (context, index) {
                  String degree = degrees[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CheckboxListTile(
                        title: Text(degree, style: TextStyle(fontSize: 18)),
                        value: isDegreeSelected[degree] ?? false,
                        onChanged: (bool? value) {
                          setState(() {
                            isDegreeSelected[degree] = value ?? false;
                          });
                        },
                      ),

                      if (isDegreeSelected[degree] ?? false)
                        Column(
                          children: [
                            TextFormField(
                              decoration: InputDecoration(labelText: "Country for $degree", border: OutlineInputBorder()),
                              onChanged: (value) {
                                setState(() {
                                  degreeDetails[degree]!['country'] = value;
                                });
                              },
                              validator: (value) => value!.isEmpty ? "Enter country for $degree" : null,
                            ),
                            SizedBox(height: 10),

                            TextFormField(
                              decoration: InputDecoration(labelText: "City for $degree", border: OutlineInputBorder()),
                              onChanged: (value) {
                                setState(() {
                                  degreeDetails[degree]!['city'] = value;
                                });
                              },
                              validator: (value) => value!.isEmpty ? "Enter city for $degree" : null,
                            ),
                            SizedBox(height: 10),

                            TextFormField(
                              decoration: InputDecoration(labelText: "College/University for $degree", border: OutlineInputBorder()),
                              onChanged: (value) {
                                setState(() {
                                  degreeDetails[degree]!['college'] = value;
                                });
                              },
                              validator: (value) => value!.isEmpty ? "Enter college/university for $degree" : null,
                            ),
                            SizedBox(height: 10),

                            TextFormField(
                              decoration: InputDecoration(labelText: "Completion Year for $degree", border: OutlineInputBorder()),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                setState(() {
                                  degreeDetails[degree]!['year'] = value;
                                });
                              },
                              validator: (value) => value!.isEmpty ? "Enter completion year for $degree" : null,
                            ),
                            SizedBox(height: 20),
                          ],
                        ),
                    ],
                  );
                },
              ),
              SizedBox(height: 20),

              TextFormField(
                controller: PMCNumberController,
                decoration: InputDecoration(labelText: "PMC Registration Number", border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? "Enter your PMC Registration Number" : null,
              ),

              SizedBox(height: 30),

              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                  onPressed: saveEducation,
                  child: Text("Next", style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}