import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'AnswerScreen.dart';

class QuoraFeedScreen extends StatelessWidget {
  const QuoraFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepOrange.shade600,
          title: const Text(
            'Questions For you',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.white,
            ),
          ),
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
        ),
        body: const TabBarView(
          children: [
            QuoraFeedTab(),
            // Add other tabs if needed
            Center(child: Text('Second Tab')),
            Center(child: Text('Third Tab')),
          ],
        ),
      ),
    );
  }
}

class QuoraFeedTab extends StatefulWidget {
  const QuoraFeedTab({super.key});

  @override
  State<QuoraFeedTab> createState() => _QuoraFeedTabState();
}

class _QuoraFeedTabState extends State<QuoraFeedTab> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;
  List<DocumentSnapshot> _questions = [];

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final querySnapshot = await _firestore
          .collection('questions')
          .orderBy('timestamp', descending: true)
          .get();

      setState(() {
        _questions = querySnapshot.docs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading questions: $e')),
      );
    }
  }

  void _navigateToAnswersScreen(BuildContext context, {required String question, required String questionId}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnswersScreen(
          question: question,
          questionId: questionId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _questions.isEmpty
        ? const Center(child: Text('No questions found'))
        : ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _questions.length,
      itemBuilder: (context, index) {
        final question = _questions[index];
        final data = question.data() as Map<String, dynamic>;
        final timestamp = data['timestamp'] as Timestamp?;
        final timeAgo = timestamp != null
            ? DateFormat('MMM d, y').format(timestamp.toDate())
            : 'Some time ago';

        return Card(
          elevation: 6,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Colors.white,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _navigateToAnswersScreen(
                context,
                question: data['text'] ?? '',
                questionId: question.id),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundImage: data['authorPhotoUrl'] != null
                            ? NetworkImage(data['authorPhotoUrl'])
                            : null,
                        child: data['authorPhotoUrl'] == null
                            ? Text(data['authorName']?.toString().substring(0, 1) ?? '?')
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: data['authorName']?.replaceAll('✔️', '') ?? 'Anonymous',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  if (data['authorName']?.contains('✔️') ?? false)
                                    const TextSpan(
                                      text: ' ✔️',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Text(
                              timeAgo,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_horiz, size: 20),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "${data['text'] ?? ''}?",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _navigateToAnswersScreen(
                              context,
                              question: data['text'] ?? '',
                              questionId: question.id),
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('Answer', style: TextStyle(fontSize: 13)),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.orangeAccent[700],
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(color: Colors.black),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _navigateToAnswersScreen(
                              context,
                              question: data['text'] ?? '',
                              questionId: question.id),
                          icon: const Icon(Icons.message, size: 16),
                          label: Text(
                            "${data['answers'] ?? 0} answers",
                            style: TextStyle(color: Colors.red[800], fontSize: 13),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.red[800],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(color: Colors.black),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}