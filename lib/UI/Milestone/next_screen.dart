import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class NextScreen extends StatefulWidget {
  final String title;
  final String? imageUrl;
  final String? youtubeUrl;
  final String ageGroup;
  final String category;
  final bool isCompleted;
  final Function(bool) onCompletionChanged;

  NextScreen({
    required this.title,
    this.imageUrl,
    this.youtubeUrl,
    required this.ageGroup,
    required this.category,
    required this.isCompleted,
    required this.onCompletionChanged,
  }) : assert(imageUrl != null || youtubeUrl != null,
  'Either imageUrl or youtubeUrl must be provided');

  @override
  _NextScreenState createState() => _NextScreenState();
}

class _NextScreenState extends State<NextScreen> {
  late bool isCompleted;
  late ConfettiController _confettiController;
  late YoutubePlayerController? _youtubeController;

  @override
  void initState() {
    super.initState();
    isCompleted = widget.isCompleted;
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));

    // Initialize YouTube player only if youtubeUrl is provided
    if (widget.youtubeUrl != null) {
      final videoId = YoutubePlayer.convertUrlToId(widget.youtubeUrl!) ?? '';
      _youtubeController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          enableCaption: true,
        ),
      );
    } else {
      _youtubeController = null;
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _youtubeController?.dispose();
    super.dispose();
  }

  void _toggleCompletion() {
    final newStatus = !isCompleted;
    setState(() {
      isCompleted = newStatus;
    });
    widget.onCompletionChanged(newStatus);

    if (newStatus) {
      _confettiController.play();
      Future.delayed(Duration(seconds: 3), () {
        _confettiController.stop();
      });
    }
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
        return 'Your baby is becoming more aware of their surroundings and starting to show early problem-solving skills. They begin to recognize familiar objects and people, and may show anticipation for routine activities.';
      } else if (category == 'Language/Communication Milestones') {
        return 'Your baby is starting to explore vocalizations and respond to sounds. They\'re learning the basics of communication through cooing, gurgling, and making sounds in response to your voice.';
      } else if (category == 'Movement/Physical Development Milestones') {
        return 'Your baby is gaining more control over their movements and developing stronger muscles. They can hold their head up during tummy time and may start to push up on their arms.';
      } else if (category == 'Social/Emotional Milestones') {
        return 'Your baby is beginning to show more social awareness and emotional responses. They smile spontaneously, especially at people, and enjoy playing with others.';
      }
    } else if (ageGroup == '0 - 2mo') {
      if (category == 'Cognitive Milestones') {
        return 'Your baby will start to visually track movement as part of their cognitive development. They begin to focus on faces and may follow objects with their eyes.';
      } else if (category == 'Language/Communication Milestones') {
        return 'Your baby is beginning to make sounds and respond to auditory stimuli. They may startle at loud noises and turn toward familiar sounds.';
      } else if (category == 'Movement/Physical Development Milestones') {
        return 'Your baby is developing early motor skills and muscle control. They begin to make smoother movements and gain more control over their head movements.';
      } else if (category == 'Social/Emotional Milestones') {
        return 'Your baby is starting to show social responses and emotional connections. They begin to develop a social smile and may calm when picked up or spoken to.';
      }
    }
    return 'Your baby is developing new skills as part of their growth journey. Each child develops at their own pace, so don\'t worry if your baby reaches some milestones earlier or later than others.';
  }

  Widget _buildMediaContent() {
    if (widget.youtubeUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 200,
          child: YoutubePlayer(
            controller: _youtubeController!,
            showVideoProgressIndicator: true,
            progressIndicatorColor: Colors.purple,
            progressColors: ProgressBarColors(
              playedColor: Colors.purple,
              handleColor: Colors.purple[400]!,
            ),
          ),
        ),
      );
    } else if (widget.imageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          widget.imageUrl!,
          fit: BoxFit.cover,
          height: 200,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              height: 200,
              color: Colors.grey[200],
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 200,
              color: Colors.grey[200],
              child: Center(
                child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
              ),
            );
          },
        ),
      );
    } else {
      return Container(
        height: 200,
        color: Colors.grey[200],
        child: Center(
          child: Icon(Icons.help_outline, size: 50, color: Colors.grey),
        ),
      );
    }
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
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.purple[100],
                        child: widget.youtubeUrl != null
                            ? Icon(Icons.play_circle_fill, color: Colors.purple)
                            : Icon(Icons.image, color: Colors.purple),
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
                    title: Text('Has your child done this?'),
                    trailing: IconButton(
                      icon: Icon(
                        isCompleted ? Icons.check_circle : Icons.check_circle_outline,
                        color: isCompleted ? Colors.purple : Colors.grey,
                        size: 30,
                      ),
                      onPressed: _toggleCompletion,
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildMediaContent(),
                  SizedBox(height: 16),
                  Text('What to expect', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  SizedBox(height: 8),
                  Text(
                    _getExpectationText(widget.ageGroup, widget.category),
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 20),
                  if (isCompleted)
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green[200]!)
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.celebration, color: Colors.green),
                          SizedBox(width: 10),
                          Text('Milestone completed!', style: TextStyle(color: Colors.green[800])),
                        ],
                      ),
                    )
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
}