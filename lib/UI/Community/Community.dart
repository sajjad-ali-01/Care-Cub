import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityScreen extends StatefulWidget {
  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  TextEditingController messageController = TextEditingController();
  TextEditingController commentController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;
  String? _currentMessageIdForComments;
  bool _showCommentsScreen = false;
  List<Map<String, dynamic>> _currentMessageComments = [];

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
  }

  void sendMessage() async {
    if (messageController.text.trim().isEmpty) return;

    try {
      await _firestore.collection('messages').add({
        'text': messageController.text.trim(),
        'senderId': _currentUser?.uid,
        'senderName': _currentUser?.displayName ?? 'Anonymous',
        'senderEmail': _currentUser?.email,
        'timestamp': FieldValue.serverTimestamp(),
        'isImage': false,
        'likes': [],
        'comments': [],
      });
      messageController.clear();
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  Future<void> pickImage(ImageSource imageSource) async {
    try {
      final photo = await ImagePicker().pickImage(source: imageSource);
      if (photo == null) return;

      await _firestore.collection('messages').add({
        'text': photo.path,
        'senderId': _currentUser?.uid,
        'senderName': _currentUser?.displayName ?? 'Anonymous',
        'senderEmail': _currentUser?.email,
        'timestamp': FieldValue.serverTimestamp(),
        'isImage': true,
        'likes': [],
        'comments': [],
      });
    } catch (ex) {
      print("Error picking image: ${ex.toString()}");
    }
  }

  Future<void> toggleLike(String messageId, List likes) async {
    try {
      if (likes.contains(_currentUser?.uid)) {
        await _firestore.collection('messages').doc(messageId).update({
          'likes': FieldValue.arrayRemove([_currentUser?.uid])
        });
      } else {
        await _firestore.collection('messages').doc(messageId).update({
          'likes': FieldValue.arrayUnion([_currentUser?.uid])
        });
      }
    } catch (e) {
      print('Error toggling like: $e');
    }
  }

  Future<void> loadComments(String messageId) async {
    try {
      final doc = await _firestore.collection('messages').doc(messageId).get();
      if (doc.exists) {
        setState(() {
          _currentMessageComments = List.from(doc.data()!['comments'] ?? []);
          _currentMessageIdForComments = messageId;
          _showCommentsScreen = true;
        });
      }
    } catch (e) {
      print('Error loading comments: $e');
    }
  }
  void showAlertBox() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Pick Image From"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                onTap: () {
                  pickImage(ImageSource.camera);
                  Navigator.pop(context);
                },
                leading: Icon(Icons.camera_alt),
                title: Text("Camera"),
              ),
              ListTile(
                onTap: () {
                  pickImage(ImageSource.gallery);
                  Navigator.pop(context);
                },
                leading: Icon(Icons.image),
                title: Text("Gallery"),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildCommentsScreen() {
    return Scaffold(
      appBar: AppBar(
        title: Text("Comments"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              _showCommentsScreen = false;
            });
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: _firestore.collection('messages').doc(_currentMessageIdForComments).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final comments = List.from(snapshot.data!['comments'] ?? []);
                comments.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

                return ListView.builder(
                  reverse: true,
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    final isCurrentUser = comment['senderId'] == _currentUser?.uid;

                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      child: Column(
                        crossAxisAlignment: isCurrentUser
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          if (!isCurrentUser)
                            Padding(
                              padding: EdgeInsets.only(bottom: 4),
                              child: Text(
                                comment['senderName'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                          Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.8,
                            ),
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isCurrentUser
                                  ? Colors.teal.shade100
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (comment['mediaUrl'] != null)
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 8),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: comment['mediaType'] == 'image'
                                          ? Image.network(
                                        comment['mediaUrl'],
                                        width: 200,
                                        height: 150,
                                        fit: BoxFit.cover,
                                      )
                                          : AspectRatio(
                                        aspectRatio: 16/9,
                                        child: Container(
                                          color: Colors.black,
                                          child: Center(
                                            child: Icon(
                                              Icons.play_circle_filled,
                                              color: Colors.white,
                                              size: 48,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                Text(
                                  comment['text'],
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: Text(
                              _formatTimestamp(comment['timestamp']),
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Enhanced comment input field
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: Offset(0, -1),
                ),
              ],
            ),
            child: Column(
              children: [
                if (_commentMedia != null)
                  Stack(
                    children: [
                      Container(
                        height: 100,
                        width: double.infinity,
                        margin: EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey.shade100,
                        ),
                        child: _commentMedia is File
                            ? _commentMediaType == 'image'
                            ? Image.file(
                          _commentMedia as File,
                          fit: BoxFit.cover,
                        )
                            : Icon(Icons.videocam, size: 48)
                            : _commentMediaType == 'image'
                            ? Image.network(
                          _commentMedia as String,
                          fit: BoxFit.cover,
                        )
                            : Icon(Icons.videocam, size: 48),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _commentMedia = null;
                              _commentMediaType = null;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.camera_alt, color: Colors.deepOrange.shade500),
                      onPressed: () => _pickCommentMedia(ImageSource.gallery),
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: TextField(
                          controller: commentController,
                          maxLines: null,
                          decoration: InputDecoration(
                            hintText: 'Write a comment...',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.deepOrange.shade500,
                      ),
                      child: IconButton(
                        icon: Icon(Icons.send, color: Colors.white),
                        onPressed: addComment,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

// Add these new variables to your state class
  File? _commentMedia;
  String? _commentMediaType;

  Future<void> _pickCommentMedia(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickMedia(
        imageQuality: 70,
        maxWidth: 800,
      );

      if (pickedFile != null) {
        setState(() {
          _commentMedia = File(pickedFile.path);
          _commentMediaType = pickedFile.path.endsWith('.mp4') ? 'video' : 'image';
        });
      }
    } catch (e) {
      print('Error picking media: $e');
    }
  }

// Update your addComment method to handle media
  Future<void> addComment() async {
    if (commentController.text.trim().isEmpty && _commentMedia == null) return;
    if (_currentMessageIdForComments == null) return;

    try {
      String? mediaUrl;
      String? mediaType;

      // In a real app, you would upload the media to Firebase Storage here
      // For this example, we'll just use the local path for images
      if (_commentMedia != null) {
        mediaUrl = _commentMedia is File
            ? (_commentMedia as File).path
            : _commentMedia as String;
        mediaType = _commentMediaType;
      }

      final newComment = {
        'text': commentController.text.trim(),
        'senderId': _currentUser?.uid,
        'senderName': _currentUser?.displayName ?? 'Anonymous',
        'timestamp': DateTime.now().toIso8601String(),
        'mediaUrl': mediaUrl,
        'mediaType': mediaType,
      };

      await _firestore.collection('messages').doc(_currentMessageIdForComments).update({
        'comments': FieldValue.arrayUnion([newComment])
      });

      setState(() {
        commentController.clear();
        _commentMedia = null;
        _commentMediaType = null;
      });
    } catch (e) {
      print('Error adding comment: $e');
    }
  }
  String _formatTimestamp(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      return '${dateTime.hour}:${dateTime.minute} ${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showCommentsScreen) {
      return _buildCommentsScreen();
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.deepOrange.shade500,
          title: Text("Community Chat", style: TextStyle(color: Colors.white)),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('messages')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final messages = snapshot.data!.docs;

                  return ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final data = message.data() as Map<String, dynamic>;
                      final isCurrentUser = data['senderId'] == _currentUser?.uid;
                      final senderName = data['senderName'];
                      final isImage = data['isImage'] ?? false;
                      final likes = List.from(data['likes'] ?? []);
                      final comments = List.from(data['comments'] ?? []);

                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                        child: Column(
                          crossAxisAlignment: isCurrentUser
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            if (!isCurrentUser)
                              Padding(
                                padding: EdgeInsets.only(left: 8, bottom: 2),
                                child: Text(
                                  senderName,
                                  style: TextStyle(color: Colors.grey, fontSize: 13),
                                ),
                              ),
                            Row(
                              mainAxisAlignment: isCurrentUser
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                              children: [
                                if (!isCurrentUser)
                                  CircleAvatar(
                                    backgroundImage: AssetImage("assets/images/profile_pic.png"),
                                    radius: 20,
                                  ),
                                SizedBox(width: 8),
                                Container(
                                  constraints: BoxConstraints(
                                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                                  ),
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isCurrentUser
                                        ? Colors.teal.shade200
                                        : Colors.grey.shade300,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(15),
                                      topRight: Radius.circular(15),
                                      bottomLeft: isCurrentUser ? Radius.circular(15) : Radius.zero,
                                      bottomRight: isCurrentUser ? Radius.zero : Radius.circular(15),
                                    ),
                                  ),
                                  child: isImage
                                      ? Image.file(
                                    File(data['text']),
                                    height: 200,
                                    width: 150,
                                    fit: BoxFit.cover,
                                  )
                                      : Text(
                                    data['text'],
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                                SizedBox(width: 8),
                                if (isCurrentUser)
                                  CircleAvatar(
                                    backgroundImage: AssetImage("assets/images/profile_pic.png"),
                                    radius: 20,
                                  ),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Row(
                                mainAxisAlignment: isCurrentUser
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.start,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      likes.contains(_currentUser?.uid)
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: likes.contains(_currentUser?.uid)
                                          ? Colors.red
                                          : Colors.grey,
                                    ),
                                    onPressed: () => toggleLike(message.id, likes),
                                    iconSize: 20,
                                    padding: EdgeInsets.zero,
                                    constraints: BoxConstraints(),
                                  ),
                                  Text(likes.length.toString()),
                                  SizedBox(width: 16),
                                  IconButton(
                                    icon: Icon(Icons.comment),
                                    onPressed: () => loadComments(message.id),
                                    iconSize: 20,
                                    padding: EdgeInsets.zero,
                                    constraints: BoxConstraints(),
                                  ),
                                  Text(comments.length.toString()),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              color: Colors.grey.shade200,
              child: Row(
                children: [
                  IconButton(
                    onPressed: showAlertBox,
                    icon: Icon(Icons.camera_alt, color: Colors.black),
                  ),
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(color: Colors.black),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: sendMessage,
                    icon: Icon(Icons.send, size: 28, color: Colors.deepOrange.shade500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}