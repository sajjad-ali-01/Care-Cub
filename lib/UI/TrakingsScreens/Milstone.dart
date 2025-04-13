import 'package:flutter/material.dart';

class MilestonesScreen extends StatelessWidget {
  final List<Map<String, dynamic>> milestones = [
    {'image': 'assets/images/img_1.png', 'title': '0 - 2mo', 'progress': '0 / 11'},
    {'image': 'assets/images/img.png', 'title': '2 - 4mo', 'progress': '0 / 13'},
    {'image': 'assets/images/img_2.png', 'title': '4 - 6mo', 'progress': '0 / 12'},
    {'image': 'assets/images/img_3.png', 'title': '6 - 9mo', 'progress': '0 / 13'},
    {'image': 'assets/images/img_4.png', 'title': '9 - 12mo', 'progress': '0 / 10'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.arrow_back, color: Colors.grey[700]),
        title: Text('All Milestones', style: TextStyle(color: Colors.purple[800], fontWeight: FontWeight.bold)),
        backgroundColor: Colors.grey[200],
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "From their first smile to their first word, your baby's milestones are important markers of their magical growth journey.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: milestones.length,
                itemBuilder: (context, index) {
                  final milestone = milestones[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailScreen(
                            title: milestone['title'],
                            image: milestone['image'],
                          ),
                        ),
                      );
                    },
                    child: Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: Image.asset(milestone['image'], width: 60, height: 60),
                        title: Text(milestone['title'], style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 5),
                            LinearProgressIndicator(value: 0.0, backgroundColor: Colors.grey[300]),
                            SizedBox(height: 5),
                            Text(milestone['progress'], style: TextStyle(color: Colors.grey[600]))
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
    );
  }
}

class DetailScreen extends StatefulWidget {
  final String title;
  final String image;

  DetailScreen({required this.title,required this.image});

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  String? expandedCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey[700]),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.title, style: TextStyle(color: Colors.purple[800], fontWeight: FontWeight.bold)),
        backgroundColor: Colors.grey[200],
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(widget.image, height: 200, fit: BoxFit.cover),
            ),
            SizedBox(height: 16),
            Text("0 out of 11 completed", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            _buildExpandableTile('Cognitive Milestones', Icons.lightbulb_outline, Colors.green, ['Watches you as you move', 'Looks at a toy for several seconds']),
            _buildExpandableTile('Language/Communication Milestones', Icons.chat_bubble_outline, Colors.blue, ['Babbles', 'Responds to sounds']),
            Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableTile(String title, IconData icon, Color color, List<String> items) {
    bool isExpanded = expandedCategory == title;
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        leading: CircleAvatar(backgroundColor: color, child: Icon(icon, color: Colors.white)),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        initiallyExpanded: isExpanded,
        onExpansionChanged: (expanded) {
          setState(() {
            expandedCategory = expanded ? title : null;
          });
        },
        children: items.map((item) => ListTile(
          title: Text(item),
          trailing: Icon(Icons.check_circle_outline, color: Colors.grey),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NextScreen(title: item,image: widget.image,)),
            );
          },
        )).toList(),
      ),
    );
  }
}


class NextScreen extends StatelessWidget {
  final String title;
  final String image;

  NextScreen({required this.title,required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey[700]),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('0 – 2mo', style: TextStyle(color: Colors.purple[800], fontWeight: FontWeight.bold)),
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
                    backgroundImage: AssetImage(image),
                  ),
                  SizedBox(width: 10),
                  Text('0 – 2mo', style: TextStyle(color: Colors.purple[800], fontWeight: FontWeight.bold))
                ],
              ),
              SizedBox(height: 16),
              Text(
                'Cognitive Milestones (learning, thinking, problem-solving)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              SizedBox(height: 8),
              Text('Watches you as you move', style: TextStyle(fontSize: 16)),
              SizedBox(height: 16),
              ListTile(
                tileColor: Colors.grey[200],
                title: Text('Has your child done this'),
                trailing: Icon(Icons.check_circle, color: Colors.grey),
              ),
              SizedBox(height: 16),
              Image.asset(image, fit: BoxFit.cover),
              SizedBox(height: 16),
              Text('What to expect', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              SizedBox(height: 8),
              Text(
                'Your baby will start to visually track movement as part of their cognitive development.'
                    ' This involves following objects or people (including you) with their eyes. Engaging '
                    'your baby`s attention and then moving from side to side or up and down can help '
                    'strengthen their visual tracking skills. You can use colorful toys, rattles, or '
                    'even your own face to capture their interest. As they follow the movement, they are '
                    'not only improving their eye coordination but also developing their ability to focus '
                    'and process visual information. This milestone is an exciting step in their cognitive '
                    'and sensory development, laying the foundation for future skills like hand-eye '
                    'coordination and spatial awareness. Make it fun by smiling, talking, or making sounds '
                    'as you move—this interaction also supports their social and emotional growth!',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      )
    );
  }
}
