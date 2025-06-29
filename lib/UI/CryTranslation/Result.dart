import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;
import 'package:audio_waveforms/audio_waveforms.dart';

import 'cryUI.dart';
class ResultsScreen extends StatefulWidget {
  final String audioPath;
  final Map<String, double> predictionResults;


  const ResultsScreen({
    super.key,
    required this.audioPath,
    required this.predictionResults,
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  String? _selectedFilter;
  bool _feedbackSubmitted = false;

  @override
  void initState() {
    super.initState();
  }

  // Method to get suggestions for each condition
  List<String> _getSuggestions(String condition) {
    switch (condition) {
      case 'Discomfort':
        return [
          'Check diaper and clothing for tightness or irritation',
          'Try different holding positions to relieve pressure',
          'Gently massage baby\'s back or tummy'
        ];
      case 'Burping':
        return [
          'Hold baby upright against your shoulder',
          'Pat or rub back gently in circular motions',
          'Try walking while holding baby upright'
        ];
      case 'Belly Pain':
        return [
          'Do bicycle leg movements to relieve gas',
          'Apply gentle tummy massage clockwise',
          'Consult with the Doctor'
        ];
      case 'Hungry':
        return [
          'Offer feeding if it\'s been 2-3 hours',
          'Ensure proper latch if breastfeeding'
        ];
      case 'Tired':
        return [
          'Swaddle snugly to mimic womb feeling',
          'Reduce stimulation and dim lights',
          'Try gentle rocking or white noise'
        ];
      default:
        return [
          'The provided voice is not for the baby cry please record again'
        ];
    }
  }

  Widget _getCategoryAvatar(String category, {double size = 40}) {
    String imagePath;
    Color color;

    switch (category) {
      case 'Belly Pain':
        imagePath = "assets/images/belly_pain.png"; // Update with your actual image path
        color = Colors.redAccent;
        break;
      case 'Burping':
        imagePath = "assets/images/burping.png"; // Update with your actual image path
        color = Colors.orangeAccent;
        break;
      case 'Discomfort':
        imagePath = "assets/images/discomfort.png"; // Update with your actual image path
        color = Colors.blue;
        break;
      case 'Hungry':
        imagePath = "assets/images/feed.png"; // Update with your actual image path
        color = Colors.greenAccent;
        break;
      case 'Tired':
        imagePath = "assets/images/tired.png"; // Update with your actual image path
        color = Colors.purpleAccent;
        break;
      default:
        imagePath = "assets/images/default.png"; // Update with your actual image path
        color = Colors.grey;
    }

    return CircleAvatar(
      radius: size,
      backgroundColor: color.withOpacity(0.2),
      backgroundImage: AssetImage(imagePath),
      child: imagePath.isEmpty
          ? Icon(Icons.help_outline, color: color, size: size * 0.6)
          : null, // Show icon if image fails to load
    );
  }

  @override
  Widget build(BuildContext context) {
    // Sort predictions by percentage (highest first)
    final sortedPredictions = widget.predictionResults.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final highestPrediction = sortedPredictions.isNotEmpty
        ? sortedPredictions.first
        : null;

    final topSuggestions = _selectedFilter != null
        ? _getSuggestions(_selectedFilter!)
        : _getSuggestions(highestPrediction?.key ?? 'Others');

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const CryCaptureScreen(),
            ),
          );
        },
        child: const Icon(Icons.mic,color: Colors.white,),
        backgroundColor: Colors.deepOrange.shade600,
      ),
      body: CustomScrollView(
        slivers: [
          // Expanded AppBar with most likely reason
          SliverAppBar(
            expandedHeight: 120,
            leading: IconButton(onPressed: (){Navigator.pop(context);}, icon: Icon(Icons.arrow_back,color: Colors.white,)),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 60, bottom: 16),
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (highestPrediction != null)
                    _getCategoryAvatar(highestPrediction.key, size: 30),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${highestPrediction?.value.toStringAsFixed(0)}% Likely to be',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          highestPrediction?.key ?? '',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              background: Container(
                color: Colors.deepOrange.shade600,
              ),
            ),
            pinned: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_alt,color: Colors.white,),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'Filter Recommendations',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ...sortedPredictions
                              .where((entry) => entry.key != 'Others')
                              .map((entry) {
                            return RadioListTile<String>(
                              title: Text(entry.key),
                              value: entry.key,
                              groupValue: _selectedFilter,
                              onChanged: (value) {
                                setState(() {
                                  _selectedFilter = value;
                                });
                                Navigator.pop(context);
                              },
                              secondary: _getCategoryAvatar(entry.key, size: 24),
                            );
                          }),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _selectedFilter = null;
                              });
                              Navigator.pop(context);
                            },
                            child: const Text('Reset Filter'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),

          // Main content
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Predictions with progress bars
                    const Text(
                      'All predictions',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...sortedPredictions.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  entry.key,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '${entry.value.toStringAsFixed(0)}%',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: entry.value / 100,
                              backgroundColor: Colors.grey[300],
                              color: _getProgressBarColor(entry.key),
                              minHeight: 8,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        ),
                      );
                    }).toList(),

                    // Top 3 Recommendations
                    const SizedBox(height: 8),
                    const Text(
                      'Recommendations',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selectedFilter != null
                          ? 'For $_selectedFilter'
                          : 'For ${highestPrediction?.key ?? 'your baby'}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...topSuggestions.take(3).map((suggestion) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 4, right: 12),
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                suggestion,
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),

                    // Did it work section
                    const SizedBox(height: 0),
                    const Divider(),
                    const SizedBox(height: 0),
                    if (!_feedbackSubmitted) ...[
                      const Text(
                        'Did these suggestions help?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                side: BorderSide(color: Colors.green.shade400),
                              ),
                              onPressed: () {
                                setState(() {
                                  _feedbackSubmitted = true;
                                });
                                // You could add analytics or backend call here
                              },
                              child: Text(
                                'Yes',
                                style: TextStyle(
                                  color: Colors.green.shade700,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                side: BorderSide(color: Colors.red.shade400),
                              ),
                              onPressed: () {
                                setState(() {
                                  _feedbackSubmitted = true;
                                });
                                // You could add analytics or backend call here
                              },
                              child: Text(
                                'No',
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      const SizedBox(height: 12),
                      const Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          SizedBox(width: 8),
                          Text(
                            'Thanks for your feedback!',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'We\'ll use this to improve our suggestions.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Color _getProgressBarColor(String category) {
    switch (category) {
      case 'Belly Pain':
        return Colors.redAccent;
      case 'Burping':
        return Colors.orangeAccent;
      case 'Discomfort':
        return Colors.blue;
      case 'Hungry':
        return Colors.greenAccent;
      case 'Tired':
        return Colors.purpleAccent;
      case 'Others':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }
}