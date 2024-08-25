import 'package:firebase_database/firebase_database.dart';

class Post {
  final String caption;
  final List<String> mediaUrls;
  final DateTime timestamp;
  final String username;
  final Map<String, List<String>> comments;
  final Map<String, bool> likes;
  final String id;

  Post({
    required this.caption,
    required this.mediaUrls,
    required this.timestamp,
    required this.username,
    required this.comments,
    required this.likes,
    required this.id,
  });

  factory Post.fromMap(Map<String, dynamic> map, String id) {
    // Convert media to List<String>
    List<String> mediaUrls = [];
    if (map['media'] is List) {
      mediaUrls = List<String>.from(map['media'] ?? []);
    }

    // Convert comments to Map<String, List<String>>
    print(map['comments']);
    Map<String, List<String>> comments = {};
    if (map['comments'] is Map) {
      comments = (map['comments'] as Map).map(
            (key, value) {
          if (value is Map) {
            // Filter out null values and ensure they are strings
            final filteredComments = (value.values
                .whereType<String>()
                .toList());
            return MapEntry(key, filteredComments);
          } else {
            return MapEntry(key, []);
          }
        },
      );
    }
    print(comments);

    // Convert likes to Map<String, bool>
    Map<String, bool> likes = {};
    if (map['likes'] is Map) {
      likes = Map<String, bool>.from(map['likes']);
    }

    return Post(
      caption: map['caption'] ?? '',
      mediaUrls: mediaUrls,
      timestamp: DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
      username: map['username'] ?? '',
      comments: comments,
      likes: likes,
      id: id,
    );
  }
}
