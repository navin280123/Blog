import 'package:firebase_database/firebase_database.dart';
import 'Post.dart'; // Adjust the path based on your project structure

Future<List<Post>> fetchPosts() async {
  final databaseReference = FirebaseDatabase.instance.ref().child('posts');
  DatabaseEvent event = await databaseReference.once();
  DataSnapshot snapshot = event.snapshot;

  if (snapshot.value == null) {
    return []; // Return an empty list if no data is found
  }

  Map<String, dynamic> postsMap = Map<String, dynamic>.from(snapshot.value as Map);

  return postsMap.entries.map((entry) {
    String id = entry.key; // The key is the post ID
    return Post.fromMap(Map<String, dynamic>.from(entry.value), id);
  }).toList();
}
