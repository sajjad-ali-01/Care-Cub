import 'package:flutter/material.dart';
import 'next_screen.dart';
import 'package:confetti/confetti.dart';

class DetailScreen extends StatefulWidget {
  final String title;
  final String image;
  final int initialCompleted;
  final int totalMilestones;
  final String docId;
  final List<String> items;
  final Map<String, bool> completedItems;
  final Function(String, int, Map<String, bool>) onUpdate;
  final VoidCallback onCelebrate;

  DetailScreen({
    required this.title,
    required this.image,
    required this.initialCompleted,
    required this.totalMilestones,
    required this.docId,
    required this.items,
    required this.completedItems,
    required this.onUpdate,
    required this.onCelebrate,
  });

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late int completedCount;
  late Map<String, bool> completedItems;
  late ConfettiController _confettiController;

  // Map containing either imageUrl or youtubeUrl for each milestone
  final Map<String, Map<String, String>> milestoneMedia = {
    // 0-2 months
    'Watches you as you move': {'youtubeUrl': 'https://youtu.be/5AKUzlW7pcw'},
    'Looks at a toy for several seconds': {'imageUrl': 'https://www.cdc.gov/ncbddd/actearly/milestones/images/2-Months_Looks-at-a-toy-for-several-seconds.jpg'},
    'Babbles': {'youtubeUrl': 'https://youtu.be/nFVh8cPr9Dk'},
    'Crawling': {'youtubeUrl': 'https://youtu.be/nFVh8cPr9Dk'},
    'Responds to sounds': {'youtubeUrl': 'https://youtu.be/ZQ2tm9mvDG4'},
    'Moves both arms and both legs': {'youtubeUrl': 'https://youtu.be/R7kQMd8M3U4'},
    'Holds head up when on tummy': {'imageUrl': 'https://www.cdc.gov/ncbddd/actearly/milestones/images/2-months_Holds-head-up-when-on-tummy.png'},
    'Makes smoother movements with arms and legs': {'youtubeUrl': 'https://youtu.be/kM4Xf3-IKj4'},
    'Begins to smile at people': {'imageUrl': 'https://www.cdc.gov/ncbddd/actearly/milestones/images/2-months_Seems-Happy-to-See-You.png'},
    'Can briefly calm themselves': {'imageUrl': 'https://www.cdc.gov/ncbddd/actearly/milestones/images/2-months_Calms-down-when-spoken-to-or-picked-up-1.png'},
    'Smiles when you talk to or smile at her': {'youtubeUrl': 'https://youtu.be/osLAmjKZm6s'},
    'Looks at faces': {'imageUrl': 'https://www.cdc.gov/ncbddd/actearly/milestones/images/2-months_Looks-at-your-face_1.png'},

    // 2-4 months
    'If hungry, opens mouth when sees breast or bottle': {'imageUrl': 'https://www.cdc.gov/ncbddd/actearly/milestones/images/4-months-If-hungry-opens-mouth-when-she-sees-breast-or-bottle.png'},
    'Looks at his hands with interest': {'youtubeUrl': 'https://youtu.be/LjnVH041ro0'},
    'Make sounds like "ooo","aahh"': {'youtubeUrl': 'https://youtu.be/8vnX60PxlTg'},
    'Makes sounds back when you talk': {'youtubeUrl': 'https://youtu.be/8wSuua6pKHI'},
    'Turns head toward the sound of your voice': {'youtubeUrl': 'https://youtu.be/dPvQazyoRS0'},
    'Uses arms to swing a toy': {'youtubeUrl': 'https://youtu.be/DILHfYfO6Ck'},
    'Holds head steady without support when you\'re holding': {'youtubeUrl': 'https://youtu.be/vt1r42EXBPg'},
    'Holds a toy/object briefly when you put in his hand': {'youtubeUrl': 'https://youtu.be/giUtPBtowDw'},
    'Brings hands to mouth': {'youtubeUrl': 'https://youtu.be/DUiytQAXkyc'},
    'Pushes up onto elbows/forearms when on tummy': {'imageUrl': 'https://www.cdc.gov/ncbddd/actearly/milestones/images/4-months_-pushes-up-onto-elbows-forearms-when-on-tummy.png'},
    'Smiles on his own to get your attention': {'youtubeUrl': 'https://youtu.be/dUFpDchxJ1Y'},
    'Chuckles (not yet a full laugh when you try to make her laugh)': {'youtubeUrl': 'https://youtu.be/1Q-wilrN8GU'},
    'Looks at you, moves, or makes sounds to get or keep your attention': {'youtubeUrl': 'https://youtu.be/O6Bma5ZlrfQ'},

    // 4-6 months
    'Puts things in mouth to explore them': {'imageUrl': 'https://www.cdc.gov/ncbddd/actearly/milestones/images/6-Months_Puts-things-in-her-mouth-to-explore-them.png'},
    'Reaches to grab a toy wants': {'imageUrl': 'https://www.cdc.gov/ncbddd/actearly/milestones/images/6-Months_Reaches-to-grab-a-toy-she-wants.png'},
    'Closes lips to show she doesn\'t want more food': {'youtubeUrl': 'https://youtu.be/jO86kP4bdRQ'},
    'Takes turns making sound with you': {'youtubeUrl': 'https://youtu.be/FCcQeYVNVGE'},
    'Blows "raspberries" (stick tongue out and blows)': {'youtubeUrl': 'https://youtu.be/Oga2f0mCyRI'},
    'Makes squealing noises': {'youtubeUrl': 'https://youtu.be/RG8NVPbhT3E'},
    'Rolls from tummy to back': {'youtubeUrl': 'https://youtu.be/5tgdkihi3r4'},
    'Pushes up with straight arms when on tummy': {'imageUrl': 'https://www.cdc.gov/ncbddd/actearly/milestones/images/6-Months_Pushes-up-with-straight-arms-when-on-tummy.png'},
    'Leans on hands to support himself when sitting': {'imageUrl': 'https://www.cdc.gov/ncbddd/actearly/milestones/images/6-months_Leans-on-hands-to-support-herself-when-sitting.png'},
    'Knows familiar people': {'imageUrl': 'https://www.cdc.gov/ncbddd/actearly/milestones/images/6-Months_Knows-familiar-people-1.png'},
    'Likes to look himself in a mirror': {'imageUrl': 'https://www.cdc.gov/ncbddd/actearly/milestones/images/6-Months_Likes-to-look-at-self-in-a-mirror.png'},
    'Laughs': {'youtubeUrl': 'https://youtu.be/hnAJCmvXQv8'},

    // 6-9 months
    'Looks for objects when dropped out of sight': {'youtubeUrl': 'https://youtu.be/Oi2C5I0dRMs'},
    'Bangs two things together': {'youtubeUrl': 'https://youtu.be/Yjei6r9v3Ck'},
    'Makes different sounds like "mamamama" and "babababa"': {'youtubeUrl': 'https://youtu.be/ah7h8pz02NY'},
    'Lifts arms up to be picked up': {'youtubeUrl': 'https://youtu.be/xiNpIYUvvk0'},
    'Gets to sitting position by himself': {'youtubeUrl': 'https://youtu.be/blts1HhYk6s'},
    'Moves things from one hand to other hand': {'imageUrl': 'https://www.cdc.gov/ncbddd/actearly/milestones/images/9-Months_Moves-things-from-one-hand-to-the-other_1.png'},
    'Uses fingers to "rake" food towards himself': {'youtubeUrl': 'https://youtu.be/h8f5YEuyrFk'},
    'Sits without support': {'imageUrl': 'https://www.cdc.gov/ncbddd/actearly/milestones/images/9-Months_Sits-without-support.png'},
    'Is shy, clingy, or fearful around strangers': {'youtubeUrl': 'https://youtu.be/_Z1bHpCq_kw'},
    'Shows several facial expressions, like happy, sad, angry and surprised': {'imageUrl': 'https://www.cdc.gov/ncbddd/actearly/milestones/checklist/images/9-Months_Shows-several-facial-expressions_1_SmTxt.png'},
    'Looks when you call his/her name': {'youtubeUrl': 'https://youtu.be/2zEEh4hM7dw'},
    'Reacts when you leave (looks, reaches for you, or cries)': {'youtubeUrl': 'https://youtu.be/HbE7HbOeIAM'},
    'Smiles or laughs when you play': {'imageUrl': 'https://www.cdc.gov/ncbddd/actearly/milestones/checklist/images/9-months_smiles-or-laughs-when-you-play-peekaboo_1.png'},

    // 9-12 months
    'Put something in a container, like a block in a cup': {'youtubeUrl': 'https://youtu.be/Bu2W89FzKiw'},
    'Looks for things you hide, like a toy under a blanket': {'youtubeUrl': 'https://youtu.be/0kjoCFXP4gs'},
    'Waves "bye-bye"': {'youtubeUrl': 'https://youtu.be/GqV34gup6TQ'},
    'Calls a parent "mama" or "papa" or any other name': {'youtubeUrl': 'https://youtu.be/zQafMJwPzKQ'},
    'Understands "no" (pauses briefly or stops when you say it)': {'youtubeUrl': 'https://youtu.be/n-z_MA8u-w4'},
    'Pulls up to stand': {'imageUrl': 'https://www.cdc.gov/ncbddd/actearly/milestones/images/1-Year-Pulls-up-to-stand.png'},
    'Walks holding on to the furniture': {'youtubeUrl': 'https://youtu.be/IsWTBFfj3Y0'},
    'Drinks from a cup without a lid, as you hold it': {'youtubeUrl': 'https://youtu.be/mq0ywrwcmCE'},
    'Picks things up between thumb and pointer finger': {'youtubeUrl': 'https://youtu.be/5q3azhKq0dQ'},
    'Plays games with you': {'youtubeUrl': 'https://youtu.be/2JVhfYtMAlQ'},
  };

