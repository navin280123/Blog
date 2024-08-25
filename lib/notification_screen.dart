import 'package:blog/PostDetailScreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class NotificationScreen extends StatelessWidget {
  final String email;
  final String username;

  const NotificationScreen({required this.email, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<DataSnapshot>(
        future: _fetchNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error fetching notifications'));
          }

          if (!snapshot.hasData || snapshot.data?.value == null) {
            return Center(child: Text('No notifications available'));
          }

          final notificationsMap = Map<String, dynamic>.from(snapshot.data!.value as Map<dynamic, dynamic>);
          final notificationsList = notificationsMap.entries.map((entry) {
            return {
              'id': entry.key,
              ...Map<String, dynamic>.from(entry.value)
            };
          }).toList();

          return ListView.builder(
            itemCount: notificationsList.length,
            itemBuilder: (context, index) {
              final notification = notificationsList[index];
              final message = notification['message'] ?? 'No message';
              final time = notification['time'] ?? '';
              final type = notification['type'] ?? 'unknown';
              final postId = notification['postId'] ?? ''; // Get the postId from the notification

              return ListTile(
                leading: Icon(
                  type == 'like' ? Icons.favorite : Icons.comment,
                  color: type == 'like' ? Colors.red : Colors.blue,
                ),
                title: Text(message),
                subtitle: Text(time),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {
                  if (postId.isNotEmpty) {
                    // Navigate to the PostDetailScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PostDetailScreen(postId: postId, currentUsername: username),
                      ),
                    );
                  } else {
                    // Handle cases where postId is missing (optional)
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Unable to open post.')),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<DataSnapshot> _fetchNotifications() {
    final databaseReference = FirebaseDatabase.instance
        .ref()
        .child('accounts')
        .child(username)
        .child('notifications');

    return databaseReference.get();
  }
}
