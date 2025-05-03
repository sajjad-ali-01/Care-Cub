import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'NutritionResults.dart';

class DeficiencyAssessmentScreen extends StatefulWidget {
  final String ageGroup;

  const DeficiencyAssessmentScreen({super.key, required this.ageGroup});

  @override
  State<DeficiencyAssessmentScreen> createState() =>
      _DeficiencyAssessmentScreenState();
}

class _DeficiencyAssessmentScreenState extends State<DeficiencyAssessmentScreen> {
  List<QueryDocumentSnapshot> deficiencies = [];
  Map<String, String?> answers = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDeficiencies();
  }

  Future<void> fetchDeficiencies() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('deficiencies')
          .get();

      // Shuffle the documents for random order
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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange.shade600,
        title: Text('Assessment (${widget.ageGroup})',style: TextStyle(color: Colors.white),),
        leading: IconButton(onPressed: (){Navigator.pop(context);}, icon: Icon(Icons.arrow_back,color: Colors.white,)),
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
                  : () {
                showResults();
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

  void showResults() {
    // Filter deficiencies with "Yes" answers
    final positiveResults = deficiencies.where((deficiency) {
      return answers[deficiency.id] == 'Yes';
    }).toList();

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
