import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'dart:io';

class AnswersScreen extends StatefulWidget {
  final String question;
  final String questionId;
  final String? scrollToAnswerId;
  final bool expandReplies;
  const AnswersScreen({
    super.key,
    required this.question,
    required this.questionId,
    this.scrollToAnswerId,
    this.expandReplies = false,
  });

  @override
  State<AnswersScreen> createState() => _AnswersScreenState();
}

class _AnswersScreenState extends State<AnswersScreen> {
  final ScrollController scrollController = ScrollController();
  final TextEditingController _answerController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();
  List<DocumentSnapshot> _answers = [];
  bool _isLoading = true;
  bool _showOnlyMyAnswers = false;
  String? _currentUserId;
  Map<String, bool> _expandedReplies = {};
  Map<String, TextEditingController> _replyControllers = {};
  Map<String, bool> _isReplying = {};
  Map<String, bool> _isUpvoting = {};
  File? _imageFile;
  File? _videoFile;
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isUploading = false;
  String userName = '';
  String userInitials = '';
  String userPhotoUrl = '';
  bool isDoctor = false;

  @override
  void initState() {
    super.initState();
    _currentUserId = _auth.currentUser?.uid;
    _fetchUserData(); // Fetch user data
    _loadAnswers().then((_) {
      if (widget.scrollToAnswerId != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToAnswer(widget.scrollToAnswerId!);
        });
      }
    });
  }

  Future<void> _fetchUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Check if user is a doctor first
        final doctorDoc = await FirebaseFirestore.instance
            .collection('Doctors')
            .doc(user.uid)
            .get();

        if (doctorDoc.exists) {
          // User is a doctor - fetch from Doctors collection
          setState(() {
            userName = doctorDoc['title'] + " "+ doctorDoc['name']?? 'Dr.' ;
            userPhotoUrl = doctorDoc['photoUrl'] ?? '';
            isDoctor = true;
          });
        } else {
          // User is not a doctor - fetch from users collection
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

          if (userDoc.exists) {
            setState(() {
              userName = userDoc['name'] ?? '';
              userPhotoUrl = userDoc['photoUrl'] ?? '';
              isDoctor = false;
            });
          }
        }

        // Get initials from name
        if (userName.isNotEmpty) {
          final initials = userName
              .split(' ')
              .where((part) => part.isNotEmpty)
              .take(2)
              .map((part) => part[0])
              .join()
              .toUpperCase();
          setState(() {
            userInitials = initials;
          });
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  void _scrollToAnswer(String answerId) {
    final index = _answers.indexWhere((a) => a.id == answerId);
    if (index != -1) {
      scrollController.animateTo(
        index * 300.0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );

      if (widget.expandReplies) {
        setState(() {
          _expandedReplies[answerId] = true;
        });
      }
    }
  }

  Future<void> _loadAnswers() async {
    try {
      setState(() {
        _isLoading = true;
      });

      Query query = _firestore
          .collection('questions')
          .doc(widget.questionId)
          .collection('answers')
          .orderBy('timestamp', descending: true);

      final querySnapshot = await query.get();

      for (var answer in querySnapshot.docs) {
        _replyControllers[answer.id] = TextEditingController();
        _expandedReplies[answer.id] = false;
        _isReplying[answer.id] = false;
        _isUpvoting[answer.id] = false;
      }

      setState(() {
        _answers = querySnapshot.docs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading answers: $e')),
      );
    }
  }

  Future<void> _showMediaSelectionDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Select Media Type"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: const Text('Image'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage();
                  },
                ),
                const Padding(padding: EdgeInsets.all(8.0)),
                GestureDetector(
                  child: const Text('Video'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickVideo();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _videoFile = null;
          if (_videoController != null) {
            _videoController!.dispose();
            _videoController = null;
          }
          if (_chewieController != null) {
            _chewieController!.dispose();
            _chewieController = null;
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> _pickVideo() async {
    try {
      final pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _videoFile = File(pickedFile.path);
          _imageFile = null;
          _initializeVideoPlayer(_videoFile!.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking video: $e')),
      );
    }
  }

  void _initializeVideoPlayer(String videoPath) async {
    if (_videoController != null) {
      await _videoController?.dispose();
    }
    if (_chewieController != null) {
      //await _chewieController?.dispose();
    }

    _videoController = VideoPlayerController.file(File(videoPath));
    await _videoController!.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoController!,
      autoPlay: true,
      looping: false,
      allowFullScreen: true,
      aspectRatio: _videoController!.value.aspectRatio,
      showControls: true,
      materialProgressColors: ChewieProgressColors(
        playedColor: Colors.red,
        handleColor: Colors.red,
        backgroundColor: Colors.grey,
        bufferedColor: Colors.grey.shade400,
      ),
    );

    setState(() {});
  }

  void _clearMedia() {
    if (_videoController != null) {
      _videoController!.dispose();
      _videoController = null;
    }
    if (_chewieController != null) {
      _chewieController!.dispose();
      _chewieController = null;
    }
    setState(() {
      _imageFile = null;
      _videoFile = null;
    });
  }

  Future<void> _postAnswer() async {
    if (_answerController.text.trim().isEmpty && _imageFile == null && _videoFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write an answer or add media')),
      );
      return;
    }

    try {
      setState(() {
        _isUploading = true;
      });

      final user = _auth.currentUser;
      if (user == null) return;

      // Get question details to notify the author
      final questionDoc = await _firestore.collection('questions').doc(widget.questionId).get();
      final questionAuthorId = questionDoc.data()?['authorId'] as String?;
      final questionAuthorName = questionDoc.data()?['authorName'] as String?;

      // Add answer
      Map<String, dynamic> answerData = {
        'text': _answerController.text,
        'questionId': widget.questionId,
        'authorId': user.uid,
        'authorName': userName,
        'authorPhotoUrl': userPhotoUrl,
        'authorIsDoctor': isDoctor,
        'timestamp': FieldValue.serverTimestamp(),
        'upvotes': 0,
        'upvotedBy': [],
        'replyCount': 0,
      };

      // Add media information if available
      if (_imageFile != null) {
        answerData['mediaType'] = 'image';
        answerData['localMediaPath'] = _imageFile!.path;
      } else if (_videoFile != null) {
        answerData['mediaType'] = 'video';
        answerData['localMediaPath'] = _videoFile!.path;
      }

      await _firestore
          .collection('questions')
          .doc(widget.questionId)
          .collection('answers')
          .add(answerData);

      // Update answer count
      await _firestore.collection('questions').doc(widget.questionId).update({
        'answers': FieldValue.increment(1),
      });

      // Create notification only if it's not the question author answering their own question
      if (questionAuthorId != null && questionAuthorId != user.uid) {
        await _firestore.collection('notifications').add({
          'userId': questionAuthorId,
          'type': 'answer',
          'questionId': widget.questionId,
          'senderId': user.uid,
          'senderName': userName,
          'timestamp': FieldValue.serverTimestamp(),
          'read': false,
          'message': '$userName answered your question: "${widget.question}"',
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Answer posted successfully!')),
      );
      _answerController.clear();
      _clearMedia();
      await _loadAnswers();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error posting answer: $e')),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _postReply(String answerId) async {
    final controller = _replyControllers[answerId];
    if (controller == null || controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write a reply')),
      );
      return;
    }

    try {
      setState(() {
        _isReplying[answerId] = true;
      });

      final user = _auth.currentUser;
      if (user == null) return;

      // Get answer details to notify the author
      final answerDoc = await _firestore
          .collection('questions')
          .doc(widget.questionId)
          .collection('answers')
          .doc(answerId)
          .get();
      final answerAuthorId = answerDoc.data()?['authorId'] as String?;
      final answerAuthorName = answerDoc.data()?['authorName'] as String?;

      // Add the reply
      await _firestore
          .collection('questions')
          .doc(widget.questionId)
          .collection('answers')
          .doc(answerId)
          .collection('replies')
          .add({
        'text': controller.text.trim(),
        'answerId': answerId,
        'authorId': user.uid,
        'authorName': userName,
        'authorPhotoUrl': userPhotoUrl,
        'authorIsDoctor': isDoctor,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Update reply count
      await _firestore
          .collection('questions')
          .doc(widget.questionId)
          .collection('answers')
          .doc(answerId)
          .update({
        'replyCount': FieldValue.increment(1),
      });

      // Create notification only if it's not the answer author replying to their own answer
      if (answerAuthorId != null && answerAuthorId != user.uid) {
        // Get the question text first
        final questionDoc = await _firestore.collection('questions').doc(widget.questionId).get();
        final questionText = questionDoc.data()?['text'] as String? ?? 'a question';

        await _firestore.collection('notifications').add({
          'userId': answerAuthorId,
          'type': 'reply',
          'questionId': widget.questionId,
          'questionText': questionText,
          'answerId': answerId,
          'senderId': user.uid,
          'senderName': userName,
          'timestamp': FieldValue.serverTimestamp(),
          'read': false,
          'message': '$userName replied to your answer on "$questionText"',
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reply posted successfully!')),
      );

      controller.clear();
      setState(() {
        _isReplying[answerId] = false;
      });
    } catch (e) {
      setState(() {
        _isReplying[answerId] = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error posting reply: $e')),
      );
    }
  }

  Future<void> _toggleUpvote(String answerId, List<dynamic> upvotedBy) async {
    try {
      if (_currentUserId == null) return;

      setState(() {
        _isUpvoting[answerId] = true;
      });

      final isUpvoted = upvotedBy.contains(_currentUserId);
      final answerIndex = _answers.indexWhere((a) => a.id == answerId);

      if (answerIndex == -1) return;

      final updatedAnswer = Map<String, dynamic>.from(_answers[answerIndex].data() as Map<String, dynamic>);
      final updatedUpvotedBy = List.from(upvotedBy);
      final currentUpvotes = updatedAnswer['upvotes'] ?? 0;

      if (isUpvoted) {
        updatedUpvotedBy.remove(_currentUserId);
        updatedAnswer['upvotes'] = currentUpvotes - 1;
      } else {
        updatedUpvotedBy.add(_currentUserId);
        updatedAnswer['upvotes'] = currentUpvotes + 1;
      }

      updatedAnswer['upvotedBy'] = updatedUpvotedBy;

      setState(() {
        _answers[answerIndex] = _answers[answerIndex].reference.update(updatedAnswer) as DocumentSnapshot<Object?>;
      });

      await _firestore
          .collection('questions')
          .doc(widget.questionId)
          .collection('answers')
          .doc(answerId)
          .update({
        'upvotes': isUpvoted ? FieldValue.increment(-1) : FieldValue.increment(1),
        'upvotedBy': isUpvoted
            ? FieldValue.arrayRemove([_currentUserId])
            : FieldValue.arrayUnion([_currentUserId]),
      });

    } catch (e) {
      _loadAnswers();
    } finally {
      setState(() {
        _isUpvoting[answerId] = false;
      });
    }
  }

  void _toggleReplies(String answerId) {
    setState(() {
      _expandedReplies[answerId] = !(_expandedReplies[answerId] ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Answers", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepOrange.shade600,
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white)
        ),
        elevation: 1,
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Text(widget.question, style: const TextStyle(fontSize: 17)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
            child: Text(
              "Responses on this question",
              style: TextStyle(color: Colors.red[400], fontSize: 15),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _answers.isEmpty
                ? const Center(
              child: Text('No answers yet. Be the first to answer!'),
            )
                : ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: _answers.length,
              itemBuilder: (context, index) {
                final answer = _answers[index];
                final data = answer.data() as Map<String, dynamic>;
                final timestamp = data['timestamp'] as Timestamp?;
                final timeAgo = timestamp != null
                    ? DateFormat('MMM d, y').format(timestamp.toDate())
                    : 'Some time ago';
                final upvotedBy = data['upvotedBy'] as List<dynamic>? ?? [];
                final isUpvoted = _currentUserId != null &&
                    upvotedBy.contains(_currentUserId);
                final replyCount = data['replyCount'] ?? 0;
                final isUpvoting = _isUpvoting[answer.id] ?? false;
                final hasMedia = data['mediaType'] != null;
                final mediaType = data['mediaType'] as String?;
                final localMediaPath = data['localMediaPath'] as String?;

                return Column(
                  children: [
                    Card(
                      margin: const EdgeInsets.all(8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              leading: CircleAvatar(
                                backgroundImage:
                                data['authorPhotoUrl'] != null
                                    ? NetworkImage(data['authorPhotoUrl'])
                                    : null,
                                child: data['authorPhotoUrl'] == null
                                    ? Text(data['authorName']
                                    ?.toString()
                                    .substring(0, 1) ??
                                    '?')
                                    : null,
                              ),
                              title: Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: data['authorName'] ?? 'Anonymous',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    if (data['authorIsDoctor'] == true) // Use this flag instead of checking for '✔️'
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
                              subtitle: Text(timeAgo),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(data['text'] ?? ''),
                            ),
                            if (hasMedia && mediaType == 'image' && localMediaPath != null)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.file(
                                  File(localMediaPath),
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            if (hasMedia && mediaType == 'video' && localMediaPath != null)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: AspectRatio(
                                  aspectRatio: 16 / 9,
                                  child: _VideoPlayerWidget(
                                    videoPath: localMediaPath,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        isUpvoted ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                                        color: isUpvoted ? Colors.blue : null,
                                      ),
                                      onPressed: isUpvoting ? null : () => _toggleUpvote(answer.id, upvotedBy),
                                    ),
                                    if (isUpvoting)
                                      const CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                                      ),
                                  ],
                                ),
                                Text('${data['upvotes'] ?? 0}'),
                                const SizedBox(width: 16),
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.comment),
                                      onPressed: () => _toggleReplies(answer.id),
                                    ),
                                  ],
                                ),
                                Text('$replyCount'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_expandedReplies[answer.id] ?? false)
                      _buildRepliesSection(answer.id),
                  ],
                );
              },
            ),
          ),
          // Answer input section with media options
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Column(
              children: [
                if (_imageFile != null)
                  Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Image.file(
                          _imageFile!,
                          width: double.infinity,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: _clearMedia,
                        ),
                      ),
                    ],
                  ),
                if (_videoFile != null)
                  Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: _chewieController != null
                              ? Chewie(controller: _chewieController!)
                              : Container(
                            color: Colors.black,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: _clearMedia,
                        ),
                      ),
                    ],
                  ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.attach_file),
                        onPressed: _showMediaSelectionDialog,
                      ),
                      Expanded(
                        child: TextField(
                          controller: _answerController,
                          decoration: const InputDecoration(
                            hintText: "Write your answer...",
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 12),
                          ),
                          maxLines: null,
                        ),
                      ),
                      _isUploading
                          ? const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                          : Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: IconButton(
                          icon: const Icon(Icons.send, color: Colors.deepOrange),
                          onPressed: _postAnswer,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildRepliesSection(String answerId) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('questions')
          .doc(widget.questionId)
          .collection('answers')
          .doc(answerId)
          .collection('replies')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading replies'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final replies = snapshot.data?.docs ?? [];
        final isReplying = _isReplying[answerId] ?? false;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 40, right: 8, bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _replyControllers[answerId] ??= TextEditingController(),
                      decoration: const InputDecoration(
                        hintText: "Write a reply...",
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      maxLines: null,
                      enabled: !isReplying,
                    ),
                  ),
                  isReplying
                      ? const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                      : IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () => _postReply(answerId),
                  ),
                ],
              ),
            ),
            ...replies.map((reply) {
              final replyData = reply.data() as Map<String, dynamic>;
              final timestamp = replyData['timestamp'] as Timestamp?;
              final timeAgo = timestamp != null
                  ? DateFormat('MMM d, y').format(timestamp.toDate())
                  : 'Some time ago';

              return Padding(
                padding: const EdgeInsets.only(left: 40, right: 8, top: 4),
                child: Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            radius: 16,
                            backgroundImage:
                            replyData['authorPhotoUrl'] != null
                                ? NetworkImage(replyData['authorPhotoUrl'])
                                : null,
                            child: replyData['authorPhotoUrl'] == null
                                ? Text(replyData['authorName']
                                ?.toString()
                                .substring(0, 1) ??
                                '?')
                                : null,
                          ),
                          title: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: replyData['authorName'] ?? 'Anonymous',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                if (replyData['authorIsDoctor'] == true) // Use this flag instead of checking for '✔️'
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
                          subtitle: Text(
                            timeAgo,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(replyData['text'] ?? ''),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _answerController.dispose();
    for (var controller in _replyControllers.values) {
      controller.dispose();
    }
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }
}

class _VideoPlayerWidget extends StatefulWidget {
  final String videoPath;

  const _VideoPlayerWidget({required this.videoPath});

  @override
  __VideoPlayerWidgetState createState() => __VideoPlayerWidgetState();
}

class __VideoPlayerWidgetState extends State<_VideoPlayerWidget> {
  late VideoPlayerController _controller;
  ChewieController? _chewieController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    _controller = VideoPlayerController.file(File(widget.videoPath));
    await _controller.initialize();
    _chewieController = ChewieController(
      videoPlayerController: _controller,
      autoPlay: false,
      looping: false,
      allowFullScreen: true,
      aspectRatio: _controller.value.aspectRatio,
      showControls: true,
      materialProgressColors: ChewieProgressColors(
        playedColor: Colors.red,
        handleColor: Colors.red,
        backgroundColor: Colors.grey,
        bufferedColor: Colors.grey.shade400,
      ),
    );
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Chewie(controller: _chewieController!);
  }
}