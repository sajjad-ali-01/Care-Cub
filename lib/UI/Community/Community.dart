import 'dart:async';
import 'dart:math';

import 'package:carecub/UI/BottomNavigationBar.dart';
import 'package:carecub/UI/Community/questions.dart';
import 'package:carecub/UI/Splash%20screen.dart';
import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import '../Doctor_Booking/Doctor_Side/DoctorHome.dart';

import 'AnswerScreen.dart';
import 'comments.dart';
import 'notifications.dart';
import 'userProfile.dart';
import 'Post_and_Ask_question.dart';


enum PostMenu { delete, report, share }

class CommunityHomePage extends StatefulWidget {
  const CommunityHomePage({super.key});

  @override
  State<CommunityHomePage> createState() => _CommunityHomePageState();
}

class _CommunityHomePageState extends State<CommunityHomePage> {

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final Random random = Random();
  final ScrollController scrollController = ScrollController();

  List<DocumentSnapshot> feedItems = [];
  List<DocumentSnapshot> questions = [];
  bool isLoading = true;
  bool isLoadingQuestions = true;
  bool hasMore = true;
  DocumentSnapshot? lastDocument;
  final int perPage = 10;
  final Map<String, bool> userRepostedStatus = {};
  final Map<String, StreamSubscription> postSubscriptions = {};
  final Map<String, StreamSubscription> questionsubscriptions = {};
  StreamSubscription? feedSubscription;
  VideoPlayerController? currentVideoController;
  ChewieController? currentChewieController;
  String? currentPlayingVideoId;
  int unreadCount = 0;
  StreamSubscription? unreadSubscription;


