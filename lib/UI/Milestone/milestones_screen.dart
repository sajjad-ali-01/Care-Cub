import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:confetti/confetti.dart';
import 'detail_screen.dart';

class MileStonesScreen extends StatefulWidget {
  @override
  _MileStonesScreenState createState() => _MileStonesScreenState();
}

class _MileStonesScreenState extends State<MileStonesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late ConfettiController _confettiController;

  List<Map<String, dynamic>> milestones = [
    {
      'image': 'assets/images/baby1.jpg',
      'title': '0 - 2mo',
      'total': 11,
      'completed': 0,
      'docId': '0_2mo',
      'items': [
        'Watches you as you move',
        'Looks at a toy for several seconds',
        'Babbles',
        'Responds to sounds',
        'Moves both arms and both legs',
        'Holds head up when on tummy',
        'Makes smoother movements with arms and legs',
        'Begins to smile at people',
        'Can briefly calm themselves',
        'Tries to look at parent',
        'Looks at faces'
      ],
      'completedItems': {}
    },
    {
      'image': 'assets/images/baby2.jpg',
      'title': '2 - 4mo',
      'total': 13,
      'completed': 0,
      'docId': '2_4mo',
      'items': [
        'If hungry, opens mouth when sees breast or bottle',
        'Looks at his hands with interest',
        'Make sounds like "ooo","aahh"',
        'Makes sounds back when you talk',
        'Turns head toward the sound of your voice',
        'Uses arms to swing a toy',
        'Holds head steady without support when you\'re holding',
        'Holds a toy/object briefly when you put in his hand',
        'Brings hands to mouth',
        'Pushes up onto elbows/forearms when on tummy',
        'Smiles on his own to get your attention',
        'Chuckles (not yet a full laugh when you try to make her laugh)',
        'Looks at you, moves, or makes sounds to get or keep your attention'
      ],
      'completedItems': {}
    },
    {
      'image': 'assets/images/baby3.jpg',
      'title': '4 - 6mo',
      'total': 12,
      'completed': 0,
      'docId': '4_6mo',
      'items': [
        'Puts things in mouth to explore them',
        'Reaches to grab a toy wants',
        'Closes lips to show she doesn\'t want more food',
        'Takes turns making sound with you',
        'Blows "raspberries" (stick tongue out and blows)',
        'Makes squealing noises',
        'Rolls from tummy to back',
        'Pushes up with straight arms when on tummy',
        'Leans on hands to support himself when sitting',
        'Knows familiar people',
        'Likes to look himself in a mirror',
        'Laughs'
      ],
      'completedItems': {}
    },
    {
      'image': 'assets/images/baby4.jpg',
      'title': '6 - 9mo',
      'total': 13,
      'completed': 0,
      'docId': '6_9mo',
      'items': [
        'Looks for objects when dropped out of sight',
        'Bangs two things together',
        'Makes different sounds like "mamamama" and "babababa"',
        'Lifts arms up to be picked up',
        'Gets to sitting position by himself',
        'Moves things from one hand to other hand',
        'Uses fingers to "rake" food towards himself',
        'Sits without support',
        'Is shy, clingy, or fearful around strangers',
        'Shows several facial expressions, like happy, sad, angry and surprised',
        'Looks when you call his/her name',
        'Reacts when you leave (looks, reaches for you, or cries)',
        'Smiles or laughs when you play'
      ],
      'completedItems': {}
    },
    {
      'image': 'assets/images/baby5.jpg',
      'title': '9 - 12mo',
      'total': 10,
      'completed': 0,
      'docId': '9_12mo',
      'items': [
        'Put something in a container, like a block in a cup',
        'Looks for things you hide, like a toy under a blanket',
        'Waves "bye-bye"',
        'Calls a parent "mama" or "papa" or any other name',
        'Understands "no" (pauses briefly or stops when you say it)',
        'Pulls up to stand',
        'Walks holding on to the furniture',
        'Drinks from a cup without a lid, as you hold it',
        'Picks things up between thumb and pointer finger',
        'Plays games with you'
      ],
      'completedItems': {}
    },
  ];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _loadMilestoneData();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _loadMilestoneData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    for (var milestone in milestones) {
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('milestones')
          .doc(milestone['docId'])
          .get();

      if (doc.exists) {
        setState(() {
          milestone['completed'] = doc['completed'] ?? 0;
          milestone['completedItems'] = Map<String, bool>.from(doc['completedItems'] ?? {});
        });
      } else {
        // Initialize completedItems map
        Map<String, bool> initialItems = {};
        for (var item in milestone['items']) {
          initialItems[item] = false;
        }
        setState(() {
          milestone['completedItems'] = initialItems;
        });
      }
    }
  }

  Future<void> _updateMilestoneData(String docId, int completedCount, Map<String, bool> completedItems) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('milestones')
        .doc(docId)
        .set({
      'completed': completedCount,
      'completedItems': completedItems,
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    final index = milestones.indexWhere((m) => m['docId'] == docId);
    if (index != -1) {
      setState(() {
        milestones[index]['completed'] = completedCount;
        milestones[index]['completedItems'] = completedItems;
      });
    }
  }

  void _showConfetti() {
    _confettiController.play();
    Future.delayed(Duration(seconds: 3), () {
      _confettiController.stop();
    });
  }

  Color getProgressColor(int index) {
    switch(index) {
      case 0: return Colors.yellow;
      case 1: return Colors.deepOrange;
      case 2: return Colors.lightGreen;
      case 3: return Colors.purple;
      case 4: return Colors.lightBlue;
      default: return Colors.deepOrange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'All Milestones',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepOrange.shade600,
        elevation: 0,
      ),
      backgroundColor: Colors.grey.shade100,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "From their first smile to their first word, your baby's milestones are important markers of their magical growth journey.",
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: milestones.length,
                    itemBuilder: (context, index) {
                      final milestone = milestones[index];
                      return GestureDetector(
                        onTap: () async {
                          final updatedCount = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailScreen(
                                title: milestone['title'],
                                image: milestone['image'],
                                initialCompleted: milestone['completed'],
                                totalMilestones: milestone['total'],
                                docId: milestone['docId'],
                                items: milestone['items'],
                                completedItems: Map<String, bool>.from(milestone['completedItems']),
                                onUpdate: _updateMilestoneData,
                                onCelebrate: _showConfetti,
                              ),
                            ),
                          );

                          if (updatedCount != null) {
                            setState(() {
                              milestones[index]['completed'] = updatedCount;
                            });

                            if (updatedCount == milestone['total']) {
                              _showConfetti();
                            }
                          }
                        },
                        child: Card(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          color: Colors.white,
                          elevation: 2,
                          child: ListTile(
                            leading: Image.asset(
                              milestone['image'],
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                            title: Text(
                              milestone['title'],
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 5),
                                LinearProgressIndicator(
                                  value: milestone['completed'] / milestone['total'],
                                  backgroundColor: Colors.grey.shade300,
                                  color: getProgressColor(index),
                                ),
                                SizedBox(height: 5),
                                Text(
                                    '${milestone['completed']} / ${milestone['total']}',
                                    style: TextStyle(color: Colors.black)
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple
              ],
            ),
          ),
        ],
      ),
    );
  }
}