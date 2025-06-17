import 'package:firebase_auth/firebase_auth.dart'; // Add this import
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'NutritionResults.dart';

class DeficiencyAssessmentScreen extends StatefulWidget {
  final String ageGroup;

  const DeficiencyAssessmentScreen({
    super.key,
    required this.ageGroup,
  });

  @override
  State<DeficiencyAssessmentScreen> createState() =>
      _DeficiencyAssessmentScreenState();
}

class _DeficiencyAssessmentScreenState extends State<DeficiencyAssessmentScreen> {
  List<QueryDocumentSnapshot> deficiencies = [];
  Map<String, String?> answers = {};
  bool isLoading = true;
  String? userId; // Store user ID here

  @override
  void initState() {
    super.initState();
    _getCurrentUserId(); // Get user ID when widget initializes
    fetchDeficiencies();
  }

  Future<void> _getCurrentUserId() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        setState(() {
          userId = user.uid;
        });
      } else {
        // Handle case where user is not logged in
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You need to be logged in')),
          );
          Navigator.pop(context); // Go back if user is not logged in
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting user: $e')),
        );
      }
    }
  }

  Future<void> fetchDeficiencies() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('deficiencies')
          .get();

      final shuffledDocs = querySnapshot.docs..shuffle();

      setState(() {
        deficiencies = shuffledDocs;
        isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> saveAssessmentResults(List<QueryDocumentSnapshot> positiveResults) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not authenticated. Please sign in.')),
        );
        return;
      }

      final now = DateTime.now();
      final formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(now);

      // Save complete deficiency data for each positive result
      final resultsData = positiveResults.map((doc) {
        return {
          'deficiency': doc['deficiency'],
          'question': doc['question'],
          'educationalTip': doc['educationalTip'],
          'recommendedIntake': doc['recommendedIntake'],
          'mealSuggestions': doc['mealSuggestions'],
          'recommendedFoods': doc['recommendedFoods'],
          'referenceLink': doc['referenceLink'],
          // Include any other fields you want to display in history
        };
      }).toList();

      final assessmentData = {
        'ageGroup': widget.ageGroup,
        'date': formattedDate,
        'timestamp': FieldValue.serverTimestamp(),
        'results': resultsData,
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('nutritionAssessments')
          .add(assessmentData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Assessment saved successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save assessment: ${e.toString()}')),
      );
      print('Error saving assessment: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || userId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange.shade600,
        title: Text('Assessment (${widget.ageGroup})', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: deficiencies.length,
                itemBuilder: (context, index) {
                  final deficiency = deficiencies[index];
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            deficiency['question'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          DropdownButtonFormField<String>(
                            value: answers[deficiency.id],
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              labelText: 'Select answer',
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'Yes',
                                child: Text('Yes'),
                              ),
                              DropdownMenuItem(
                                value: 'No',
                                child: Text('No'),
                              ),
                              DropdownMenuItem(
                                value : 'None',
                                child:  Text('None'),
                              )
                            ],
                            onChanged: (value) {
                              setState(() {
                                answers[deficiency.id] = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: answers.length != deficiencies.length
                  ? null
                  : () async {
                final positiveResults = deficiencies.where((deficiency) {
                  return answers[deficiency.id] == 'Yes';
                }).toList();

                await saveAssessmentResults(positiveResults);
                showResults(positiveResults);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: answers.length != deficiencies.length
                    ? Colors.grey
                    : Colors.deepOrange,
              ),
              child: Text(
                'Get Recommendations',
                style: TextStyle(
                  color: answers.length != deficiencies.length
                      ? Colors.black
                      : Colors.white,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void showResults(List<QueryDocumentSnapshot> positiveResults) {

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultsScreen(
          ageGroup: widget.ageGroup,
          results: positiveResults,
        ),
      ),
    );
  }
}