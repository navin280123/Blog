import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:blog/Post.dart'; // Import your Post model
import 'PostWidget.dart'; // Import the PostWidget for reuse

class PostDetailScreen extends StatefulWidget {
  final String postId;
  final String currentUsername;

  const PostDetailScreen({
    required this.postId,
    required this.currentUsername,
  });

  @override
  _PostDetailScreenState createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late Future<Post?> _postFuture;

  @override
  void initState() {
    super.initState();
    _postFuture = _fetchPost();
  }

  Future<Post?> _fetchPost() async {
    final databaseReference = FirebaseDatabase.instance.ref().child('posts').child(widget.postId);
    final snapshot = await databaseReference.get();

    if (snapshot.exists) {
      final postMap = Map<String, dynamic>.from(snapshot.value as Map<dynamic, dynamic>);
      return Post.fromMap(postMap, widget.postId);
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Post Details'),
      ),
      body: FutureBuilder<Post?>(
        future: _postFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error loading post'));
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('Post not found'));
          }

          final post = snapshot.data!;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: PostWidget(
                post: post,
                postId: widget.postId,
                currentUsername: widget.currentUsername,
                index: 0, // Index is irrelevant in this context
              ),
            ),
          );
        },
      ),
    );
  }
}
