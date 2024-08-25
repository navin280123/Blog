import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'add_post_screen.dart';
import 'notification_screen.dart';
import 'profile_screen.dart';
import 'login.dart';

class BlogMain extends StatefulWidget {
  final String email;
  final String username;

  BlogMain({required this.email, required this.username});

  @override
  _BlogMainState createState() => _BlogMainState();
}

class _BlogMainState extends State<BlogMain> {
  int _selectedIndex = 0;

  List<Widget> _widgetOptions() => [
    HomeScreen(email: widget.email, username: widget.username),
    SearchScreen(email: widget.email, username: widget.username),
    AddPostScreen(email: widget.email, username: widget.username),
    NotificationScreen(email: widget.email, username: widget.username),
    ProfileScreen( username: widget.username),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => Login()),
            (Route<dynamic> route) => false,
      );
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'BLOG',
          style: TextStyle(
            fontFamily: 'Monsteraat',
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              _signOut(context);
            },
          ),
        ],
        // No leading widget to avoid the back button
      ),
      body: _widgetOptions().elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box),
            label: 'Add Post',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,       // Color of the selected icon
        unselectedItemColor: Colors.grey,     // Color of unselected icons
        backgroundColor: Colors.white,        // Background color of the bottom bar
        onTap: _onItemTapped,
      ),
    );
  }
}
