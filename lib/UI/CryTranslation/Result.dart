import 'package:flutter/material.dart';

class CryPredictionResultScreen extends StatelessWidget {
  final Map<String, double> predictions = {
    'Tired': 40.0,
    'Hungry': 30.0,
    'Discomfort': 25.0,
    'Belly Pain': 20.0,
    'Burping': 15.0,
  };

  String getSuggestion(Map<String, double> predictions) {
    String highestReason = predictions.keys.first;
    double highestPercentage = predictions.values.first;

    predictions.forEach((key, value) {
      if (value > highestPercentage) {
        highestReason = key;
        highestPercentage = value;
      }
    });

    switch (highestReason) {
      case 'Discomfort':
        return 'Try adjusting the baby’s position or checking for any irritants.';
      case 'Burping':
        return 'Hold the baby upright and gently pat their back to help them burp.';
      case 'Not Now':
        return 'The baby seems content at the moment.';
      case 'Belly Pain':
        return 'Consider massaging the baby’s tummy or consulting a pediatrician.';
      case 'Hungry':
        return 'Try feeding the baby.';
      case 'Tired':
        return 'Put the baby in a calm environment to help them sleep.';
      default:
        return 'No suggestion available.';
    }
  }

  @override
  Widget build(BuildContext context) {
    String suggestion = getSuggestion(predictions);

    return Scaffold(
      backgroundColor: Color(0xFFDFFAFF),
      appBar: AppBar(
        title: Text('Cry Prediction Result'),
        backgroundColor: Color(0xFFDFFAFF),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Prediction Results',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            ...predictions.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 0),
                    LinearProgressIndicator(
                      value: entry.value / 100,
                      backgroundColor: Colors.grey.shade300,
                      color: Colors.teal,
                      minHeight: 8,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${entry.value.toStringAsFixed(1)}%',
                          style: TextStyle(fontSize: 14, color: Colors.teal),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
            SizedBox(height: 0),
            Divider(thickness: 1, color: Colors.grey.shade400),
            SizedBox(height: 0),
            Text(
              'Suggestion',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                suggestion,
                style: TextStyle(fontSize: 16, color: Colors.teal.shade900),
              ),
            ),
            Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Back to record'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF55D3C9),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  textStyle: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
