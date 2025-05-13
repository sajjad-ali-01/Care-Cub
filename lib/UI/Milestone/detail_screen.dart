import 'package:flutter/material.dart';
import 'next_screen.dart';

class DetailScreen extends StatefulWidget {
  final String title;
  final String image;
  final int initialCompleted;
  final int totalMilestones;

  DetailScreen({
    required this.title,
    required this.image,
    required this.initialCompleted,
    required this.totalMilestones,
  });

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late int completedCount;
  Map<String, bool> completedItems = {};

  @override
  void initState() {
    super.initState();
    completedCount = widget.initialCompleted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context, completedCount);
          },
        ),
        title: Text(widget.title,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepOrange.shade600, // Changed to deep orange
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                    widget.image, height: 200, fit: BoxFit.cover),
              ),
              SizedBox(height: 16),
              Text(
                  "$completedCount out of ${widget.totalMilestones} completed",
                  style: TextStyle(fontWeight: FontWeight.bold)
              ),
              SizedBox(height: 16),

              if (widget.title == '2 - 4mo') ...[
                _buildExpandableTile(
                    'Cognitive Milestones', Icons.lightbulb_outline,
                    Colors.green, [
                  'If hungry, opens mouth when sees breast or bottle',
                  'Looks at his hands with interest'
                ]),

                _buildExpandableTile('Language/Communication Milestones',
                    Icons.chat_bubble_outline, Colors.blue, [
                      'Make sounds like "ooo","aahh"',
                      'Makes sounds back when you talk',
                      'Turns head toward the sound of your voice'
                    ]),

                _buildExpandableTile('Movement/Physical Development Milestones',
                    Icons.directions_walk, Colors.purple, [
                      'Uses arms to swing a toy',
                      'Holds head steady without support when you\'re holding',
                      'Holds a toy/object briefly when you put in his hand',
                      'Brings hands to mouth',
                      'Pushes up onto elbows/forearms when on tummy'
                    ]),

                _buildExpandableTile(
                    'Social/Emotional Milestones', Icons.emoji_emotions,
                    Colors.orange, [
                  'Smiles on his own to get your attention',
                  'Chuckles (not yet a full laugh when you try to make her laugh)',
                  'Looks at you, moves, or makes sounds to get or keep your attention'
                ]),
              ] else
                if (widget.title == '4 - 6mo') ...[
                  _buildExpandableTile(
                      'Cognitive Milestones', Icons.lightbulb_outline,
                      Colors.green, [
                    'Puts things in mouth to explore them',
                    'Reaches to grab a toy wants',
                    'Closes lips to show she doesn\'t want more food'
                  ]),

                  _buildExpandableTile('Language/Communication Milestones',
                      Icons.chat_bubble_outline, Colors.blue, [
                        'Takes turns making sound with you',
                        'Blows "raspberries" (stick tongue out and blows)',
                        'Makes squealing noises'
                      ]),

                  _buildExpandableTile(
                      'Movement/Physical Development Milestones',
                      Icons.directions_walk, Colors.purple, [
                    'Rolls from tummy to back',
                    'Pushes up with straight arms when on tummy',
                    'Leans on hands to support himself when sitting'
                  ]),

                  _buildExpandableTile(
                      'Social/Emotional Milestones', Icons.emoji_emotions,
                      Colors.orange, [
                    'Knows familiar people',
                    'Likes to look himself in a mirror',
                    'Laughs'
                  ]),
                ] else
                  if (widget.title == '6 - 9mo') ...[
                    _buildExpandableTile(
                        'Cognitive Milestones', Icons.lightbulb_outline,
                        Colors.green, [
                      'Looks for objects when dropped out of sight',
                      'Bangs two things together'
                    ]),

                    _buildExpandableTile('Language/Communication Milestones',
                        Icons.chat_bubble_outline, Colors.blue, [
                          'Makes different sounds like "mamamama" and "babababa"',
                          'Lifts arms up to be picked up'
                        ]),

                    _buildExpandableTile(
                        'Movement/Physical Development Milestones',
                        Icons.directions_walk, Colors.purple, [
                      'Gets to sitting position by himself',
                      'Moves things from one hand to other hand',
                      'Uses fingers to "rake" food towards himself',
                      'Sits without support'
                    ]),

                    _buildExpandableTile(
                        'Social/Emotional Milestones', Icons.emoji_emotions,
                        Colors.orange, [
                      'Is shy, clingy, or fearful around strangers',
                      'Shows several facial expressions, like happy, sad, angry and surprised',
                      'Looks when you call his/her name',
                      'Reacts when you leave (looks, reaches for you, or cries)',
                      'Smiles or laughs when you play'
                    ]),
                  ] else
                    if (widget.title == '9 - 12mo') ...[
                      _buildExpandableTile(
                          'Cognitive Milestones', Icons.lightbulb_outline,
                          Colors.green, [
                        'Put something in a container, like a block in a cup',
                        'Looks for things you hide, like a toy under a blanket'
                      ]),

                      _buildExpandableTile('Language/Communication Milestones',
                          Icons.chat_bubble_outline, Colors.blue, [
                            'Waves "bye-bye"',
                            'Calls a parent "mama" or "papa" or any other name',
                            'Understands "no" (pauses briefly or stops when you say it)'
                          ]),

                      _buildExpandableTile(
                          'Movement/Physical Development Milestones',
                          Icons.directions_walk, Colors.purple, [
                        'Pulls up to stand',
                        'Walks holding on to the furniture',
                        'Drinks from a cup without a lid, as you hold it',
                        'Picks things up between thumb and pointer finger'
                      ]),

                      _buildExpandableTile(
                          'Social/Emotional Milestones', Icons.emoji_emotions,
                          Colors.orange, [
                        'Plays games with you'
                      ]),
                    ] else
                      ...[
                        _buildExpandableTile(
                            'Cognitive Milestones', Icons.lightbulb_outline,
                            Colors.green, [
                          'Watches you as you move',
                          'Looks at a toy for several seconds'
                        ]),

                        _buildExpandableTile(
                            'Language/Communication Milestones',
                            Icons.chat_bubble_outline, Colors.blue, [
                          'Babbles',
                          'Responds to sounds'
                        ]),

                        _buildExpandableTile(
                            'Movement/Physical Development Milestones',
                            Icons.directions_walk, Colors.purple, [
                          'Moves both arms and both legs',
                          'Holds head up when on tummy',
                          'Makes smoother movements with arms and legs'
                        ]),

                        _buildExpandableTile(
                            'Social/Emotional Milestones', Icons.emoji_emotions,
                            Colors.orange, [
                          'Begins to smile at people',
                          'Can briefly calm themselves',
                          'Tries to look at parent',
                          'Looks at faces'
                        ]),
                      ],

              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandableTile(String title, IconData icon, Color color,
      List<String> items) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: CircleAvatar(
            backgroundColor: color,
            child: Icon(icon, color: Colors.white),
          ),
          title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          children: items.map((item) =>
              ListTile(
                title: Text(item),
                trailing: IconButton(
                  icon: Icon(
                    completedItems[item] == true ? Icons.check_circle : Icons
                        .check_circle_outline,
                    color: completedItems[item] == true ? color : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      if (completedItems[item] == true) {
                        completedItems[item] = false;
                        completedCount--;
                      } else {
                        completedItems[item] = true;
                        completedCount++;
                      }
                    });
                  },
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          NextScreen(
                            title: item,
                            image: widget.image,
                            ageGroup: widget.title,
                            category: title,
                            isCompleted: completedItems[item] ?? false,
                            onCompletionChanged: (isCompleted) {
                              setState(() {
                                if (isCompleted &&
                                    !(completedItems[item] ?? false)) {
                                  completedCount++;
                                } else if (!isCompleted &&
                                    (completedItems[item] ?? false)) {
                                  completedCount--;
                                }
                                completedItems[item] = isCompleted;
                              });
                            },
                          ),
                    ),
                  );
                },
              )).toList(),
        ),
      ),
    );
  }
}