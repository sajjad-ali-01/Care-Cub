import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'AnswerScreen.dart';
import 'comments.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<DocumentSnapshot> _notifications = [];
  bool _isLoading = true;
  StreamSubscription? _notificationSubscription;

  @override
  void initState() {
    super.initState();
    _setupNotificationsListener();
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }

  Future<void> _setupNotificationsListener() async {
    try {
      setState(() => _isLoading = true);
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      _notificationSubscription = _firestore.collection('notifications')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .listen((snapshot) {
        if (mounted) {
          setState(() {
            _notifications = snapshot.docs;
            _isLoading = false;
          });
        }
      }, onError: (error) {
        if (mounted) {
          setState(() => _isLoading = false);
        }
        debugPrint('Error loading notifications: $error');
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Error setting up notifications listener: $e');
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final unreadNotifications = await _firestore.collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('read', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (final doc in unreadNotifications.docs) {
        batch.update(doc.reference, {'read': true});
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Error marking notifications as read: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange.shade600,
        title: const Text('Notifications',style: TextStyle(color: Colors.white),),
        leading: IconButton(onPressed: (){Navigator.pop(context);}, icon: Icon(Icons.arrow_back,color: Colors.white,)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
          ? const Center(child: Text('No notifications yet'))
          : RefreshIndicator(
        onRefresh: () async {
          await _setupNotificationsListener();
        },
        child: ListView.builder(
          itemCount: _notifications.length,
          itemBuilder: (context, index) {
            final notification = _notifications[index];
            final data = notification.data() as Map<String, dynamic>;
            final isRead = data['read'] ?? false;
            final timestamp = data['timestamp'] as Timestamp?;
            final timeAgo = timestamp != null
                ? DateFormat('MMM d, h:mm a').format(timestamp.toDate())
                : '';

            return ListTile(
              leading: CircleAvatar(
                child: Text(data['senderName']?.toString().substring(0, 1) ?? '?'),
              ),
              title: Text(
                data['message'] ?? 'Notification',
                style: TextStyle(
                  fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                ),
              ),
              subtitle: Text(timeAgo),
              trailing: isRead ? null : const Icon(Icons.circle, size: 10, color: Colors.blue),
              onTap: () async {
                await _firestore.collection('notifications').doc(notification.id).update({
                  'read': true,
                });
                _handleNotificationTap(data);
              },
            );
          },
        ),
      ),
    );
  }

  void _handleNotificationTap(Map<String, dynamic> notification) {
    final type = notification['type'] as String?;
    final postId = notification['postId'] as String?;
    final questionId = notification['questionId'] as String?;
    final commentId = notification['commentId'] as String?;
    final answerId = notification['answerId'] as String?;
    final replyId = notification['replyId'] as String?;

    // Get content text for display
    final postText = notification['postText'] as String? ?? 'a post';
    final questionText = notification['questionText'] as String? ?? 'a question';
    final commentText = notification['commentText'] as String? ?? 'a comment';
    final answerText = notification['answerText'] as String? ?? 'an answer';

    if (type == 'comment') {
      // Handle comment on post
      if (postId != null && commentId != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CommentsScreen(
              postId: postId,
              scrollToCommentId: commentId,
            ),
          ),
        );
      }
    }
    else if (type == 'comment_reply') {
      // Handle reply to comment
      if (postId != null && commentId != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CommentsScreen(
              postId: postId,
              scrollToCommentId: commentId,
              expandReplies: true,
            ),
          ),
        );
      }
    }
    else if (type == 'answer') {
      // Handle answer to question
      if (questionId != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnswersScreen(
              question: questionText,
              questionId: questionId,
            ),
          ),
        );
      }
    }
    else if (type == 'reply') {
      // Handle reply to answer
      if (questionId != null && answerId != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnswersScreen(
              question: questionText,
              questionId: questionId,
              scrollToAnswerId: answerId,
              expandReplies: true,
            ),
          ),
        );
      }
    }
  }

  Widget _buildPostCard(Map<String, dynamic> post, String postId) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(post['text'] ?? '', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Posted by ${post['authorName'] ?? 'Anonymous'}'),
          ],
        ),
      ),
    );
  }
}