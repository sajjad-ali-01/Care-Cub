import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

enum MediaType { image, video }

class AskQuestionScreen extends StatefulWidget {
  final int? initialTabIndex;

  const AskQuestionScreen({super.key, this.initialTabIndex});

  @override
  State<AskQuestionScreen> createState() => _AskQuestionScreenState();
}

class _AskQuestionScreenState extends State<AskQuestionScreen> {
  late int selectedTabIndex;
  final List<String> tabs = ["Add Question", "Create Post"];
  final TextEditingController _contentController = TextEditingController();
  String selectedAudience = 'Public';
  String userName = '';
  String userInitials = '';
  String userPhotoUrl = '';
  bool isDoctor = false;
  bool _isUploading = false;
  File? _mediaFile;
  String? _mediaType; // 'image' or 'video'
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;


  @override
  void dispose() {
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    selectedTabIndex = widget.initialTabIndex ?? 0;
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Check if user is a doctor
        final doctorDoc = await FirebaseFirestore.instance
            .collection('Doctors')
            .doc(user.uid)
            .get();

        if (doctorDoc.exists) {
          setState(() {
            isDoctor = true;
            userName = doctorDoc['title'] + " "+ doctorDoc['name'] + " ✔️"?? 'Dr.';
            userPhotoUrl = doctorDoc['photoUrl'] ?? 'U';
          });
        } else {
          // Fetch regular user data
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

          if (userDoc.exists) {
            setState(() {
              userName = userDoc['name'] ?? '';
              userPhotoUrl = userDoc['photoUrl'] ?? '';
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

  Future<void> _pickMedia() async {
    final mediaType = await showDialog<MediaType>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Media Type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Image'),
              onTap: () => Navigator.pop(context, MediaType.image),
            ),
            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text('Video'),
              onTap: () => Navigator.pop(context, MediaType.video),
            ),
          ],
        ),
      ),
    );

    if (mediaType == null) return;

