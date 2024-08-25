import 'package:blog/FetchPost.dart';
import 'package:blog/Post.dart';
import 'package:blog/PostWidget.dart';
import 'package:flutter/material.dart'; // Ensure this path is correct

class HomeScreen extends StatefulWidget {
  final String email;
  final String username;

  const HomeScreen({required this.email, required this.username});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Post>> _postsFuture;

  @override
  void initState() {
    super.initState();
    _postsFuture = fetchPosts();
  }

  Future<void> _refreshPosts() async {
    setState(() {
      _postsFuture = fetchPosts(); // Refresh the posts
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshPosts, // Function to call on pull-to-refresh
        child: FutureBuilder<List<Post>>(
          future: _postsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No posts available.'));
            }

            final posts = snapshot.data!;

            return ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                return PostWidget(
                  post: posts[index],
                  postId: posts[index].id,
                  currentUsername: widget.username,
                  index: index, // Pass the index to the PostWidget
                );
              },
            );
          },
        ),
      ),
    );
  }
}
