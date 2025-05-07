import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NutritionHistoryScreen extends StatelessWidget {
  const NutritionHistoryScreen({super.key});

  // Helper method to parse meal suggestions into list
  List<String> _parseMealSuggestions(dynamic suggestions) {
    if (suggestions == null) return [];

    if (suggestions is List) {
      return suggestions.map((item) => item.toString()).toList();
    }

    return suggestions.toString().split(RegExp(r'[,;•\-–]'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('History'),
          backgroundColor: Colors.deepOrange.shade600,
        ),
        body: const Center(
          child: Text(
            'Please sign in to view your history',
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Assessment History',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepOrange.shade600,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepOrange.shade50,
              Colors.white,
            ],
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('nutritionAssessments')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error loading data\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.deepOrange),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history,
                      size: 48,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No assessment history found',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: snapshot.data!.docs.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final doc = snapshot.data!.docs[index];
                final data = doc.data() as Map<String, dynamic>;
                final results = List<Map<String, dynamic>>.from(data['results'] ?? []);
                final date = data['date'] ?? 'Unknown date';
                final ageGroup = data['ageGroup'] ?? 'Unknown age group';

                return _buildAssessmentCard(
                  context,
                  date: date,
                  ageGroup: ageGroup,
                  results: results,
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildAssessmentCard(
      BuildContext context, {
        required String date,
        required String ageGroup,
        required List<Map<String, dynamic>> results,
      }) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    date,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.deepOrange.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      ageGroup,
                      style: const TextStyle(
                        color: Colors.deepOrange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, thickness: 1),
              const SizedBox(height: 12),

              if (results.isEmpty)
                _buildEmptyState(),

              ...results.map((result) => _buildDeficiencyCard(result, ageGroup)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        const Icon(
          Icons.check_circle_outline,
          size: 48,
          color: Colors.green,
        ),
        const SizedBox(height: 8),
        const Text(
          'No deficiencies identified',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Your nutrition assessment showed no deficiencies',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDeficiencyCard(Map<String, dynamic> result, String ageGroup) {
    final recommendedIntake = result['recommendedIntake'] as Map<String, dynamic>? ?? {};
    final mealSuggestions = result['mealSuggestions'] as Map<String, dynamic>? ?? {};
    final recommendedFoods = result['recommendedFoods'] as List<dynamic>? ?? [];
    final deficiency = result['deficiency']?.toString() ?? 'Nutrition Deficiency';
    final question = result['question']?.toString() ?? '';
    final educationalTip = result['educationalTip']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Deficiency header
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.deepOrange,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  deficiency,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Original question
          if (question.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text(
                '"$question"',
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[600],
                ),
              ),
            ),
          const SizedBox(height: 12),

          // Educational tip
          if (educationalTip.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'About this deficiency:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  educationalTip,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 12),
              ],
            ),

          // Recommended intake
          if (recommendedIntake[ageGroup] != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recommended Daily Intake:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    recommendedIntake[ageGroup],
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),

          // Meal suggestions
          if (mealSuggestions[ageGroup] != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Meal Suggestions:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _parseMealSuggestions(mealSuggestions[ageGroup])
                      .map((suggestion) => Chip(
                    label: Text(suggestion),
                    backgroundColor: Colors.deepOrange.withOpacity(0.1),
                    labelStyle: const TextStyle(color: Colors.deepOrange),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ))
                      .toList(),
                ),
                const SizedBox(height: 12),
              ],
            ),

          // Recommended foods
          if (recommendedFoods.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recommended Foods:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: recommendedFoods
                      .map((food) => Chip(
                    label: Text(food.toString()),
                    backgroundColor: Colors.deepOrange.withOpacity(0.1),
                    labelStyle: const TextStyle(color: Colors.deepOrange),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ))
                      .toList(),
                ),
              ],
            ),
        ],
      ),
    );
  }
}