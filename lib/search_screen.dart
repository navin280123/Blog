import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class SearchScreen extends StatefulWidget {
  final String email;
  final String username;

  const SearchScreen({required this.email, required this.username});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchingForPosts = true;
  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _trendingPosts = [];

  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    _loadTrendingPosts();
  }

  void _loadTrendingPosts() async {
    try {
      final postsSnapshot = await _database.child('posts').get();
      if (postsSnapshot.exists && postsSnapshot.value is Map) {
        final Map<dynamic, dynamic> posts = postsSnapshot.value as Map<dynamic, dynamic>;
        List<Map<String, dynamic>> trendingPosts = [];

        posts.forEach((postId, postData) {
          if (postData is Map) {
            final postMap = Map<String, dynamic>.from(postData);
            final int likeCount = postMap['likes'] != null ? (postMap['likes'] as Map).length : 0;

            if (likeCount > 0) {
              trendingPosts.add({
                'id': postId,
                'caption': postMap['caption'],
                'media': postMap['media'] != null ? (postMap['media'] as List).first : null,
                'likeCount': likeCount,
                'username': postMap['username'],
              });
            }
          }
        });

        trendingPosts.sort((a, b) => b['likeCount'].compareTo(a['likeCount']));

        setState(() {
          _trendingPosts = trendingPosts;
        });
      } else {
        print("Error: Unexpected data format from Firebase.");
      }
    } catch (e) {
      print('Error loading trending posts: $e');
    }
  }

  void _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    List<Map<String, dynamic>> results = [];

    try {
      if (_isSearchingForPosts) {
        final postsSnapshot = await _database.child('posts').get();
        if (postsSnapshot.exists && postsSnapshot.value is Map) {
          final Map<dynamic, dynamic> posts = postsSnapshot.value as Map<dynamic, dynamic>;

          posts.forEach((postId, postData) {
            if (postData is Map) {
              final postMap = Map<String, dynamic>.from(postData);
              if (postMap['caption'].toString().toLowerCase().contains(query.toLowerCase())) {
                results.add({
                  'id': postId,
                  'caption': postMap['caption'],
                  'media': postMap['media'] != null ? (postMap['media'] as List).first : null,
                  'username': postMap['username'],
                });
              }
            }
          });
        }
      } else {
        final usersSnapshot = await _database.child('username').get();
        if (usersSnapshot.exists && usersSnapshot.value is Map) {
          final Map<dynamic, dynamic> users = usersSnapshot.value as Map<dynamic, dynamic>;

          users.forEach((userName, email) {
            if (userName.toString().toLowerCase().contains(query.toLowerCase()) ||
                email.toString().toLowerCase().contains(query.toLowerCase())) {
              results.add({
                'username': userName,
                'email': email,
              });
            }
          });
        }
      }
    } catch (e) {
      print('Error during search: $e');
    }

    setState(() {
      _searchResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(20.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onSubmitted: (value) => _search(),
                    decoration: InputDecoration(
                      hintText: _isSearchingForPosts ? 'Search posts...' : 'Search accounts...',
                      prefixIcon: Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchResults = [];
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(_isSearchingForPosts ? Icons.photo : Icons.account_circle),
                  onPressed: () {
                    setState(() {
                      _isSearchingForPosts = !_isSearchingForPosts;
                      _searchResults.clear();
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _searchResults.isEmpty
                ? _buildTrendingPostsGrid()
                : _isSearchingForPosts
                ? _buildPostResults()
                : _buildAccountResults(),
          ),
        ],
      ),
    );
  }

  // Trending posts in a grid layout
  Widget _buildTrendingPostsGrid() {
    if (_trendingPosts.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4.0,
        mainAxisSpacing: 4.0,
      ),
      itemCount: _trendingPosts.length,
      itemBuilder: (context, index) {
        final post = _trendingPosts[index];
        return GestureDetector(
          onTap: () {
            // Handle post tap
          },
          child: GridTile(
            child: post['media'] != null
                ? Image.network(
              post['media'],
              fit: BoxFit.cover,
            )
                : Icon(Icons.photo, size: 50),
          ),
        );
      },
    );
  }

  Widget _buildPostResults() {
    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final post = _searchResults[index];
        return ListTile(
          leading: post['media'] != null
              ? Image.network(post['media'], fit: BoxFit.cover)
              : Icon(Icons.photo),
          title: Text(post['caption']),
          subtitle: Text("by ${post['username']}"),
        );
      },
    );
  }

  Widget _buildAccountResults() {
    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final user = _searchResults[index];
        return ListTile(
          leading: CircleAvatar(
            child: Icon(Icons.person),
          ),
          title: Text(user['username']),
          subtitle: Text(user['email']),
        );
      },
    );
  }
}
