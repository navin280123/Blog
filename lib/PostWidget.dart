import 'package:blog/Post.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart'; // Add this import to generate unique IDs

class PostWidget extends StatefulWidget {
  final Post post;
  final String postId;
  final String currentUsername;
  final int index; // Add index to differentiate cards

  const PostWidget({
    required this.post,
    required this.postId,
    required this.currentUsername,
    required this.index, // Accept index as a parameter
  });

  @override
  _PostWidgetState createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  late bool isLiked;
  bool isCommenting = false;
  final TextEditingController _commentController = TextEditingController();
  int commentCount = 0; // To track the number of comments

  // Define a list of colors
  final List<Color> _cardColors = [
    Colors.red[50]!,
    Colors.blue[50]!,
    Colors.green[50]!,
    Colors.yellow[50]!,
    Colors.orange[50]!,
  ];

  @override
  void initState() {
    super.initState();
    isLiked = widget.post.likes.containsKey(widget.currentUsername);
    commentCount = widget.post.comments.values.expand((list) => list).length;
  }

  void _toggleLike() async {
    final databaseReference = FirebaseDatabase.instance.ref().child('posts').child(widget.postId);
    final postOwnerRef = FirebaseDatabase.instance.ref().child('accounts').child(widget.post.username);

    if (isLiked) {
      await databaseReference.child('likes').child(widget.currentUsername).remove(); // Remove like
    } else {
      await databaseReference.child('likes').child(widget.currentUsername).set(true); // Add like

      // Generate a unique ID for the notification
      final notificationId = Uuid().v4();
      final message = '${widget.currentUsername} has liked your post';

      // Create a notification entry
      await postOwnerRef.child('notifications').child(notificationId).set({
        'message': message,
        'postId': widget.postId,
        'type': 'like',
        'time': DateTime.now().toIso8601String(),
        'fromUser': widget.currentUsername,
      });
    }

    setState(() {
      isLiked = !isLiked;
      // Update like count
      widget.post.likes[widget.currentUsername] = !isLiked;
    });
  }

  void _toggleCommenting() {
    setState(() {
      isCommenting = !isCommenting;
    });
  }

  void _addComment() async {
    final comment = _commentController.text.trim();
    if (comment.isEmpty) return;

    final databaseReference = FirebaseDatabase.instance.ref().child('posts').child(widget.postId);
    final postOwnerRef = FirebaseDatabase.instance.ref().child('accounts').child(widget.post.username);

    // Add comment to the database
    await databaseReference.child('comments').child(widget.currentUsername).push().set(comment);

    // Generate a unique ID for the notification
    final notificationId = Uuid().v4();
    final message = '${widget.currentUsername} commented on your post: $comment';

    // Create a notification entry
    await postOwnerRef.child('notifications').child(notificationId).set({
      'message': message,
      'postId': widget.postId,
      'type': 'comment',
      'time': DateTime.now().toIso8601String(),
      'fromUser': widget.currentUsername,
    });

    setState(() {
      _commentController.clear();
      _toggleCommenting(); // Hide the text editor after sending comment
      commentCount++; // Increment comment count
    });
  }

  void _showImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.black.withOpacity(0.8),
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Center(
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) {
                    return child;
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Icon(Icons.error, color: Colors.white),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Select color based on index
    final cardColor = _cardColors[widget.index % _cardColors.length];

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      color: cardColor, // Set the background color
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.all(8.0),
            leading: CircleAvatar(child: Text(widget.post.username[0])),
            title: Text(widget.post.username),
            subtitle: Text(widget.post.timestamp.toLocal().toString()),
          ),
          if (widget.post.mediaUrls.isNotEmpty)
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0), // Add padding around PageView
                  child: SizedBox(
                    height: 200, // Adjust height as needed
                    child: PageView.builder(
                      itemCount: widget.post.mediaUrls.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () => _showImageDialog(widget.post.mediaUrls[index]),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0), // Add padding inside PageView
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0), // Circular curve on corners
                              child: Image.network(
                                widget.post.mediaUrls[index],
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) {
                                    return child;
                                  } else {
                                    return Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Icon(Icons.error),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                if (widget.post.mediaUrls.length > 1)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.black.withOpacity(0.5),
                      child: Text(
                        '+${widget.post.mediaUrls.length}',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(widget.post.caption),
          ),
          Divider(), // Add a separator line below the caption
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border),
                  color: isLiked ? Colors.red : Colors.grey,
                  onPressed: _toggleLike,
                ),
                Text('${widget.post.likes.length} likes'),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.comment),
                  onPressed: _toggleCommenting,
                ),
                Text('$commentCount comments'), // Display number of comments
              ],
            ),
          ),
          if (isCommenting)
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Add a comment...',
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.send),
                        onPressed: _addComment,
                      ),
                    ],
                  ),
                  SizedBox(height: 8.0), // Add some spacing
                  // Display comments if available
                  ...widget.post.comments.entries.expand((entry) {
                    final username = entry.key;
                    final comments = entry.value;
                    return comments.map((comment) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              username, // Username
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(comment),
                          ],
                        ),
                      );
                    }).toList();
                  }).toList(),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
