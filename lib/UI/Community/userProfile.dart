import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;
  final String userName;
  final String userPhotoUrl;

  const UserProfileScreen({
    super.key,
    required this.userId,
    required this.userName,
    required this.userPhotoUrl,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<DocumentSnapshot> _userPosts = [];
  bool _isLoading = true;
  String _selectedFilter = 'all'; // 'all', 'images', 'videos', 'docs'

  // Video player state
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  String? _currentPlayingVideoId;

  @override
  void initState() {
    super.initState();
    _loadUserPosts();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  Future<void> _initializeVideoPlayer(String videoPath, String postId) async {
    // Dispose previous controllers if any
    if (_currentPlayingVideoId != null && _currentPlayingVideoId != postId) {
      _videoController?.dispose();
      _chewieController?.dispose();
    }

    setState(() {
      _currentPlayingVideoId = postId;
    });

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

    // Reset to initial state when video completes
    _videoController!.addListener(() {
      if (_videoController!.value.isInitialized &&
          !_videoController!.value.isPlaying &&
          _videoController!.value.position == _videoController!.value.duration) {
        _resetVideoPlayer();
      }
    });

    if (mounted) setState(() {});
  }

  void _resetVideoPlayer() {
    if (_videoController != null) {
      _videoController!.pause();
      _videoController!.seekTo(Duration.zero);
      setState(() {
        _currentPlayingVideoId = null;
      });
    }
  }

  Future<void> _loadUserPosts() async {
    try {
      Query query = _firestore.collection('posts')
          .where('authorId', isEqualTo: widget.userId)
          ;

      // Apply filter if not 'all'
      if (_selectedFilter == 'images') {
        query = query.where('fileType', isEqualTo: 'image');
      } else if (_selectedFilter == 'videos') {
        query = query.where('fileType', isEqualTo: 'video');
      } else if (_selectedFilter == 'docs') {
        query = query.where('fileType', isEqualTo: 'document');
      }

      final querySnapshot = await query.get();

      setState(() {
        _userPosts = querySnapshot.docs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading posts: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userName),
      ),
      body: Column(
        children: [
          // User Profile Header
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: widget.userPhotoUrl.isNotEmpty
                      ? NetworkImage(widget.userPhotoUrl)
                      : null,
                  child: widget.userPhotoUrl.isEmpty
                      ? const Icon(Icons.person, size: 40)
                      : null,
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.userName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${_userPosts.length} posts',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                _buildFilterChip('All', 'all'),
                _buildFilterChip('Images', 'images'),
                _buildFilterChip('Videos', 'videos'),
                _buildFilterChip('Documents', 'docs'),
              ],
            ),
          ),

          const Divider(height: 1),

          // User Posts
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _userPosts.isEmpty
                ? const Center(child: Text('No posts yet'))
                : ListView.builder(
              itemCount: _userPosts.length,
              itemBuilder: (context, index) {
                final post = _userPosts[index].data() as Map<String, dynamic>;
                return _buildUserPostCard(post, _userPosts[index].id);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        selected: _selectedFilter == value,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = value;
            _isLoading = true;
            _resetVideoPlayer(); // Reset video when changing filters
          });
          _loadUserPosts();
        },
      ),
    );
  }

  Widget _buildUserPostCard(Map<String, dynamic> post, String postId) {
    final timestamp = post['timestamp'] as Timestamp?;
    final timeAgo = timestamp != null
        ? DateFormat('MMM d, y').format(timestamp.toDate())
        : 'Some time ago';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              post['text'] ?? '',
              style: const TextStyle(fontSize: 15),
            ),
          ),

          if (post['filePath'] != null && post['filePath'].toString().isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: post['fileType'] == 'image'
                    ? Image.file(
                  File(post['filePath']),
                  fit: BoxFit.cover,
                  width: double.infinity,
                )
                    : post['fileType'] == 'video'
                    ? _buildVideoPlayer(post['filePath'], postId)
                    : _buildDocumentPreview(post['filePath']),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              timeAgo,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer(String videoPath, String postId) {
    return GestureDetector(
      onTap: () => _initializeVideoPlayer(videoPath, postId),
      child: Container(
        width: double.infinity,
        color: Colors.black,
        child: _currentPlayingVideoId == postId && _chewieController != null
            ? AspectRatio(
          aspectRatio: _videoController!.value.aspectRatio,
          child: Chewie(controller: _chewieController!),
        )
            : Container(
          height: 200,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.play_circle_fill,
                  size: 50, color: Colors.white),
              const SizedBox(height: 8),
              Text(
                'Tap to play video',
                style: TextStyle(color: Colors.white.withOpacity(0.8)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentPreview(String filePath) {
    final fileName = filePath.split('/').last;
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[200],
      child: Row(
        children: [
          const Icon(Icons.insert_drive_file, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              fileName,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}