  @override
  void dispose() {
    scrollController.dispose();
    feedSubscription?.cancel();
    postSubscriptions.values.forEach((sub) => sub.cancel());
    questionsubscriptions.values.forEach((sub) => sub.cancel());
    unreadSubscription?.cancel();
    super.dispose();
  }
  void setupUnreadCountListener() {
    final userId = auth.currentUser?.uid;
    if (userId == null) return;

    unreadSubscription = firestore.collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('read', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        setState(() {
          unreadCount = snapshot.docs.length;
        });
      }
    });
  }


  Future<void> markAllNotificationsAsRead() async {
    if (unreadCount > 0) {
      final userId = auth.currentUser?.uid;
      if (userId != null) {
        final unreadNotifications = await firestore.collection('notifications')
            .where('userId', isEqualTo: userId)
            .where('read', isEqualTo: false)
            .get();

        final batch = firestore.batch();
        for (final doc in unreadNotifications.docs) {
          batch.update(doc.reference, {'read': true});
        }
        await batch.commit();
      }
    }
  }

  void initializeVideoPlayer(String videoUrl, String postId) async {
    if (currentPlayingVideoId != null && currentPlayingVideoId != postId) {
      currentVideoController?.dispose();
      currentChewieController?.dispose();
    }

    setState(() {
      currentPlayingVideoId = postId;
    });

    try {
      currentVideoController = VideoPlayerController.network(videoUrl);
      await currentVideoController!.initialize();

      currentChewieController = ChewieController(
        videoPlayerController: currentVideoController!,
        autoPlay: true,
        looping: false,
        allowFullScreen: true,
        aspectRatio: currentVideoController!.value.aspectRatio,
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.red,
          handleColor: Colors.red,
          backgroundColor: Colors.grey,
          bufferedColor: Colors.grey.shade400,
        ),
      );

      currentVideoController!.addListener(() {
        if (currentVideoController!.value.isInitialized &&
            !currentVideoController!.value.isPlaying &&
            currentVideoController!.value.position == currentVideoController!.value.duration) {
          resetVideoPlayer();
        }
      });

      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading video: $e')),
        );
      }
      resetVideoPlayer();
    }
  }

  void resetVideoPlayer() {
    if (currentVideoController != null) {
      currentVideoController!.pause();
      currentVideoController!.seekTo(Duration.zero);
      setState(() {
        currentPlayingVideoId = null;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadInitialData();
    scrollController.addListener(scrollListener);
    setupUnreadCountListener();
  }

  void scrollListener() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      loadMoreFeedItems();
    }
  }

  Future<void> loadInitialData() async {
    await Future.wait([
      loadQuestions(),
      loadInitialFeedItems(),
    ]);
  }

  Future<void> loadQuestions() async {
    try {
      setState(() => isLoadingQuestions = true);

      final querySnapshot = await firestore.collection('questions')
          .orderBy('timestamp', descending: true)
          .limit(5) // Load 5 questions initially
          .get();

      setState(() {
        questions = querySnapshot.docs;
        isLoadingQuestions = false;
      });

      // Setup listeners for these questions
      for (final question in querySnapshot.docs) {
        listenForQuestionUpdates(question.id);
      }
    } catch (e) {
      setState(() => isLoadingQuestions = false);
      debugPrint('Error loading questions: $e');
    }
  }

  Future<void> loadInitialFeedItems() async {
    try {
      setState(() => isLoading = true);

      feedSubscription = firestore.collection('posts')
          .orderBy('timestamp', descending: true)
          .limit(perPage)
          .snapshots()
          .listen((snapshot) {
        if (mounted) {
          setState(() {
            feedItems = snapshot.docs;
            isLoading = false;
            lastDocument = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
          });

          // Setup listeners for all posts
          for (final doc in snapshot.docs) {
            listenForRepostStatus(doc.id);
          }
        }
      }, onError: (error) {
        if (mounted) {
          setState(() => isLoading = false);
        }
        debugPrint('Error loading feed: $error');
      });
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint('Error loading initial feed: $e');
    }
  }

  Future<void> loadMoreFeedItems() async {
    if (!hasMore || isLoading) return;

    try {
      setState(() => isLoading = true);

      final querySnapshot = await firestore.collection('posts')
          .orderBy('timestamp', descending: true)
          .startAfterDocument(lastDocument!)
          .limit(perPage)
          .get();

      if (querySnapshot.docs.isEmpty) {
        setState(() {
          hasMore = false;
          isLoading = false;
        });
        return;
      }

      setState(() {
        feedItems.addAll(querySnapshot.docs);
        lastDocument = querySnapshot.docs.last;
        isLoading = false;
        hasMore = querySnapshot.docs.length == perPage;
      });

      // Setup listeners for new posts
      for (final doc in querySnapshot.docs) {
        listenForRepostStatus(doc.id);
      }
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint('Error loading more posts: $e');
    }
  }

  void listenForRepostStatus(String postId) {
    if (postSubscriptions.containsKey(postId)) return;

    final userId = auth.currentUser?.uid;
    if (userId == null) return;

    postSubscriptions[postId] = firestore.collection('posts')
        .where('originalPostId', isEqualTo: postId)
        .where('authorId', isEqualTo: userId)
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        setState(() {
          userRepostedStatus[postId] = snapshot.docs.isNotEmpty;
        });
      }
    });
  }

  void listenForQuestionUpdates(String questionId) {
    if (questionsubscriptions.containsKey(questionId)) return;

    questionsubscriptions[questionId] = firestore.collection('questions')
        .doc(questionId)
        .snapshots()
        .listen((snapshot) {
      if (mounted && snapshot.exists) {
        setState(() {
          final index = questions.indexWhere((q) => q.id == questionId);
          if (index != -1) {
            questions[index] = snapshot;
          }
        });
      }
    });
  }

  Future<void> handleLike(String postId, bool isLiked) async {
    try {
      final userId = auth.currentUser?.uid;
      if (userId == null) return;

      final postRef = firestore.collection('posts').doc(postId);
      final postDoc = await postRef.get();

      if (!postDoc.exists) return;

      final postAuthorId = postDoc.data()?['authorId'] as String?;
      final postAuthorName = postDoc.data()?['authorName'] as String?;
      final currentUser = auth.currentUser;
      final currentUserDoc = await firestore.collection('users').doc(userId).get();
      final currentUserName = currentUserDoc.data()?['name'] as String? ?? 'Someone';

      await firestore.runTransaction((transaction) async {
        final updatedPost = await transaction.get(postRef);
        if (!updatedPost.exists) return;

        final likes = updatedPost.data()?['likes'] as int ?? 0;
        final likedBy = updatedPost.data()?['likedBy'] as List<dynamic>? ?? [];

        if (isLiked) {
          transaction.update(postRef, {
            'likes': likes - 1,
            'likedBy': FieldValue.arrayRemove([userId])
          });
        } else {
          transaction.update(postRef, {
            'likes': likes + 1,
            'likedBy': FieldValue.arrayUnion([userId])
          });

          // Create notification only if it's not the post author liking their own post
          if (postAuthorId != null && postAuthorId != userId) {
            await firestore.collection('notifications').add({
              'userId': postAuthorId,
              'type': 'like',
              'postId': postId,
              'senderId': userId,
              'senderName': currentUserName,
              'timestamp': FieldValue.serverTimestamp(),
              'read': false,
              'message': '$currentUserName liked your post',
            });
          }
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating like: $e')),
      );
    }
  }

  Future<void> handleRepost(String postId) async {
    try {
      final userId = auth.currentUser?.uid;
      if (userId == null) return;

      final repostQuery = await firestore.collection('posts')
          .where('originalPostId', isEqualTo: postId)
          .where('authorId', isEqualTo: userId)
          .limit(1)
          .get();

      if (repostQuery.docs.isNotEmpty) {
        await firestore.collection('posts').doc(repostQuery.docs.first.id).delete();
        await firestore.collection('posts').doc(postId).update({
          'reposts': FieldValue.increment(-1),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Repost removed!')),
          );
        }
        return;
      }

      final postDoc = await firestore.collection('posts').doc(postId).get();
      if (!postDoc.exists) return;

      final originalPost = postDoc.data()!;
      final userDoc = await firestore.collection('users').doc(userId).get();
      final userData = userDoc.data() as Map<String, dynamic>?;

      await firestore.collection('posts').add({
        'type': 'repost',
        'authorId': userId,
        'authorName': userData?['name'] ?? 'Anonymous',
        'authorPhotoUrl': userData?['photoUrl'],
        'timestamp': FieldValue.serverTimestamp(),
        'originalPostId': postId,
        'originalAuthorId': originalPost['authorId'],
        'originalAuthorName': originalPost['authorName'],
        'likes': 0,
        'comments.dart': 0,
        'reposts': 0,
      });

      await firestore.collection('posts').doc(postId).update({
        'reposts': FieldValue.increment(1),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reposted successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error reposting: $e')),
        );
      }
    }
  }
  Future<void> deletePost(String postId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await firestore.collection('posts').doc(postId).delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post deleted successfully')),
        );
        // Refresh the feed
        refreshData();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting post: $e')),
        );
      }
    }
  }
  Future<void> reportPost(String postId) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Post'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please select a reason for reporting this post:'),
            const SizedBox(height: 20),
            ListTile(
              title: const Text('Inappropriate content'),
              onTap: () => Navigator.pop(context, 'Inappropriate content'),
            ),
            ListTile(
              title: const Text('Spam or misleading'),
              onTap: () => Navigator.pop(context, 'Spam or misleading'),
            ),
            ListTile(
              title: const Text('Harassment or bullying'),
              onTap: () => Navigator.pop(context, 'Harassment or bullying'),
            ),
            ListTile(
              title: const Text('Other violation'),
              onTap: () => Navigator.pop(context, 'Other violation'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (reason != null) {
      try {
        final user = auth.currentUser;
        if (user != null) {
          // Get the post data first
          final postDoc = await firestore.collection('posts').doc(postId).get();
          if (!postDoc.exists) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Post not found')),
            );
            return;
          }

          final postData = postDoc.data() as Map<String, dynamic>;

          await firestore.collection('posts')
              .doc(postId)
              .collection('reports')
              .add({
            'reporterId': user.uid,
            'reporterName': user.displayName ?? 'Anonymous',
            'reporterPhotoUrl': user.photoURL,
            'postAuthorId': postData['authorId'],
            'postAuthorName': postData['authorName'],
            'postContent': postData['text'] ?? '',
            'postMediaUrl': postData['mediaUrl'],
            'postMediaType': postData['mediaType'],
            'reason': reason,
            'timestamp': FieldValue.serverTimestamp(),
            'status': 'pending',
            'reviewedBy': null,
            'reviewedAt': null,
            'actionTaken': null,
          });

          // Also store in a separate reports collection for easy access
          await firestore.collection('reports').add({
            'postId': postId,
            'reporterId': user.uid,
            'reason': reason,
            'timestamp': FieldValue.serverTimestamp(),
            'status': 'pending',
            'postData': postData,
          });

          // Update post's report count
          await firestore.collection('posts').doc(postId).update({
            'reportCount': FieldValue.increment(1),
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Post reported successfully. Our team will review it shortly.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error reporting post: $e')),
        );
      }
    }
  }

  Future<void> sharePost(String postId) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Shared!')),
    );
  }

  Future<void> refreshData() async {
    setState(() {
      hasMore = true;
      lastDocument = null;
      feedItems.clear();
      questions.clear();
    });
    await loadInitialData();
  }

  // Function to get mixed feed items (posts and questions)
  List<Widget> getMixedFeedItems() {
    List<Widget> mixedFeed = [];
    int postIndex = 0;
    int questionIndex = 0;

    // We'll show 3-5 posts, then 2 questions, and repeat
    while (postIndex < feedItems.length || questionIndex < questions.length) {
      // Add 3-5 posts
      int postsToAdd = min(3 + random.nextInt(3), feedItems.length - postIndex);
      for (int i = 0; i < postsToAdd && postIndex < feedItems.length; i++) {
        final item = feedItems[postIndex];
        final data = item.data() as Map<String, dynamic>;
        mixedFeed.add(buildPostCard(data, item.id));
        postIndex++;
      }

      // Add 2 questions
      int questionsToAdd = min(2, questions.length - questionIndex);
      for (int i = 0; i < questionsToAdd && questionIndex < questions.length; i++) {
        final question = questions[questionIndex];
        final data = question.data() as Map<String, dynamic>;
        mixedFeed.add(buildQuestionCard(data, question.id));
        questionIndex++;
      }
    }

    return mixedFeed;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange.shade600,
        title: const Text(
          'Care Cub Community',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading:IconButton(
          onPressed: () async {
            final prefs = await SharedPreferences.getInstance();

            final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
            final isDrLoggedIn = prefs.getBool('isDrLoggedIn') ?? false;

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) {
                if (isDrLoggedIn) {
                  return DoctorDashboard();
                } else if (isLoggedIn) {
                  return Tabs();
                } else {
                  return SplashScreen();
                }
              }),
                  (Route<dynamic> route) => false,
            );
          },
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications, color: Colors.white,size: 25,),
                if (unreadCount > 0)
                  Positioned(
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                      child: Text(
                        '$unreadCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () async {
              await markAllNotificationsAsRead();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsScreen()),
              );
            },
          ),
          const SizedBox(width: 12),
        ],
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: refreshData,
        child: CustomScrollView(
          controller: scrollController,
          slivers: [
            // Search and Action Buttons Section
            SliverToBoxAdapter(
              child: Column(
                children: [
                  // Search Field
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search questions or posts...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                      onTap: () {
                        showSearch(
                          context: context,
                          delegate: CommunitySearchDelegate(),
                        );
                      },
                    ),
                  ),

                  // Action Buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        buildActionButton(
                          icon: Icons.help_outline,
                          label: 'Ask',
                          onPressed: () => navigateToAskQuestionScreen(context),
                        ),
                        buildActionButton(
                          icon: Icons.edit,
                          label: 'Answer',
                          onPressed: () => navigateToAnswerScreen(context),
                        ),
                        buildActionButton(
                          icon: Icons.post_add,
                          label: 'Post',
                          onPressed: () => navigateToCreatePostScreen(context),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                ],
              ),
            ),

            // Mixed Feed Section
            if (isLoading || isLoadingQuestions)
              SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(
                      color: Colors.red[800],
                    ),
                  ),
                ),
              )
            else if (feedItems.isEmpty && questions.isEmpty)
              SliverToBoxAdapter(
                child: const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No content yet. Be the first to post or ask a question!'),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final mixedItems = getMixedFeedItems();
                    if (index >= mixedItems.length) {
                      return hasMore
                          ? Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Colors.red[800],
                          ),
                        ),
                      )
                          : const SizedBox();
                    }
                    return mixedItems[index];
                  },
                  childCount: getMixedFeedItems().length + (hasMore ? 1 : 0),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: Colors.red[800],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 23),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 15)),
          ],
        ),
      ),
    );
  }

  Widget buildQuestionCard(Map<String, dynamic> data, String id) {
    final timestamp = data['timestamp'] as Timestamp?;
    final timeAgo = timestamp != null
        ? DateFormat('MMM d, y').format(timestamp.toDate())
        : 'Some time ago';

    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => navigateToAnswersScreen(
            context,
            question: data['text'] ?? '',
            questionId: id
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: data['authorPhotoUrl'] != null
                        ? NetworkImage(data['authorPhotoUrl'])
                        : null,
                    child: data['authorPhotoUrl'] == null
                        ? Text(data['authorName']?.toString().substring(0, 1) ?? '?')
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: data['authorName']?.replaceAll('✔️', '') ?? 'Anonymous',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              if (data['authorName']?.contains('✔️') ?? false)
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

                        Text(
                          timeAgo,
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600]
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_horiz, size: 20),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                "${data['text'] ?? ''}?",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),

              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => navigateToAnswersScreen(
                          context,
                          question: data['text'] ?? '',
                          questionId: id
                      ),
                      icon: const Icon(Icons.edit, size: 16,),
                      label: const Text('Answer',style: TextStyle(fontSize: 13),),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.orangeAccent[700],
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side:  BorderSide(color: Colors.black),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {navigateToAnswersScreen(
                          context,
                          question: data['text'] ?? '',
                          questionId: id);
                      },
                      icon: Icon(Icons.message, size: 16),
                      label: Text(
                        "${data['answers'] ?? 0} answers",
                        style: TextStyle(color: Colors.red[800],fontSize: 13),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.red[800],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(color: Colors.black), 
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        elevation: 0, 
                      ),
                    )
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPostCard(Map<String, dynamic> data, String id) {
    listenForRepostStatus(id);

    DateTime? postDate;
    if (data['timestamp'] != null) {
      if (data['timestamp'] is Timestamp) {
        postDate = (data['timestamp'] as Timestamp).toDate();
      }
    }

    final timeAgo = postDate != null
        ? DateFormat('MMM d, y').format(postDate)
        : 'Some time ago';

    final isLiked = (data['likedBy'] as List<dynamic>? ?? []).contains(auth.currentUser?.uid);
    final isRepost = data['originalPostId'] != null;
    final isMyRepost = isRepost && data['authorId'] == auth.currentUser?.uid;
    final hasReposted = userRepostedStatus[id] ?? false;

    final commentCount = isRepost ? (data['comments'] ?? 0) : (data['comments'] ?? 0);

    return StreamBuilder<DocumentSnapshot>(
      stream: isRepost ? firestore.collection('posts').doc(data['originalPostId']).snapshots() : null,
      builder: (context, snapshot) {
        final displayData = isRepost && snapshot.hasData
            ? snapshot.data!.data() as Map<String, dynamic>
            : data;

        return Card(
          elevation: 6,
          color: Colors.white,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isRepost)
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 12),
                  child: Row(
                    children: [
                      Icon(Icons.repeat, size: 16, color: isMyRepost ? Colors.deepOrange.shade600 : Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '${data['authorName']} reposted',
                        style: TextStyle(
                            color: isMyRepost ? Colors.deepOrange.shade600 : Colors.grey,
                            fontSize: 12
                        ),
                      ),
                    ],
                  ),
                ),
              Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: isRepost ? 4 : 12,
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserProfileScreen(
                            userId: displayData['authorId'],
                            userName: displayData['authorName'] ?? 'Anonymous',
                            userPhotoUrl: displayData['authorPhotoUrl'] ?? '',
                          ),
                        ),
                      );
                    },
                    child: CircleAvatar(
                      radius: 20,
                      backgroundImage: displayData['authorPhotoUrl'] != null
                          ? NetworkImage(displayData['authorPhotoUrl'] as String)
                          : null,
                      child: displayData['authorPhotoUrl'] == null
                          ? Text(displayData['authorName']?.toString().substring(0, 1) ?? '?')
                          : null,
                    ),
                  ),
                  title: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserProfileScreen(
                            userId: displayData['authorId'],
                            userName: displayData['authorName'] ?? 'Anonymous',
                            userPhotoUrl: displayData['authorPhotoUrl'] ?? '',
                          ),
                        ),
                      );
                    },
                    child:Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: data['authorName']?.replaceAll('✔️', '') ?? 'Anonymous',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          if (data['authorName']?.contains('✔️') ?? false)
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

                  ),
                  subtitle: Text(
                    timeAgo,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  trailing: PopupMenuButton<PostMenu>(
                    icon: const Icon(Icons.more_horiz, size: 20),
                    onSelected: (PostMenu result) {
                      switch (result) {
                        case PostMenu.delete:
                          deletePost(id);
                          break;
                        case PostMenu.report:
                          reportPost(id);
                          break;
                        case PostMenu.share:
                          sharePost(id);
                          break;
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      final isMyPost = displayData['authorId'] == auth.currentUser?.uid;
                      return <PopupMenuEntry<PostMenu>>[
                        if (isMyPost)
                          const PopupMenuItem<PostMenu>(
                            value: PostMenu.delete,
                            child: ListTile(
                              leading: Icon(Icons.delete, color: Colors.red),
                              title: Text('Delete', style: TextStyle(color: Colors.red)),
                            ),
                          )
                        else
                          const PopupMenuItem<PostMenu>(
                            value: PostMenu.report,
                            child: ListTile(
                              leading: Icon(Icons.report, color: Colors.orange),
                              title: Text('Report', style: TextStyle(color: Colors.orange)),
                            ),
                          ),
                        const PopupMenuItem<PostMenu>(
                          value: PostMenu.share,
                          child: ListTile(
                            leading: Icon(Icons.share),
                            title: Text('Share'),
                          ),
                        ),
                      ];
                    },
                  ),

                ),
              ),
              if (displayData['text'] != null && displayData['text'].toString().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    displayData['text'].toString(),
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
              if (displayData['mediaUrl'] != null && displayData['mediaUrl'].toString().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: displayData['mediaType'] == 'image'
                        ? Image.network(
                      displayData['mediaUrl'],
                      fit: BoxFit.cover,
                      width: double.infinity,
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
                            child: Icon(Icons.error),
                          ),
                        );
                      },
                    )
                        : displayData['mediaType'] == 'video'
                        ? buildVideoPlayer(displayData['mediaUrl'], id)
                        : buildDocumentPreview(displayData['mediaUrl']),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildPostActionButton(
                      icon: isLiked ? Icons.thumb_up_alt_sharp : Icons.thumb_up_alt_outlined,
                      label: "${displayData['likes'] ?? 0}",
                      onPressed: () => handleLike(id, isLiked),
                      color: isLiked ? Colors.orangeAccent.shade700 : null,
                    ),
                    buildPostActionButton(
                      icon: Icons.comment,
                      label: "$commentCount", 
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CommentsScreen(
                              postId: id,
                            ),
                          ),
                        );
                      },
                    ),
                    buildPostActionButton(
                      icon: Icons.repeat,
                      label: "${displayData['reposts'] ?? 0}",
                      onPressed: () => handleRepost(isRepost ? data['originalPostId'] : id),
                      color: hasReposted ? Colors.orangeAccent.shade700 : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildVideoPlayer(String videoUrl, String postId) {
    return VideoThumbnailPlayer(
      videoUrl: videoUrl,
      postId: postId,
    );
  }

  Widget buildDocumentPreview(String filePath) {
    final fileName = filePath.split('/').last;
    final extension = fileName.split('.').last.toLowerCase();

    IconData icon;
    switch (extension) {
      case 'pdf':
        icon = Icons.picture_as_pdf;
        break;
      case 'doc':
      case 'docx':
        icon = Icons.description;
        break;
      case 'txt':
        icon = Icons.text_snippet;
        break;
      default:
        icon = Icons.insert_drive_file;
    }

    return Container(
      color: Colors.grey[200],
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, size: 40, color: Colors.grey[600]),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Tap to open document',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPostActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return Expanded(
      child: TextButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 22, color: color),
        label: Text(
          label,
          style: TextStyle(color: color,fontSize: 14),
        ),
        style: TextButton.styleFrom(
          foregroundColor: Colors.blueGrey[700],
        ),
      ),
    );
  }

  void navigateToAskQuestionScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AskQuestionScreen()),
    );
  }

  void navigateToAnswerScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QuoraFeedScreen()),
    );
  }

  void navigateToCreatePostScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AskQuestionScreen(initialTabIndex: 1)),
    );
  }

  void navigateToAnswersScreen(BuildContext context, {required String question, required String questionId}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnswersScreen(
          question: question,
          questionId: questionId,
        ),
      ),
    );
  }
}