    try {
      switch (mediaType) {
        case MediaType.image:
          final pickedFile = await ImagePicker().pickImage(
            source: ImageSource.gallery,
            imageQuality: 85,
            maxWidth: 800,
          );
          if (pickedFile != null) {
            setState(() {
              _mediaFile = File(pickedFile.path);
              _mediaType = 'image';
              _videoController?.dispose();
              _chewieController?.dispose();
            });
          }
          break;

        case MediaType.video:
          final pickedFile = await ImagePicker().pickVideo(
            source: ImageSource.gallery,
            maxDuration: const Duration(minutes: 10),
          );
          if (pickedFile != null) {
            setState(() {
              _mediaFile = File(pickedFile.path);
              _mediaType = 'video';
            });
            await _initializeVideo(_mediaFile!);
          }
          break;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking file: $e')),
      );
    }
  }

  Future<String?> _uploadMediaToCloudinary() async {
    if (_mediaFile == null) return null;

    try {
      setState(() {
        _isUploading = true;
      });

      final url = Uri.parse('https://api.cloudinary.com/v1_1/dghmibjc3/upload');
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = 'CareCub'
        ..files.add(await http.MultipartFile.fromPath('file', _mediaFile!.path));

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
  Future<void> _postQuestion() async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a question')),
      );
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      setState(() {
        _isUploading = true;
      });

      // Upload media if exists
      String? mediaUrl;
      if (_mediaFile != null) {
        mediaUrl = await _uploadMediaToCloudinary();
      }

      await FirebaseFirestore.instance.collection('questions').add({
        'text': _contentController.text,
        'audience': selectedAudience,
        'authorId': user.uid,
        'authorName': userName,
        'authorIsDoctor': isDoctor,
        'timestamp': FieldValue.serverTimestamp(),
        'upvotes': 0,
        'answers': 0,
        'authorPhotoUrl': userPhotoUrl,
        'mediaUrl': mediaUrl,
        'mediaType': _mediaType,
      });

      setState(() {
        _isUploading = false;
        _mediaFile = null;
        _mediaType = null;
        _contentController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Question posted successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error posting question: $e')),
      );
    }
  }

  Future<void> _createPost() async {
    if (_contentController.text.trim().isEmpty && _mediaFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter text or add a file')),
      );
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      setState(() {
        _isUploading = true;
      });

      // Upload media if exists
      String? mediaUrl;
      if (_mediaFile != null) {
        mediaUrl = await _uploadMediaToCloudinary();
      }

      Map<String, dynamic> postData = {
        'authorId': user.uid,
        'authorIsDoctor': isDoctor,
        'authorName': userName,
        'authorPhotoUrl': userPhotoUrl,
        'comments': 0,
        'mediaUrl': mediaUrl,
        'mediaType': _mediaType, // 'image' or 'video'
        'likedBy': [],
        'likes': 0,
        'reposts': 0,
        'text': _contentController.text,
        'timestamp': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('posts').add(postData);

      setState(() {
        _isUploading = false;
        _mediaFile = null;
        _mediaType = null;
        _contentController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post created successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating post: $e')),
      );
    }
  }

  Future<void> _initializeVideo(File videoFile) async {
    _videoController?.dispose();
    _chewieController?.dispose();

    _videoController = VideoPlayerController.file(videoFile);
    await _videoController!.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoController!,
      autoPlay: false,
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

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    String currentTitle = tabs[selectedTabIndex];
    String buttonText = selectedTabIndex == 0 ? "Add" : "Post";

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.deepOrange.shade600,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
        elevation: 0,
        title: Row(
          children: [
            Text(
              currentTitle,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            const Spacer(),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _contentController,
              builder: (context, value, child) {
                final hasContent = value.text.isNotEmpty || _mediaFile != null;
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: hasContent
                        ? Colors.blue.shade900
                        : Colors.blue.shade700,
                    shape: const StadiumBorder(),
                  ),
                  onPressed: hasContent && !_isUploading
                      ? () => selectedTabIndex == 0 ? _postQuestion() : _createPost()
                      : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: _isUploading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : Text(buttonText, style: const TextStyle(color: Colors.white)),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(tabs.length, (index) {
                  bool isSelected = selectedTabIndex == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedTabIndex = index;
                        _contentController.clear();
                        _mediaFile = null;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 32.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.4,
                            child: Text(
                              tabs[index],
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? Colors.black : Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (isSelected)
                            Container(
                              height: 2,
                              width: MediaQuery.of(context).size.width * 0.4,
                              color: Colors.blue,
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: selectedTabIndex == 0
                  ? buildAddQuestionContent()
                  : buildCreatePostContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildAddQuestionContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFEAF2FF),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(16),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Tips on getting good answers quickly",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                      fontSize: 16),
                ),
                SizedBox(height: 8),
                BulletPoint(text: "Make sure your question has not been asked already"),
                BulletPoint(text: "Keep your question short and to the point"),
                BulletPoint(text: "Double-check grammar and spelling"),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.purple,
                radius: 14,
                backgroundImage: userPhotoUrl.isNotEmpty
                    ? NetworkImage(userPhotoUrl)
                    : null,
                child: userPhotoUrl.isEmpty
                    ? Text(
                  userInitials.isNotEmpty ? userInitials : 'U',
                  style: const TextStyle(color: Colors.white),
                )
                    : null,
              ),
              const SizedBox(width: 10),
              DropdownButton<String>(
                value: selectedAudience,
                items: const <String>['Public']
                    .map((String value) =>
                    DropdownMenuItem<String>(value: value, child: Text(value)))
                    .toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedAudience = newValue!;
                  });
                },
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
            child: TextField(
              controller: _contentController,
              maxLines: null,
              decoration: const InputDecoration(
                hintText: 'Start your question with "What", "How", "Why", etc.',
                border: InputBorder.none,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          if (_mediaFile != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  if (_mediaType == 'image')
                    Image.file(
                      _mediaFile!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    )
                  else if (_mediaType == 'video')
                    Column(
                      children: [
                        if (_chewieController != null &&
                            _chewieController!.videoPlayerController.value.isInitialized)
                          AspectRatio(
                            aspectRatio: _videoController!.value.aspectRatio,
                            child: Chewie(controller: _chewieController!),
                          )
                        else
                          Container(
                            height: 200,
                            color: Colors.black,
                            child: const Center(
                              child: CircularProgressIndicator(color: Colors.white),
                            ),
                          ),
                        const SizedBox(height: 8),
                        Text(
                          'Video: ${_mediaFile!.path.split('/').last}',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    )
                ],
              ),
            ),
          const Divider(height: 0.5),
        ],
      ),
    );
  }

  Widget buildCreatePostContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.purple,
              backgroundImage: userPhotoUrl.isNotEmpty
                  ? NetworkImage(userPhotoUrl)
                  : null,
              child: userPhotoUrl.isEmpty
                  ? Text(
                userInitials.isNotEmpty ? userInitials : 'U',
                style: const TextStyle(color: Colors.white),
              )
                  : null,
            ),
            title: Text(userName.isNotEmpty ? userName : 'Loading...'),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _contentController,
              maxLines: null,
              decoration: const InputDecoration(
                hintText: "Say something...",
                border: InputBorder.none,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          if (_mediaFile != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  if (_mediaType == 'image')
                    Image.file(
                      _mediaFile!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    )
                  else if (_mediaType == 'video')
                    Column(
                      children: [
                        if (_chewieController != null &&
                            _chewieController!.videoPlayerController.value.isInitialized)
                          AspectRatio(
                            aspectRatio: _videoController!.value.aspectRatio,
                            child: Chewie(controller: _chewieController!),
                          )
                        else
                          Container(
                            height: 200,
                            color: Colors.black,
                            child: const Center(
                              child: CircularProgressIndicator(color: Colors.white),
                            ),
                          ),
                        const SizedBox(height: 8),
                        Text(
                          'Video: ${_mediaFile!.path.split('/').last}',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    )
                ],
              ),
            ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: _pickMedia,
                  tooltip: 'Add Media',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BulletPoint extends StatelessWidget {
  final String text;

  const BulletPoint({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text("• ", style: TextStyle(color: Colors.blue, fontSize: 20)),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.blue),
          ),
        ),
      ],
    );
  }
}