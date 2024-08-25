import 'package:blog/EditProfileScreen.dart';
import 'package:blog/PostDetailScreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ProfileScreen extends StatefulWidget {
  final String username;

  const ProfileScreen({required this.username});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String name;
  late String profileImageUrl;
  late int postCount;
  late int followerCount;
  late int followingCount;
  bool isLoading = true;
  List<Map<String, dynamic>> posts = []; // List to store posts

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final dbRef = FirebaseDatabase.instance.ref();
    try {
      final userRef = dbRef.child('accounts').child(widget.username);

      final nameSnapshot = await userRef.child('details/name').get();
      final profileImageSnapshot = await userRef.child('details/photo').get();
      final postCountSnapshot = await userRef.child('posts').get();
      final followerCountSnapshot = await userRef.child('follower').get();
      final followingCountSnapshot = await userRef.child('following').get();

      setState(() {
        name = nameSnapshot.value as String? ?? 'Unknown Name';
        profileImageUrl = profileImageSnapshot.value as String? ?? '';
        postCount = postCountSnapshot.children.isEmpty ? 0 : postCountSnapshot.children.length;
        followerCount = followerCountSnapshot.children.isEmpty ? 0 : followerCountSnapshot.children.length;
        followingCount = followingCountSnapshot.children.isEmpty ? 0 : followingCountSnapshot.children.length;
        isLoading = false;
      });

      // Fetch posts
      await _fetchPosts();
    } catch (e) {
      print('Error fetching user data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchPosts() async {
    final dbRef = FirebaseDatabase.instance.ref();
    try {
      final postsRef = dbRef.child('accounts').child(widget.username).child('posts');
      final postsSnapshot = await postsRef.get();

      if (postsSnapshot.exists) {
        final postList = postsSnapshot.children.map((post) {
          final mediaSnapshot = post.child('media');
          final mediaUrls = mediaSnapshot.value as List<dynamic>? ?? [];

          final mediaUrl = mediaUrls.isNotEmpty ? mediaUrls.first as String : '';

          return {
            'id': post.key,
            'mediaUrls': mediaUrls.map((url) => url as String).toList(), // Collect all media URLs
            'caption': post.child('caption').value as String? ?? '',
            'timestamp': post.child('timestamp').value as String? ?? '',
          };
        }).toList();
        setState(() {
          posts = postList;
        });
      } else {
        setState(() {
          posts = [];
        });
      }
    } catch (e) {
      print('Error fetching posts: $e');
      setState(() {
        posts = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Custom profile header
          Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey[300]!, width: 1),
              ),
              color: Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: profileImageUrl.isNotEmpty ? NetworkImage(profileImageUrl) : null,
                      child: profileImageUrl.isEmpty ? Icon(Icons.person, size: 50) : null,
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                          Text('@${widget.username}', style: TextStyle(fontSize: 18, color: Colors.grey)),
                          SizedBox(height: 8.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildStatColumn(postCount, 'Posts'),
                              _buildStatColumn(followerCount, 'Followers'),
                              _buildStatColumn(followingCount, 'Following'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfileScreen(username: widget.username),
                        ),
                      );
                    },
                    child: Text('Edit Profile'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, // Background color
                      padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.0), // Space between profile details and post grid
          // Posts grid
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 2.0,
                mainAxisSpacing: 2.0,
              ),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return GestureDetector(
                  onTap: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => PostDetailScreen(postId: post[inde, currentUsername: username),
                    //   ),
                    // );
                  },
                  child: Image.network(
                    post['mediaUrls'].first,
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(int count, String label) {
    return Column(
      children: [
        Text(count.toString(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }
}
