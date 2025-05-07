import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ResultsScreen extends StatelessWidget {
  final String ageGroup;
  final List<QueryDocumentSnapshot> results;

  const ResultsScreen({
    super.key,
    required this.ageGroup,
    required this.results,
  });

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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Assessment Results',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.deepOrange.shade600,
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: results.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
            itemCount: results.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final deficiency = results[index];
              return _buildDeficiencyCard(deficiency, ageGroup);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 48,
            color: Colors.green,
          ),
          const SizedBox(height: 16),
          const Text(
            'No deficiencies identified',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your assessment showed no nutrition deficiencies',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDeficiencyCard(QueryDocumentSnapshot deficiency, String ageGroup) {
    final mealSuggestions = deficiency['mealSuggestions'] as Map<String, dynamic>? ?? {};
    final recommendedIntake = deficiency['recommendedIntake'] as Map<String, dynamic>? ?? {};
    final recommendedFoods = deficiency['recommendedFoods'] as List<dynamic>? ?? [];
    final deficiencyName = deficiency['deficiency']?.toString() ?? 'Nutrition Deficiency';
    final question = deficiency['question']?.toString() ?? '';
    final educationalTip = deficiency['educationalTip']?.toString() ?? '';

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
                      deficiencyName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

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
              const SizedBox(height: 16),

              // Educational tip
              if (educationalTip.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'About this deficiency:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      educationalTip,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 16),
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
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        recommendedIntake[ageGroup],
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 16),
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
                        fontSize: 16,
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
                    const SizedBox(height: 16),
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
                        fontSize: 16,
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
        ),
      ),
    );
  }
}