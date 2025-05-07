import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'dart:io';
import 'package:http/http.dart' as http;


class CommentsScreen extends StatefulWidget {
  final String postId;
  final String? scrollToCommentId;
  final bool expandReplies;

  const CommentsScreen({
    super.key,
    required this.postId,
    this.scrollToCommentId,
    this.expandReplies = false,
  });

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _commentController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();
  List<DocumentSnapshot> _comments = [];
  bool _isLoading = true;
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
  String _currentUserName = '';
  String _currentUserPhotoUrl = '';
  bool _currentUserIsDoctor = false;

  @override
  void initState() {
    super.initState();
    _currentUserId = _auth.currentUser?.uid;
    _fetchCurrentUserData();
    _loadComments().then((_) {
      if (widget.scrollToCommentId != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToComment(widget.scrollToCommentId!);
          if (widget.expandReplies) {
            setState(() {
              _expandedReplies[widget.scrollToCommentId!] = true;
            });
          }
        });
      }
    });
  }
  // Add this method to upload media to Cloudinary
  Future<String?> _uploadMediaToCloudinary() async {
    if (_imageFile == null && _videoFile == null) return null;

    try {
      setState(() {
        _isUploading = true;
      });

      final url = Uri.parse('https://api.cloudinary.com/v1_1/dghmibjc3/upload');
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = 'CareCub';

      if (_imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'file',
          _imageFile!.path,
        ));
      } else if (_videoFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'file',
          _videoFile!.path,
        ));
      }

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.toBytes();
        final responseString = String.fromCharCodes(responseData);
        final jsonMap = jsonDecode(responseString);
        return jsonMap['secure_url'] ?? jsonMap['url'];
      } else {
        throw Exception('Failed to upload media to Cloudinary');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading media: $e')),
      );
      return null;
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _fetchCurrentUserData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // First check if user is a doctor
      final doctorDoc = await _firestore
          .collection('Doctors')
          .doc(user.uid)
          .get();

      if (doctorDoc.exists) {
        setState(() {
          _currentUserIsDoctor = true;
          _currentUserName = doctorDoc['title'] + " "+ doctorDoc['name']?? 'Dr.' ;
          _currentUserPhotoUrl = doctorDoc['photoUrl'] ?? '';
        });
      } else {
        // If not a doctor, check regular users collection
        final userDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            _currentUserName = userDoc['name'] ?? '';
            _currentUserPhotoUrl = userDoc['photoUrl'] ?? '';
            _currentUserIsDoctor = false;
          });
        }
      }
    } catch (e) {
      print('Error fetching current user data: $e');
    }
  }

  Future<Map<String, dynamic>> _getUserData(String userId) async {
    try {
      // First check if user is a doctor
      final doctorDoc = await _firestore
          .collection('Doctors')
          .doc(userId)
          .get();

      if (doctorDoc.exists) {
        return {
          'name': 'Dr. ${doctorDoc['name'] ?? ''}',
          'photoUrl': doctorDoc['photoUrl'] ?? '',
          'isDoctor': true,
        };
      }

      // If not a doctor, check regular users collection
      final userDoc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        return {
          'name': userDoc['name'] ?? 'Anonymous',
          'photoUrl': userDoc['photoUrl'] ?? '',
          'isDoctor': false,
        };
      }

      return {
        'name': 'Anonymous',
        'photoUrl': '',
        'isDoctor': false,
      };
    } catch (e) {
      print('Error fetching user data: $e');
      return {
        'name': 'Anonymous',
        'photoUrl': '',
        'isDoctor': false,
      };
    }
  }

  void _scrollToComment(String commentId) {
    final index = _comments.indexWhere((c) => c.id == commentId);
    if (index != -1) {
      _scrollController.animateTo(
        index * 200.0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _loadComments() async {
    try {
      setState(() {
        _isLoading = true;
      });

      Query query = _firestore
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .orderBy('timestamp', descending: true);

      final querySnapshot = await query.get();

      for (var comment in querySnapshot.docs) {
        _replyControllers[comment.id] = TextEditingController();
        _expandedReplies[comment.id] = false;
        _isReplying[comment.id] = false;
        _isUpvoting[comment.id] = false;
      }

      setState(() {
        _comments = querySnapshot.docs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading comments: $e')),
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
     // await _chewieController?.dispose();
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

  // Update the _postComment method to upload media
  Future<void> _postComment() async {
    if (_commentController.text.trim().isEmpty && _imageFile == null && _videoFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write a comment or add media')),
      );
      return;
    }

    try {
      setState(() {
        _isUploading = true;
      });

      final user = _auth.currentUser;
      if (user == null) return;

      // Upload media if exists
      String? mediaUrl;
      String? mediaType;

      if (_imageFile != null || _videoFile != null) {
        mediaUrl = await _uploadMediaToCloudinary();
        mediaType = _imageFile != null ? 'image' : 'video';
      }

      // Get post details to notify the author
      final postDoc = await _firestore.collection('posts').doc(widget.postId).get();
      final postAuthorId = postDoc.data()?['authorId'] as String?;
      final postText = postDoc.data()?['text'] as String? ?? 'a post';

      // Create comment data with media info
      Map<String, dynamic> commentData = {
        'text': _commentController.text,
        'postId': widget.postId,
        'authorId': user.uid,
        'authorName': _currentUserName,
        'authorPhotoUrl': _currentUserPhotoUrl,
        'authorIsDoctor': _currentUserIsDoctor,
        'timestamp': FieldValue.serverTimestamp(),
        'upvotes': 0,
        'upvotedBy': [],
        'replyCount': 0,
        'mediaUrl': mediaUrl,
        'mediaType': mediaType,
      };

      // Add comment
      final commentRef = await _firestore
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .add(commentData);

      // Update comment count
      await _firestore.collection('posts').doc(widget.postId).update({
        'comments': FieldValue.increment(1),
      });

      // Create notification if not the post author
      if (postAuthorId != null && postAuthorId != user.uid) {
        await _firestore.collection('notifications').add({
          'userId': postAuthorId,
          'type': 'comment',
          'postId': widget.postId,
          'postText': postText,
          'commentId': commentRef.id,
          'commentText': _commentController.text,
          'senderId': user.uid,
          'senderName': _currentUserName,
          'timestamp': FieldValue.serverTimestamp(),
          'read': false,
          'message': '${_currentUserIsDoctor ? 'Dr. ' : ''}$_currentUserName commented on your post',
          'contentPreview': 'Comment: ${_commentController.text.trim()}',
          'mediaUrl': mediaUrl,
          'mediaType': mediaType,
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment posted successfully!')),
      );
      _commentController.clear();
      _clearMedia();
      await _loadComments();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error posting comment: $e')),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Widget _buildAuthorName(Map<String, dynamic> data) {
    final isDoctor = data['authorIsDoctor'] ?? false;
    final authorName = data['authorName'] ?? 'Anonymous';

    return Row(
      children: [
        Text(
          isDoctor ? authorName : authorName, // Name already includes "Dr." prefix if doctor
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDoctor ? Colors.black : Colors.black,
          ),
        ),
        if (isDoctor)
          const Padding(
            padding: EdgeInsets.only(left: 4.0),
            child: Text.rich(
                TextSpan(
                  text: ' ✔️',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                ),
            ),
          )
          ),
      ],
    );
  }


  // Update the _postReply method to include doctor status
  // Update the _postReply method to handle media if needed
  Future<void> _postReply(String commentId) async {
    final controller = _replyControllers[commentId];
    if (controller == null || controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write a reply')),
      );
      return;
    }

    try {
      setState(() {
        _isReplying[commentId] = true;
      });

      final user = _auth.currentUser;
      if (user == null) return;

      // Get comment and post details for notification
      final commentDoc = await _firestore
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .doc(commentId)
          .get();
      final commentAuthorId = commentDoc.data()?['authorId'] as String?;
      final commentText = commentDoc.data()?['text'] as String? ?? 'a comment';
      final postDoc = await _firestore.collection('posts').doc(widget.postId).get();
      final postText = postDoc.data()?['text'] as String? ?? 'a post';

      // Add the reply with doctor status
      final replyRef = await _firestore
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .doc(commentId)
          .collection('replies')
          .add({
        'text': controller.text.trim(),
        'commentId': commentId,
        'authorId': user.uid,
        'authorName': _currentUserName,
        'authorPhotoUrl': _currentUserPhotoUrl,
        'authorIsDoctor': _currentUserIsDoctor,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Update reply count
      await _firestore
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .doc(commentId)
          .update({
        'replyCount': FieldValue.increment(1),
      });

      // Create notification for the comment author
      if (commentAuthorId != null && commentAuthorId != user.uid) {
        await _firestore.collection('notifications').add({
          'userId': commentAuthorId,
          'type': 'comment_reply',
          'postId': widget.postId,
          'postText': postText,
          'commentId': commentId,
          'commentText': commentText,
          'replyId': replyRef.id,
          'senderId': user.uid,
          'senderName': _currentUserName,
          'timestamp': FieldValue.serverTimestamp(),
          'read': false,
          'message': '${_currentUserIsDoctor ? 'Dr. ' : ''}$_currentUserName replied to your comment on "$postText"',
          'contentPreview': 'Reply: ${controller.text.trim()}',
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reply posted successfully!')),
      );

      controller.clear();
      setState(() {
        _isReplying[commentId] = false;
      });
    } catch (e) {
      setState(() {
        _isReplying[commentId] = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error posting reply: $e')),
      );
    }
  }


  Future<void> _toggleUpvote(String commentId, List<dynamic> upvotedBy) async {
    try {
      if (_currentUserId == null) return;

      setState(() {
        _isUpvoting[commentId] = true;
      });

      final isUpvoted = upvotedBy.contains(_currentUserId);
      final commentIndex = _comments.indexWhere((c) => c.id == commentId);

      if (commentIndex == -1) return;

      final updatedComment = Map<String, dynamic>.from(_comments[commentIndex].data() as Map<String, dynamic>);
      final updatedUpvotedBy = List.from(upvotedBy);
      final currentUpvotes = updatedComment['upvotes'] ?? 0;

      if (isUpvoted) {
        updatedUpvotedBy.remove(_currentUserId);
        updatedComment['upvotes'] = currentUpvotes - 1;
      } else {
        updatedUpvotedBy.add(_currentUserId);
        updatedComment['upvotes'] = currentUpvotes + 1;
      }

      updatedComment['upvotedBy'] = updatedUpvotedBy;

      setState(() {
        _comments[commentIndex] = _comments[commentIndex].reference.update(updatedComment) as DocumentSnapshot<Object?>;
      });

      await _firestore
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .doc(commentId)
          .update({
        'upvotes': isUpvoted ? FieldValue.increment(-1) : FieldValue.increment(1),
        'upvotedBy': isUpvoted
            ? FieldValue.arrayRemove([_currentUserId])
            : FieldValue.arrayUnion([_currentUserId]),
      });

    } catch (e) {
      _loadComments();
    } finally {
      setState(() {
        _isUpvoting[commentId] = false;
      });
    }
  }

  void _toggleReplies(String commentId) {
    setState(() {
      _expandedReplies[commentId] = !(_expandedReplies[commentId] ?? false);
    });
  }
  // Update the CircleAvatar widget to properly show initials
  Widget _buildAvatar(String? photoUrl, String name) {
    return CircleAvatar(
      backgroundImage: photoUrl != null && photoUrl.isNotEmpty
          ? NetworkImage(photoUrl)
          : null,
      child: photoUrl == null || photoUrl.isEmpty
          ? Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: const TextStyle(color: Colors.white),
      )
          : null,
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Comments", style: TextStyle(color: Colors.white)),
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
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _comments.isEmpty
                ? const Center(
              child: Text(
                'No comments yet. Be the first to comment!',
              ),
            )
                : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: _comments.length,
              itemBuilder: (context, index) {
                final comment = _comments[index];
                final data = comment.data() as Map<String, dynamic>;
                final timestamp = data['timestamp'] as Timestamp?;
                final timeAgo = timestamp != null
                    ? DateFormat('MMM d, y').format(timestamp.toDate())
                    : 'Some time ago';
                final upvotedBy = data['upvotedBy'] as List<dynamic>? ?? [];
                final isUpvoted = _currentUserId != null &&
                    upvotedBy.contains(_currentUserId);
                final replyCount = data['replyCount'] ?? 0;
                final isUpvoting = _isUpvoting[comment.id] ?? false;
                final hasMedia = data['mediaType'] != null;
                final mediaType = data['mediaType'] as String?;
                final localMediaPath = data['localMediaPath'] as String?;

                return Column(
                  children: [
                    Card(
                      elevation: 2,
                      color: Colors.white,
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
                              title: _buildAuthorName(data),
                              subtitle: Text(timeAgo),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(data['text'] ?? ''),
                            ),
                            if (hasMedia && mediaType == 'image' && data['mediaUrl'] != null)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    data['mediaUrl'],
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        height: 200,
                                        color: Colors.grey[300],
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
                                        color: Colors.grey[300],
                                        child: const Center(
                                          child: Icon(Icons.broken_image),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            if (hasMedia && mediaType == 'video' && data['mediaUrl'] != null)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: AspectRatio(
                                  aspectRatio: 16 / 9,
                                  child: _VideoPlayerWidget(
                                    videoUrl: data['mediaUrl'],
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
                                        isUpvoted
                                            ? Icons.thumb_up
                                            : Icons.thumb_up_alt_outlined,
                                        color: isUpvoted
                                            ? Colors.deepOrange.shade600
                                            : null,
                                      ),
                                      onPressed: isUpvoting
                                          ? null
                                          : () => _toggleUpvote(
                                          comment.id, upvotedBy),
                                    ),
                                    if (isUpvoting)
                                      const CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                        AlwaysStoppedAnimation<
                                            Color>(Colors.blue),
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
                                      onPressed: () => _toggleReplies(
                                          comment.id),
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
                    if (_expandedReplies[comment.id] ?? false)
                      _buildRepliesSection(comment.id),
                  ],
                );
              },
            ),
          ),
          // Comment input section with media options
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
                          controller: _commentController,
                          decoration: const InputDecoration(
                            hintText: "Write your comment...",
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
                          onPressed: _postComment,
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


  Widget _buildRepliesSection(String commentId) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .doc(commentId)
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
        final isReplying = _isReplying[commentId] ?? false;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 40, right: 8, bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _replyControllers[commentId] ??= TextEditingController(),
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
                    onPressed: () => _postReply(commentId),
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
                          title: _buildAuthorName(replyData),
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
    _commentController.dispose();
    for (var controller in _replyControllers.values) {
      controller.dispose();
    }
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }
}

// Update the _VideoPlayerWidget to handle network URLs
class _VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const _VideoPlayerWidget({required this.videoUrl});

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
    _controller = VideoPlayerController.network(widget.videoUrl);
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