  @override
  void initState() {
    super.initState();
    completedCount = widget.initialCompleted;
    completedItems = Map<String, bool>.from(widget.completedItems);
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _updateCompletion(String item, bool isCompleted) async {
    int newCount = completedCount;

    if (isCompleted && !(completedItems[item] ?? false)) {
      newCount++;
    } else if (!isCompleted && (completedItems[item] ?? false)) {
      newCount--;
    }

    setState(() {
      completedItems[item] = isCompleted;
      completedCount = newCount;
    });

    await widget.onUpdate(widget.docId, newCount, completedItems);

    if (newCount == widget.totalMilestones) {
      widget.onCelebrate();
      _confettiController.play();
      Future.delayed(Duration(seconds: 3), () => _confettiController.stop());
    }
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
        backgroundColor: Colors.deepOrange.shade600,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(widget.image, height: 200, fit: BoxFit.cover),
                  ),
                  SizedBox(height: 16),
                  Text(
                      "$completedCount out of ${widget.totalMilestones} completed",
                      style: TextStyle(fontWeight: FontWeight.bold)
                  ),
                  if (completedCount == widget.totalMilestones)
                    Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        "🎉 All milestones completed! 🎉",
                        style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 16
                        ),
                      ),
                    ),
                  SizedBox(height: 16),

                  if (widget.title == '0 - 2mo') ...[
                    _buildExpandableTile(
                        'Cognitive Milestones', Icons.lightbulb_outline,
                        Colors.green, [
                      'Watches you as you move',
                      'Looks at a toy for several seconds',
                      'Running'
                    ]),
                    _buildExpandableTile('Language/Communication Milestones',
                        Icons.chat_bubble_outline, Colors.blue, [
                          'Babbles',
                          'Responds to sounds'
                        ]),
                    _buildExpandableTile('Movement/Physical Development Milestones',
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
                      'Smiles when you talk to or smile at her',
                      'Looks at faces'
                    ]),
                  ] else if (widget.title == '2 - 4mo') ...[
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
                  ] else if (widget.title == '4 - 6mo') ...[
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
                  ] else if (widget.title == '6 - 9mo') ...[
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
                  ] else if (widget.title == '9 - 12mo') ...[
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
                  ],
                  SizedBox(height: 20),
                ],
              ),
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
                    completedItems[item] == true ? Icons.check_circle : Icons.check_circle_outline,
                    color: completedItems[item] == true ? color : Colors.grey,
                  ),
                  onPressed: () {
                    _updateCompletion(item, !(completedItems[item] ?? false));
                  },
                ),
                onTap: () {
                  final media = milestoneMedia[item] ?? {};
                  final hasImage = media.containsKey('imageUrl');
                  final hasVideo = media.containsKey('youtubeUrl');

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NextScreen(
                        title: item,
                        imageUrl: hasImage ? media['imageUrl'] : null,
                        youtubeUrl: hasVideo ? media['youtubeUrl'] : null,
                        ageGroup: widget.title,
                        category: title,
                        isCompleted: completedItems[item] ?? false,
                        onCompletionChanged: (isCompleted) {
                          _updateCompletion(item, isCompleted);
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