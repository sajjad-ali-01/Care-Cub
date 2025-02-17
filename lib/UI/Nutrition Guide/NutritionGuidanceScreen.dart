import 'package:flutter/material.dart';

class NutritionGuidanceScreen extends StatefulWidget {
  @override
  _NutritionGuidanceScreenState createState() =>
      _NutritionGuidanceScreenState();
}

class _NutritionGuidanceScreenState extends State<NutritionGuidanceScreen> {
  final _formKey = GlobalKey<FormState>();
  String activityLevel = 'Low';
  String dietType = 'Vegetarian';
  String snackFrequency = 'Once a day';

  String vitaminDeficiency = '';
  String mealSuggestion = '';

  void predictNutrition() {
    setState(() {
      if (activityLevel == 'Low' && snackFrequency == 'Rarely') {
        vitaminDeficiency = 'Vitamin D Deficiency';
        mealSuggestion =
        'Include foods rich in Vitamin D such as fortified cereals, eggs, and salmon.';
      } else {
        vitaminDeficiency = 'No significant deficiency detected.';
        mealSuggestion =
        'Maintain a balanced diet with fruits, vegetables, and proteins.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFDFFAFF),
      appBar: AppBar(
        title: Text('Nutrition Guidance AI'),
        backgroundColor: Colors.deepOrange.shade100,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                'Answer the following questions:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Text('1. What is the child\'s activity level?'),
              DropdownButtonFormField<String>(
                value: activityLevel,
                items: ['Low', 'Moderate', 'High']
                    .map((level) => DropdownMenuItem(
                  value: level,
                  child: Text(level),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    activityLevel = value!;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                ),
              ),
              SizedBox(height: 20),
              Text('2. What type of diet does the child follow?'),
              DropdownButtonFormField<String>(
                value: dietType,
                items: ['Vegetarian', 'Non-Vegetarian', 'Vegan']
                    .map((diet) => DropdownMenuItem(
                  value: diet,
                  child: Text(diet),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    dietType = value!;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                ),
              ),
              SizedBox(height: 20),
              Text('3. How often does the child have snacks?'),
              DropdownButtonFormField<String>(
                value: snackFrequency,
                items: ['Rarely', 'Once a day', 'Multiple times a day']
                    .map((freq) => DropdownMenuItem(
                  value: freq,
                  child: Text(freq),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    snackFrequency = value!;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                ),
              ),
              SizedBox(height: 30),
              // Submit Button
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    predictNutrition();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  textStyle: TextStyle(fontSize: 16),
                ),
                child: Text('Predict Nutrition',style: TextStyle(color: Colors.white)),
              ),
              SizedBox(height: 30),
              // Results Section
              if (vitaminDeficiency.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Predicted Vitamin Deficiency:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      vitaminDeficiency,
                      style: TextStyle(fontSize: 16, color: Colors.red),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Suggested Meal:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      mealSuggestion,
                      style: TextStyle(fontSize: 16),
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
