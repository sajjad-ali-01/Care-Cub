import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ResultsScreen extends StatelessWidget {
  final String ageGroup;
  final List<QueryDocumentSnapshot> results;

  const ResultsScreen({
    super.key,
    required this.ageGroup,
    required this.results,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assessment Results')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: results.isEmpty
            ? const Center(
          child: Text(
            'No potential deficiencies identified based on your answers.',
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        )
            : ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final deficiency = results[index];
            return ResultCard(
              ageGroup: ageGroup,
              deficiency: deficiency,
            );
          },
        ),
      ),
    );
  }
}

class ResultCard extends StatelessWidget {
  final String ageGroup;
  final QueryDocumentSnapshot deficiency;

  const ResultCard({
    super.key,
    required this.ageGroup,
    required this.deficiency,
  });

  @override
  Widget build(BuildContext context) {
    final mealSuggestions = deficiency['mealSuggestions'] as Map<String, dynamic>;
    final recommendedIntake =
    deficiency['recommendedIntake'] as Map<String, dynamic>;
    final recommendedFoods = deficiency['recommendedFoods'] as List<dynamic>;

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add the question here
            Text(
              "Question: ${deficiency['question']}",
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 10),
            Divider(),
            const SizedBox(height: 10),
            Text(
              deficiency['deficiency'],
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              deficiency['educationalTip'],
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            buildInfoRow('Recommended Intake:',
                recommendedIntake[ageGroup] ?? 'Not specified for this age'),
            const SizedBox(height: 15),
            buildInfoRow('Meal Suggestions:',
                mealSuggestions[ageGroup] ?? 'No specific suggestion for this age'),
            const SizedBox(height: 15),
            const Text(
              'Recommended Foods:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: recommendedFoods
                  .map((food) => Chip(
                label: Text(food),
                backgroundColor: Colors.blue[50],
              ))
                  .toList(),
            ),
            const SizedBox(height: 20),
            if (deficiency['referenceLink'] != null)
              InkWell(
                onTap: () {
                  // Handle link opening
                },
                child: Text(
                  'Learn more: ${deficiency['referenceLink']}',
                  style: const TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
