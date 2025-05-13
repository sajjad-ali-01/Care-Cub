import 'package:flutter/material.dart';

class NextScreen extends StatefulWidget {
  final String title;
  final String image;
  final String ageGroup;
  final String category;
  final bool isCompleted;
  final Function(bool) onCompletionChanged;

  NextScreen({
    required this.title,
    required this.image,
    required this.ageGroup,
    required this.category,
    required this.isCompleted,
    required this.onCompletionChanged,
  });

  @override
  _NextScreenState createState() => _NextScreenState();
}

class _NextScreenState extends State<NextScreen> {
  late bool isCompleted;

  @override
  void initState() {
    super.initState();
    isCompleted = widget.isCompleted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey[700]),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.ageGroup, style: TextStyle(color: Colors.purple[800], fontWeight: FontWeight.bold)),
        backgroundColor: Colors.grey[200],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: AssetImage(widget.image),
                  ),
                  SizedBox(width: 10),
                  Text(widget.ageGroup, style: TextStyle(color: Colors.purple[800], fontWeight: FontWeight.bold))
                ],
              ),
              SizedBox(height: 16),
              Text(
                '${widget.category} (${_getCategoryDescription(widget.category)})',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              SizedBox(height: 8),
              Text(widget.title, style: TextStyle(fontSize: 16)),
              SizedBox(height: 16),
              ListTile(
                tileColor: Colors.grey[200],
                title: Text('Has your child done this'),
                trailing: IconButton(
                  icon: Icon(
                    isCompleted ? Icons.check_circle : Icons.check_circle_outline,
                    color: isCompleted ? Colors.purple : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      isCompleted = !isCompleted;
                      widget.onCompletionChanged(isCompleted);
                    });
                  },
                ),
              ),
              SizedBox(height: 16),
              Image.asset(widget.image, fit: BoxFit.cover),
              SizedBox(height: 16),
              Text('What to expect', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              SizedBox(height: 8),
              Text(
                _getExpectationText(widget.ageGroup, widget.category),
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getCategoryDescription(String category) {
    switch (category) {
      case 'Cognitive Milestones':
        return 'learning, thinking, problem-solving';
      case 'Language/Communication Milestones':
        return 'communication and language development';
      case 'Movement/Physical Development Milestones':
        return 'physical growth and motor skills';
      case 'Social/Emotional Milestones':
        return 'social interaction and emotional growth';
      default:
        return '';
    }
  }

  String _getExpectationText(String ageGroup, String category) {
    if (ageGroup == '2 - 4mo') {
      if (category == 'Cognitive Milestones') {
        return 'Your baby is becoming more aware of their surroundings and starting to show early problem-solving skills...';
      } else if (category == 'Language/Communication Milestones') {
        return 'Your baby is starting to explore vocalizations and respond to sounds as part of their language development...';
      } else if (category == 'Movement/Physical Development Milestones') {
        return 'Your baby is gaining more control over their movements and developing stronger muscles...';
      } else if (category == 'Social/Emotional Milestones') {
        return 'Your baby is beginning to show more social awareness and emotional responses...';
      }
    } else if (ageGroup == '4 - 6mo') {
      if (category == 'Cognitive Milestones') {
        return 'Your baby is becoming more curious and exploring objects with their mouth and hands...';
      } else if (category == 'Language/Communication Milestones') {
        return 'Your baby is experimenting with new sounds and beginning to communicate more intentionally...';
      } else if (category == 'Movement/Physical Development Milestones') {
        return 'Your baby is developing stronger muscles and better coordination for movement...';
      } else if (category == 'Social/Emotional Milestones') {
        return 'Your baby is showing more social awareness and beginning to express joy through laughter...';
      }
    } else if (ageGroup == '6 - 9mo') {
      if (category == 'Cognitive Milestones') {
        return 'Your baby is developing object permanence and exploring cause-and-effect relationships...';
      } else if (category == 'Language/Communication Milestones') {
        return 'Your baby is experimenting with more complex sounds and beginning to understand gestures...';
      } else if (category == 'Movement/Physical Development Milestones') {
        return 'Your baby is gaining more independence in movement and developing fine motor skills...';
      } else if (category == 'Social/Emotional Milestones') {
        return 'Your baby is developing stronger emotional responses and social awareness...';
      }
    } else if (ageGroup == '9 - 12mo') {
      if (category == 'Cognitive Milestones') {
        return 'Your baby is developing problem-solving skills and understanding object permanence better...';
      } else if (category == 'Language/Communication Milestones') {
        return 'Your baby is starting to use words and gestures to communicate more effectively...';
      } else if (category == 'Movement/Physical Development Milestones') {
        return 'Your baby is developing mobility and fine motor skills, preparing for walking...';
      } else if (category == 'Social/Emotional Milestones') {
        return 'Your baby is becoming more interactive and developing social play skills...';
      }
    } else {
      if (category == 'Cognitive Milestones') {
        return 'Your baby will start to visually track movement as part of their cognitive development...';
      } else if (category == 'Language/Communication Milestones') {
        return 'Your baby is beginning to make sounds and respond to auditory stimuli...';
      } else if (category == 'Movement/Physical Development Milestones') {
        return 'Your baby is developing early motor skills and muscle control...';
      } else if (category == 'Social/Emotional Milestones') {
        return 'Your baby is starting to show social responses and emotional connections...';
      }
    }
    return 'Your baby is developing new skills as part of their growth journey...';
  }
}