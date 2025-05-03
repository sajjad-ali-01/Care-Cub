import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'NutritionsHome.dart';


class AgeSelectionScreen extends StatefulWidget {
  const AgeSelectionScreen({super.key});

  @override
  State<AgeSelectionScreen> createState() => _AgeSelectionScreenState();
}

class _AgeSelectionScreenState extends State<AgeSelectionScreen> {
  String? selectedAge;

  final ageGroups = [
    '0-6 months',
    '7-12 months',
    '1-3 years',
    '4-8 years',
    '9-10 years',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange.shade600,
          title: const Text('Select Age Group',style: TextStyle(color: Colors.white),
          ),
        leading: IconButton(onPressed: (){Navigator.pop(context);}, icon: Icon(Icons.arrow_back,color: Colors.white,)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Select your child\'s age group:',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedAge,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelText: 'Age Group',
                ),
                items: ageGroups.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedAge = value;
                  });
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: selectedAge == null
                    ? null
                    : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DeficiencyAssessmentScreen(
                        ageGroup: selectedAge!,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedAge == null ? Colors.grey : Colors.deepOrange,
                ),
                child: Text(
                  'Continue',
                  style: TextStyle(
                    color: selectedAge == null ? Colors.black : Colors.white,
                  ),
                ),
              )


            ],
          ),
        ),
      ),
    );
  }
}