class CommunitySearchDelegate extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Center(
      child: Text('Search results for: $query'),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Center(
      child: Text('Search suggestions for: $query'),
    );
  }
}
class VideoThumbnailPlayer extends StatefulWidget {
  final String videoUrl;
  final String postId;

  const VideoThumbnailPlayer({
    required this.videoUrl,
    required this.postId,
    Key? key,
  }) : super(key: key);

  @override
  _VideoThumbnailPlayerState createState() => _VideoThumbnailPlayerState();
}

class _VideoThumbnailPlayerState extends State<VideoThumbnailPlayer> {
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;
  bool _isPlaying = false;
  bool _isInitialized = false;
  double? _aspectRatio;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _videoController = VideoPlayerController.network(widget.videoUrl);

    try {
      await _videoController.initialize();
      // Calculate aspect ratio from video dimensions
      _aspectRatio = _videoController.value.aspectRatio;
      // Show first frame as thumbnail
      await _videoController.pause();
      await _videoController.seekTo(Duration.zero);

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      debugPrint("Error initializing video: $e");
      // Fallback to 16:9 if we can't determine aspect ratio
      _aspectRatio = 16 / 9;
      setState(() {
        _isInitialized = false;
      });
    }
  }

  void _togglePlayback() {
    if (_isPlaying) {
      _videoController.pause();
      setState(() => _isPlaying = false);
    } else {
      if (_chewieController == null) {
        _chewieController = ChewieController(
          videoPlayerController: _videoController,
          autoPlay: true,
          looping: false,
          allowFullScreen: true,
          aspectRatio: _aspectRatio ?? 16 / 9,
          showControls: true,
        );
      }
      _videoController.play();
      setState(() => _isPlaying = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _togglePlayback,
      child: AspectRatio(
        aspectRatio: _aspectRatio ?? 16 / 9, // Use actual aspect ratio or fallback
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Video frame as thumbnail (always visible)
            if (_isInitialized)
              VideoPlayer(_videoController)
            else
              Container(
                color: Colors.grey[300],
                child: Center(child: CircularProgressIndicator()),
              ),

            // Play button overlay (hidden when playing)
            if (!_isPlaying)
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                padding: EdgeInsets.all(12),
                child: Icon(
                  Icons.play_arrow,
                  size: 36,
                  color: Colors.white,
                ),
              ),

            // Chewie controls when playing
            if (_isPlaying && _chewieController != null)
              Positioned.fill(
                child: Chewie(controller: _chewieController!),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _videoController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }
}